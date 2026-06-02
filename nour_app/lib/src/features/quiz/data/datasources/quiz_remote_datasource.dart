import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/exceptions/server/server_exception.dart';
import 'package:nour/src/core/network/supabase_client.dart';
import 'package:nour/src/core/utils/talker/talker.dart';

import '../models/quiz_question_model.dart';
import '../models/quiz_result_model.dart';

final quizRemoteDataProvider = Provider((ref) => QuizRemoteDatasource());

/// Outcome of `getQuiz`: either today's questions, or a flag saying the user
/// already played (empty list).
typedef QuizBundle = ({List<QuizQuestionModel> questions, bool alreadyPlayed});

class QuizRemoteDatasource {
  static const _getQuizFn = 'getQuiz';
  static const _submitQuizFn = 'submitQuiz';

  /// Pulls today's quiz. The edge function tailors difficulty to the user's
  /// level and signals `already_played` when the daily attempt is spent.
  Future<QuizBundle> getQuiz() async {
    try {
      final res = await supabaseClient.functions.invoke(_getQuizFn);
      final data = res.data;

      if (data is! Map) {
        throw ServerException(
          type: .badRequest,
          message: 'Unexpected getQuiz response',
        );
      }

      final alreadyPlayed = data['already_played'] == true;
      final raw = (data['quizs'] as List?) ?? const [];
      final questions = raw
          .map((e) => QuizQuestionModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      return (questions: questions, alreadyPlayed: alreadyPlayed);
    } on ServerException {
      rethrow;
    } catch (e) {
      talker.error(e);
      throw ServerException(type: .badRequest, message: 'Failed to load quiz');
    }
  }

  /// Submits every answer in one shot. Server scores, awards ajr and marks the
  /// daily activity — returns the authoritative result.
  ///
  /// [answers] maps `questionId -> selectedOptionIndex` (1-based).
  Future<QuizResultModel> submitQuiz(Map<int, int> answers) async {
    try {
      final res = await supabaseClient.functions.invoke(
        _submitQuizFn,
        body: {
          'answers': answers.entries
              .map((e) => {
                    'question_id': e.key,
                    'selected_option_index': e.value,
                  })
              .toList(),
        },
      );

      final data = res.data;
      if (data is! Map) {
        throw ServerException(
          type: .badRequest,
          message: 'Unexpected submitQuiz response',
        );
      }

      return QuizResultModel.fromJson(Map<String, dynamic>.from(data));
    } on ServerException {
      rethrow;
    } catch (e) {
      talker.error(e);
      throw ServerException(type: .badRequest, message: 'Failed to submit quiz');
    }
  }
}
