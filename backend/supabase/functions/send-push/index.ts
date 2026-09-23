// =============================================================================
// send-push Edge Function (P1 — generic FCM sender)
// -----------------------------------------------------------------------------
// INTERNAL ONLY: called by other functions / pg_net with the header
//   x-internal-key: <INTERNAL_FUNCTIONS_KEY>
// Never by the app. Deploy with --no-verify-jwt.
//
// Payload (SendPushPayload — docs §5.1):
//   { kind, title, body, data?, userIds? | segment?: { mosqueId }, collapseKey?,
//     imageUrl?, mosqueId?, postId?, campaignId? }
//
// Algorithm: recipients → profiles.push_prefs[kind] !== false → device_tokens
//   → FCM v1 per token (concurrency 20) → notifications_log rows
//   → delete invalid tokens. Returns { sent, failed, invalidated, recipients }.
// =============================================================================

import { serviceClient } from "../_shared/supabase.ts";
import { json } from "../_shared/stripe.ts";
import { mapConcurrent, sendToToken } from "../_shared/push.ts";

type PushKind =
  | "mosque_post" | "mosque_event" | "mosque_campaign" | "mosque_broadcast"
  | "mosque_status" | "dua_ameen" | "family_milestone" | "system";

interface Payload {
  kind: PushKind;
  title: string;
  body: string;
  data?: Record<string, string>;
  userIds?: string[];
  segment?: { mosqueId: number };
  collapseKey?: string;
  imageUrl?: string;
  mosqueId?: number;
  postId?: number;
  campaignId?: number;
}

Deno.serve(async (req) => {
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const internalKey = Deno.env.get("INTERNAL_FUNCTIONS_KEY");
  if (!internalKey || req.headers.get("x-internal-key") !== internalKey) {
    return json({ error: "unauthorized" }, 401);
  }

  let payload: Payload;
  try {
    payload = (await req.json()) as Payload;
  } catch {
    return json({ error: "bad_request" }, 400);
  }
  if (!payload.kind || !payload.title) return json({ error: "bad_request" }, 400);

  const admin = serviceClient();

  // 1. Recipients
  let userIds: string[] = [];
  if (payload.segment?.mosqueId) {
    const { data, error } = await admin
      .from("mosque_followers")
      .select("user_id")
      .eq("mosque_id", payload.segment.mosqueId)
      .eq("notify", true);
    if (error) return json({ error: "db_error", detail: error.message }, 500);
    userIds = (data ?? []).map((r) => r.user_id as string);
  } else if (Array.isArray(payload.userIds)) {
    userIds = payload.userIds.filter((u) => typeof u === "string");
  }
  userIds = [...new Set(userIds)];
  if (userIds.length === 0) return json({ sent: 0, failed: 0, invalidated: 0, recipients: 0 });

  // 2. Preferences (missing key = enabled)
  const { data: profiles } = await admin
    .from("profiles")
    .select("id, push_prefs")
    .in("id", userIds);
  const allowed = new Set(
    (profiles ?? [])
      .filter((p) => (p.push_prefs as Record<string, unknown> | null)?.[payload.kind] !== false)
      .map((p) => p.id as string),
  );

  // 3. Tokens
  const { data: tokens } = await admin
    .from("device_tokens")
    .select("id, user_id, token")
    .in("user_id", [...allowed]);
  const targets = tokens ?? [];

  // 4. Log rows FIRST so every push carries its own logId (open tracking).
  const baseData: Record<string, string> = {
    kind: payload.kind,
    link: payload.data?.link ?? "",
    ...(payload.data ?? {}),
  };
  const recipientIds = [...new Set(targets.map((t) => t.user_id as string))];
  if (recipientIds.length === 0) return json({ sent: 0, failed: 0, invalidated: 0, recipients: allowed.size });

  const { data: logRows, error: logErr } = await admin
    .from("notifications_log")
    .insert(recipientIds.map((user_id) => ({
      user_id,
      kind: payload.kind,
      title: payload.title,
      body: payload.body,
      data: baseData,
      mosque_id: payload.mosqueId ?? payload.segment?.mosqueId ?? null,
      post_id: payload.postId ?? null,
      campaign_id: payload.campaignId ?? null,
      status: "pending",
    })))
    .select("id, user_id");
  if (logErr) return json({ error: "db_error", detail: logErr.message }, 500);
  const logIdByUser = new Map((logRows ?? []).map((r) => [r.user_id as string, r.id as number]));

  // 5. Send
  const results = await mapConcurrent(targets, 20, async (t) => {
    const uid = t.user_id as string;
    const r = await sendToToken(t.token as string, {
      title: payload.title,
      body: payload.body,
      data: { ...baseData, logId: String(logIdByUser.get(uid) ?? "") },
      collapseKey: payload.collapseKey,
      imageUrl: payload.imageUrl,
    });
    return { t, r };
  });

  // 6. Statuses + cleanup
  const okUsers = new Set<string>();
  const failed = new Map<string, string>();
  const invalidIds: number[] = [];
  for (const { t, r } of results) {
    const uid = t.user_id as string;
    if (r.ok) okUsers.add(uid);
    else {
      if (r.invalid) invalidIds.push(t.id as number);
      if (!failed.has(uid)) failed.set(uid, r.error);
    }
  }
  const sentIds = recipientIds.filter((u) => okUsers.has(u)).map((u) => logIdByUser.get(u)).filter(Boolean);
  const failedIds = recipientIds.filter((u) => !okUsers.has(u)).map((u) => logIdByUser.get(u)).filter(Boolean);
  if (sentIds.length) await admin.from("notifications_log").update({ status: "sent" }).in("id", sentIds);
  if (failedIds.length) {
    await admin.from("notifications_log").update({ status: "failed", error: [...failed.values()][0] ?? null }).in("id", failedIds);
  }
  if (invalidIds.length > 0) await admin.from("device_tokens").delete().in("id", invalidIds);

  const rows = { sent: sentIds.length, failed: failedIds.length };
  return json({ sent: rows.sent, failed: rows.failed, invalidated: invalidIds.length, recipients: allowed.size });
});
