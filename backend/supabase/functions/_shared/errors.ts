import { corsHeaders } from "./cors.ts";

// Mirrors the `errorKey` enum in the README — keep keys snake_case.
export type ErrorKey =
  | "unauthorized"
  | "forbidden"
  | "invalid_payload"
  | "profile_not_found"
  | "user_level_required"
  | "no_questions_available"
  | "already_played"
  | "internal_error";

export interface ApiError {
  key: ErrorKey;
  message: string;
}

export function errorResponse(
  key: ErrorKey,
  message: string,
  status = 400,
): Response {
  const body: ApiError = { key, message };
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

export function jsonResponse(payload: unknown, status = 200): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
