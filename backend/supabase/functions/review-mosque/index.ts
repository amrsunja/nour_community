// =============================================================================
// review-mosque Edge Function (P2 — Nour admin moderation)
// -----------------------------------------------------------------------------
//   { mosqueId, action: 'approve' | 'reject' | 'suspend', note? }
// Caller must be a Nour admin (profiles.is_admin). Updates the status through
// fn_admin_review_mosque (trusted context) and pushes `mosque_status` to the
// owner. Email is optional (RESEND_API_KEY) — silently skipped when unset.
// =============================================================================

import { serviceClient, userClient } from "../_shared/supabase.ts";
import { json } from "../_shared/stripe.ts";
import { callInternal } from "../_shared/internal.ts";

interface Payload {
  mosqueId: number;
  action: "approve" | "reject" | "suspend";
  note?: string;
}

const STATUS: Record<Payload["action"], string> = {
  approve: "approved",
  reject: "rejected",
  suspend: "suspended",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok");
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return json({ error: "unauthorized" }, 401);
  const user = userClient(authHeader);
  const { data: { user: me } } = await user.auth.getUser();
  if (!me) return json({ error: "unauthorized" }, 401);

  let payload: Payload;
  try {
    payload = (await req.json()) as Payload;
  } catch {
    return json({ error: "bad_request" }, 400);
  }
  if (!Number.isInteger(payload.mosqueId) || !(payload.action in STATUS)) return json({ error: "bad_request" }, 400);

  // The RPC raises 'forbidden' for non-admins.
  const { error: rpcErr } = await user.rpc("fn_admin_review_mosque", {
    p_mosque_id: payload.mosqueId,
    p_status: STATUS[payload.action],
    p_note: payload.note ?? null,
  });
  if (rpcErr) return json({ error: "forbidden", detail: rpcErr.message }, 403);

  const admin = serviceClient();
  const { data: mosque } = await admin.from("mosques").select("id, name").eq("id", payload.mosqueId).single();
  const { data: owners } = await admin
    .from("mosque_admins")
    .select("user_id")
    .eq("mosque_id", payload.mosqueId);
  const userIds = (owners ?? []).map((o) => o.user_id as string);

  const titles: Record<Payload["action"], string> = {
    approve: `${mosque?.name ?? "Your mosque"} is approved 🎉`,
    reject: `${mosque?.name ?? "Your mosque"}: registration refused`,
    suspend: `${mosque?.name ?? "Your mosque"} has been suspended`,
  };
  const bodies: Record<Payload["action"], string> = {
    approve: "Your mosque is live on Nour. Open the app to set up your profile and prayer times.",
    reject: payload.note ?? "Please contact support for more information.",
    suspend: payload.note ?? "Please contact support for more information.",
  };

  if (userIds.length > 0) {
    await callInternal("send-push", {
      kind: "mosque_status",
      title: titles[payload.action],
      body: bodies[payload.action],
      data: { link: "nour://mosque-admin" },
      userIds,
      mosqueId: payload.mosqueId,
    }).catch((e) => console.error("[review-mosque] push", e));

    const resendKey = Deno.env.get("RESEND_API_KEY");
    const from = Deno.env.get("NOTIFICATIONS_FROM_EMAIL");
    if (resendKey && from) {
      for (const uid of userIds) {
        const { data: u } = await admin.auth.admin.getUserById(uid);
        const email = u?.user?.email;
        if (!email) continue;
        await fetch("https://api.resend.com/emails", {
          method: "POST",
          headers: { Authorization: `Bearer ${resendKey}`, "Content-Type": "application/json" },
          body: JSON.stringify({ from, to: email, subject: titles[payload.action], text: bodies[payload.action] }),
        }).catch((e) => console.error("[review-mosque] email", e));
      }
    }
  }

  return json({ ok: true, status: STATUS[payload.action] });
});
