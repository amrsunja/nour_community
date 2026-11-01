// =============================================================================
// review-mosque-donations Edge Function (App Store guideline 3.2.1(vi))
// -----------------------------------------------------------------------------
//   { mosqueId, action: 'approve' | 'cancel', note? }
// Caller must be a Nour admin (profiles.is_admin). Applies the decision through
// fn_admin_review_donation_verification and pushes `mosque_status` to the
// mosque's admins.
// =============================================================================

import { serviceClient, userClient } from "../_shared/supabase.ts";
import { json } from "../_shared/stripe.ts";
import { callInternal } from "../_shared/internal.ts";

interface Payload {
  mosqueId: number;
  action: "approve" | "cancel";
  note?: string;
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
  if (!Number.isInteger(payload.mosqueId) || !["approve", "cancel"].includes(payload.action)) {
    return json({ error: "bad_request" }, 400);
  }
  const approved = payload.action === "approve";

  // The RPC raises 'forbidden' for non-admins.
  const { error: rpcErr } = await user.rpc("fn_admin_review_donation_verification", {
    p_mosque_id: payload.mosqueId,
    p_approve: approved,
    p_note: payload.note ?? null,
  });
  if (rpcErr) return json({ error: "forbidden", detail: rpcErr.message }, 403);

  const admin = serviceClient();
  const { data: mosque } = await admin.from("mosques").select("name").eq("id", payload.mosqueId).single();
  const { data: admins } = await admin.from("mosque_admins").select("user_id").eq("mosque_id", payload.mosqueId);
  const userIds = (admins ?? []).map((a) => a.user_id as string);

  if (userIds.length > 0) {
    const name = mosque?.name ?? "Your mosque";
    await callInternal("send-push", {
      kind: "mosque_status",
      title: approved ? `${name}: donations approved` : `${name}: donation access not approved`,
      body: approved
        ? "Your verification is approved. Open the app to finish setting up donations."
        : payload.note || "Please contact support for more information.",
      data: { link: "nour://mosque-admin" },
      userIds,
      mosqueId: payload.mosqueId,
    }).catch((e) => console.error("[review-mosque-donations] push", e));
  }

  return json({ ok: true, status: approved ? "approved" : "rejected" });
});
