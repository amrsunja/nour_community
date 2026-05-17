// =============================================================================
// submitQuiz Edge Function
// -----------------------------------------------------------------------------
// Payload:
//   {
//     answers: [
//       { question_id: number, selected_option_index: number }
//     ]
//   }
// Returns:
//   {
//     correct_count: number,
//     total: number,
//     earned_ajr: number,
//     bonus_awarded: boolean,
//     details: [{ question_id, correct_option_index, was_correct }]
//   }
// Server-side scoring (clients never have correct_option_index).
// =============================================================================

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders } from "../_shared/cors.ts";
import { errorResponse, jsonResponse } from "../_shared/errors.ts";
import { serviceClient, userClient } from "../_shared/supabase.ts";

interface SubmitPayload {
  answers: Array<{ question_id: number; selected_option_index: number }>;
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return errorResponse("invalid_payload", "POST required", 405);
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return errorResponse("unauthorized", "Missing Authorization header", 401);
    }

    const userSb = userClient(authHeader);
    const { data: userRes, error: userErr } = await userSb.auth.getUser();
    if (userErr || !userRes?.user) {
      return errorResponse("unauthorized", "Invalid session", 401);
    }
    const userId = userRes.user.id;

    let payload: SubmitPayload;
    try {
      payload = (await req.json()) as SubmitPayload;
    } catch {
      return errorResponse("invalid_payload", "Body must be valid JSON", 400);
    }
    if (
      !payload ||
      !Array.isArray(payload.answers) ||
      payload.answers.length === 0
    ) {
      return errorResponse("invalid_payload", "Missing answers", 400);
    }

    const sb = serviceClient();
    const today = new Date().toISOString().slice(0, 10);

    // Block double-play same day
    const { data: existingPlay } = await sb
      .from("quiz_plays")
      .select("id")
      .eq("user_id", userId)
      .eq("play_date", today)
      .maybeSingle();
    if (existingPlay) {
      return errorResponse("already_played", "Already played today", 409);
    }

    // Fetch authoritative questions
    const ids = payload.answers.map((a) => a.question_id);
    const { data: questions, error: qErr } = await sb
      .from("quiz_questions")
      .select("id, correct_option_index, ajr, bonus_ajr")
      .in("id", ids);

    if (qErr) {
      return errorResponse("internal_error", qErr.message, 500);
    }

    const qMap = new Map<number, { correct_option_index: number; ajr: number; bonus_ajr: number | null }>();
    for (const q of questions ?? []) qMap.set(q.id, q);

    let correctCount = 0;
    let earnedAjr = 0;
    const details: Array<{
      question_id: number;
      correct_option_index: number;
      was_correct: boolean;
    }> = [];

    for (const a of payload.answers) {
      const q = qMap.get(a.question_id);
      if (!q) continue;
      const ok = q.correct_option_index === a.selected_option_index;
      if (ok) {
        correctCount += 1;
        earnedAjr += q.ajr;
      }
      details.push({
        question_id: a.question_id,
        correct_option_index: q.correct_option_index,
        was_correct: ok,
      });
    }

    const total = payload.answers.length;
    const bonusAwarded = correctCount === total && total > 0;
    if (bonusAwarded) {
      // Use the highest bonus_ajr among answered questions (typically 4th/challenge)
      const maxBonus = Math.max(
        0,
        ...payload.answers
          .map((a) => qMap.get(a.question_id)?.bonus_ajr ?? 0),
      );
      earnedAjr += maxBonus;
    }

    // Persist quiz_plays
    await sb.from("quiz_plays").insert({
      user_id: userId,
      play_date: today,
      question_ids: ids,
      correct_count: correctCount,
      total_count: total,
      earned_ajr: earnedAjr,
      bonus_awarded: bonusAwarded,
    });

    // Award ajr through ajr_log (service role -> trigger updates profile counter)
    if (earnedAjr > 0) {
      await sb.from("ajr_log").insert({
        user_id: userId,
        earned_ajr: earnedAjr,
        source: bonusAwarded ? "quiz_bonus" : "quiz",
      });
    }

    // Quiz counts as a "quick action" for the streak
    await sb.rpc("fn_mark_daily_activity", {
      p_user_id: userId,
      p_mark: "quick_action",
    });

    return jsonResponse({
      correct_count: correctCount,
      total,
      earned_ajr: earnedAjr,
      bonus_awarded: bonusAwarded,
      details,
    });
  } catch (err) {
    console.error("[submitQuiz]", err);
    return errorResponse("internal_error", String(err), 500);
  }
});
