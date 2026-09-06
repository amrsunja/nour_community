// =============================================================================
// Shared FCM (HTTP v1) helpers.
// -----------------------------------------------------------------------------
// * Service-account JWT → OAuth2 access token (cached ~50 min).
// * sendToToken(): one message per device token; returns { ok, invalid }.
// Secrets: FCM_SERVICE_ACCOUNT_JSON (the JSON key file of the Firebase
// service account, as ONE line), FCM_PROJECT_ID (optional — read from the key).
// =============================================================================

interface ServiceAccount {
  project_id: string;
  client_email: string;
  private_key: string;
}

let _sa: ServiceAccount | null = null;
let _token: { value: string; expiresAt: number } | null = null;

function serviceAccount(): ServiceAccount {
  if (_sa) return _sa;
  const raw = Deno.env.get("FCM_SERVICE_ACCOUNT_JSON");
  if (!raw) throw new Error("FCM_SERVICE_ACCOUNT_JSON is not set");
  _sa = JSON.parse(raw) as ServiceAccount;
  return _sa;
}

export function fcmProjectId(): string {
  return Deno.env.get("FCM_PROJECT_ID") ?? serviceAccount().project_id;
}

function b64url(data: ArrayBuffer | string): string {
  const bytes = typeof data === "string" ? new TextEncoder().encode(data) : new Uint8Array(data);
  let bin = "";
  for (const b of bytes) bin += String.fromCharCode(b);
  return btoa(bin).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

function pemToDer(pem: string): ArrayBuffer {
  const body = pem.replace(/-----[A-Z ]+-----/g, "").replace(/\s+/g, "");
  const bin = atob(body);
  const out = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);
  return out.buffer;
}

/** OAuth2 access token for https://www.googleapis.com/auth/firebase.messaging */
export async function fcmAccessToken(): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  if (_token && _token.expiresAt - 60 > now) return _token.value;

  const sa = serviceAccount();
  const header = b64url(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const claims = b64url(JSON.stringify({
    iss: sa.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  }));
  const key = await crypto.subtle.importKey(
    "pkcs8",
    pemToDer(sa.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = await crypto.subtle.sign("RSASSA-PKCS1-v1_5", key, new TextEncoder().encode(`${header}.${claims}`));
  const assertion = `${header}.${claims}.${b64url(sig)}`;

  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion,
    }),
  });
  if (!res.ok) throw new Error(`oauth token failed: ${res.status} ${await res.text()}`);
  const json = await res.json() as { access_token: string; expires_in: number };
  _token = { value: json.access_token, expiresAt: now + (json.expires_in ?? 3600) };
  return _token.value;
}

export interface PushMessage {
  title: string;
  body: string;
  data: Record<string, string>;
  collapseKey?: string;
  imageUrl?: string;
}

export type SendResult = { ok: true } | { ok: false; invalid: boolean; error: string };

/** Sends one notification to one device token via FCM HTTP v1. */
export async function sendToToken(token: string, msg: PushMessage): Promise<SendResult> {
  const accessToken = await fcmAccessToken();
  const projectId = fcmProjectId();
  const payload = {
    message: {
      token,
      notification: { title: msg.title, body: msg.body, ...(msg.imageUrl ? { image: msg.imageUrl } : {}) },
      data: msg.data,
      android: {
        priority: "HIGH",
        ...(msg.collapseKey ? { collapse_key: msg.collapseKey } : {}),
        notification: { channel_id: "nour_mosques", sound: "default" },
      },
      apns: {
        headers: { "apns-priority": "10", ...(msg.collapseKey ? { "apns-collapse-id": msg.collapseKey } : {}) },
        payload: { aps: { sound: "default", "mutable-content": 1 } },
      },
    },
  };
  const res = await fetch(`https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`, {
    method: "POST",
    headers: { Authorization: `Bearer ${accessToken}`, "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
  if (res.ok) return { ok: true };
  const text = await res.text();
  // UNREGISTERED / INVALID_ARGUMENT (bad token) → drop the token.
  const invalid = res.status === 404 || /UNREGISTERED|INVALID_ARGUMENT|registration-token-not-registered/i.test(text);
  return { ok: false, invalid, error: `${res.status} ${text.slice(0, 300)}` };
}

/** Runs `fn` over `items` with bounded concurrency. */
export async function mapConcurrent<T, R>(items: T[], limit: number, fn: (t: T) => Promise<R>): Promise<R[]> {
  const out: R[] = new Array(items.length);
  let i = 0;
  const workers = Array.from({ length: Math.min(limit, items.length) }, async () => {
    while (true) {
      const idx = i++;
      if (idx >= items.length) return;
      out[idx] = await fn(items[idx]);
    }
  });
  await Promise.all(workers);
  return out;
}
