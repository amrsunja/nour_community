// =============================================================================
// notify-mosque-followers Edge Function (P2)
// -----------------------------------------------------------------------------
// Admin-triggered broadcast to all followers of a mosque.
//   { mosqueId, postId? , campaignId?, title?, body? }
// * caller must be an admin of the (approved) mosque
// * server-side quota: app_config.mosque_broadcasts_per_week (default 2) per
//   rolling 7 days — HTTP 429 { error: 'quota_exceeded', nextAllowedAt }
// * builds the deep link + kind from the post / campaign, calls send-push,
//   records mosque_notification_quota, stamps mosque_posts.notified_at.
// =============================================================================

import { serviceClient, userClient } from "../_shared/supabase.ts";
import { json } from "../_shared/stripe.ts";
import { callInternal } from "../_shared/internal.ts";

interface Payload {
  mosqueId: number;
  postId?: number;
  campaignId?: number;
  title?: string;
  body?: string;
}

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
  if (!Number.isInteger(payload.mosqueId)) return json({ error: "bad_request" }, 400);

  // Authorization + quota (both RPCs check is_mosque_admin with the caller's JWT).
  const { data: quota, error: qErr } = await user.rpc("fn_mosque_broadcast_quota", { p_mosque_id: payload.mosqueId });
  if (qErr) return json({ error: "forbidden", detail: qErr.message }, 403);
  if ((quota?.remaining ?? 0) <= 0) {
    return json({ error: "quota_exceeded", nextAllowedAt: quota?.next_allowed_at ?? null, quota }, 429);
  }

  const admin = serviceClient();
  const { data: mosque } = await admin.from("mosques").select("id, name, status").eq("id", payload.mosqueId).single();
  if (!mosque || mosque.status !== "approved") return json({ error: "mosque_not_approved" }, 403);

  let kind = "mosque_broadcast";
  let title = payload.title ?? mosque.name;
  let body = payload.body ?? "";
  let link = `nour://mosque/${mosque.id}`;
  let imageUrl: string | undefined;

  if (payload.postId) {
    const { data: post } = await admin
      .from("mosque_posts")
      .select("id, mosque_id, type, title, body, cover_url, is_urgent, status")
      .eq("id", payload.postId)
      .single();
    if (!post || post.mosque_id !== mosque.id) return json({ error: "post_not_found" }, 404);
    if (post.status !== "published") return json({ error: "post_not_published" }, 400);
    kind = post.type === "event" || post.type === "janaza" || post.type === "volunteering" ? "mosque_event" : "mosque_post";
    title = `${post.is_urgent ? "🔴 " : ""}${mosque.name}`;
    body = payload.body ?? post.title;
    link = `nour://mosque/${mosque.id}/post/${post.id}`;
    imageUrl = post.cover_url ?? undefined;
  } else if (payload.campaignId) {
    const { data: c } = await admin
      .from("mosque_campaigns")
      .select("id, mosque_id, title, cover_url, status")
      .eq("id", payload.campaignId)
      .single();
    if (!c || c.mosque_id !== mosque.id) return json({ error: "campaign_not_found" }, 404);
    kind = "mosque_campaign";
    title = mosque.name;
    body = payload.body ?? c.title;
    link = `nour://mosque/${mosque.id}/campaign/${c.id}`;
    imageUrl = c.cover_url ?? undefined;
  } else if (!payload.body) {
    return json({ error: "bad_request", detail: "body required for free broadcast" }, 400);
  }

  const res = await callInternal("send-push", {
    kind,
    title,
    body,
    data: { link },
    segment: { mosqueId: mosque.id },
    collapseKey: payload.postId ? `post-${payload.postId}` : payload.campaignId ? `campaign-${payload.campaignId}` : undefined,
    imageUrl,
    mosqueId: mosque.id,
    postId: payload.postId ?? null,
    campaignId: payload.campaignId ?? null,
  });
  const result = await res.json().catch(() => ({}));
  if (!res.ok) return json({ error: "push_failed", detail: result }, 502);

  await admin.from("mosque_notification_quota").insert({
    mosque_id: mosque.id,
    post_id: payload.postId ?? null,
    campaign_id: payload.campaignId ?? null,
    recipients: result.recipients ?? 0,
  });
  if (payload.postId) {
    await admin.from("mosque_posts").update({ notified_at: new Date().toISOString() }).eq("id", payload.postId);
  }

  return json({ ...result, quota: { ...quota, used: (quota?.used ?? 0) + 1, remaining: (quota?.remaining ?? 1) - 1 } });
});
