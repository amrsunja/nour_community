// Calls another edge function of this project with the internal key
// (send-push is never exposed to the app).
export async function callInternal(name: string, payload: unknown): Promise<Response> {
  const base = Deno.env.get("SUPABASE_URL")!;
  const key = Deno.env.get("INTERNAL_FUNCTIONS_KEY") ?? "";
  return fetch(`${base}/functions/v1/${name}`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-internal-key": key,
      // Supabase gateway still expects an apikey header for functions.
      apikey: Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      Authorization: `Bearer ${Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""}`,
    },
    body: JSON.stringify(payload),
  });
}
