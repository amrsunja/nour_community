import { createClient, SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

/** Service-role client — bypasses RLS. Use carefully inside edge functions. */
export function serviceClient(): SupabaseClient {
  return createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    { auth: { persistSession: false } },
  );
}

/**
 * Auth-scoped client — uses the caller's JWT. RLS applies.
 * Pass the incoming Authorization header.
 */
export function userClient(authHeader: string | null): SupabaseClient {
  return createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    {
      global: { headers: { Authorization: authHeader ?? "" } },
      auth: { persistSession: false },
    },
  );
}
