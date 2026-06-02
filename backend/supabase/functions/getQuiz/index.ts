// =============================================================================
// getQuiz Edge Function
// -----------------------------------------------------------------------------
// Returns 4 quiz questions filtered by the caller's level.
//   - Q1..Q3 : level <= user.level
//   - Q4     : level > user.level (challenge); if none exists, fall back to
//              another level <= user.level question
// If the user already played today (row in quiz_plays for today), returns
// { quizs: [], already_played: true } per README spec.
// =============================================================================

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders } from "../_shared/cors.ts";
import { errorResponse, jsonResponse } from "../_shared/errors.ts";
import { serviceClient, userClient } from "../_shared/supabase.ts";

type LevelType = "begining" | "growing" | "established" | "returning";

const LEVEL_ORDER: Record<LevelType, number> = {
  begining: 0,
  growing: 1,
  established: 2,
  returning: 3,
};

const LEVELS: LevelType[] = ["begining", "growing", "established", "returning"];

// Max quiz plays allowed per user per day.
const MAX_DAILY_PLAYS = 2;

function eligibleLevels(userLevel: LevelType): LevelType[] {
  const max = LEVEL_ORDER[userLevel];
  return LEVELS.filter((l) => LEVEL_ORDER[l] <= max);
}

function nextLevel(userLevel: LevelType): LevelType | null {
  const idx = LEVEL_ORDER[userLevel];
  return idx < 3 ? LEVELS[idx + 1] : null;
}

function shuffle<T>(arr: T[]): T[] {
  const a = [...arr];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

// NOTE: correct_option_index is intentionally returned to the client so the
// quiz UI can give instant per-question feedback (correct/wrong highlight +
// toast) the moment the user validates. submitQuiz remains the authoritative
// source for scoring, ajr and streak — the client value is presentation only.

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return errorResponse("unauthorized", "Missing Authorization header", 401);
    }

    // 1. Resolve caller from JWT
    const userSb = userClient(authHeader);
    const { data: userRes, error: userErr } = await userSb.auth.getUser();
    if (userErr || !userRes?.user) {
      return errorResponse("unauthorized", "Invalid session", 401);
    }
    const userId = userRes.user.id;

    // 2. Read profile (service role to bypass RLS edge cases)
    const sb = serviceClient();
    const { data: profile, error: profileErr } = await sb
      .from("profiles")
      .select("id, level")
      .eq("id", userId)
      .single();

    if (profileErr || !profile) {
      return errorResponse("profile_not_found", "Profile not found", 404);
    }
    if (!profile.level) {
      return errorResponse(
        "user_level_required",
        "User must finish onboarding (level not set)",
        400,
      );
    }
    const userLevel = profile.level as LevelType;

    // 3. Reached daily play limit? (max MAX_DAILY_PLAYS rows per day)
    const today = new Date().toISOString().slice(0, 10);
    const { count: playsToday } = await sb
      .from("quiz_plays")
      .select("id", { count: "exact", head: true })
      .eq("user_id", userId)
      .eq("play_date", today);

    const playsCount = playsToday ?? 0;
    if (playsCount >= MAX_DAILY_PLAYS) {
      return jsonResponse({
        quizs: [],
        already_played: true,
        plays_today: playsCount,
        plays_remaining: 0,
      });
    }

    // 4. Fetch eligible questions
    const eligibles = eligibleLevels(userLevel);
    const { data: pool, error: poolErr } = await sb
      .from("quiz_questions")
      .select("*")
      .eq("is_active", true)
      .in("level", eligibles);

    if (poolErr) {
      return errorResponse("internal_error", poolErr.message, 500);
    }
    if (!pool || pool.length === 0) {
      return errorResponse(
        "no_questions_available",
        "No quiz questions available for your level",
        404,
      );
    }

    // 5. Pick 4 random questions at-or-below level
    const picks = shuffle(pool).slice(0, 4);

    // 6. Pick the 4th: one level higher if available
    const challengeLevel = nextLevel(userLevel);
    let challenge: Record<string, unknown> | null = null;

    if (challengeLevel) {
      const { data: challengePool } = await sb
        .from("quiz_questions")
        .select("*")
        .eq("is_active", true)
        .eq("level", challengeLevel);
      if (challengePool && challengePool.length > 0) {
        challenge = shuffle(challengePool)[0];
      }
    }

    if (!challenge) {
      // Fallback: another at-or-below question that isn't already picked
      const usedIds = new Set(picks.map((p) => p.id));
      const fallback = shuffle(pool).find((p) => !usedIds.has(p.id));
      if (fallback) challenge = fallback;
    }

    const quizs = challenge ? [...picks, challenge] : picks;

    return jsonResponse({
      quizs,
      already_played: false,
      plays_today: playsCount,
      plays_remaining: MAX_DAILY_PLAYS - playsCount,
    });
  } catch (err) {
    console.error("[getQuiz]", err);
    return errorResponse("internal_error", String(err), 500);
  }
});
