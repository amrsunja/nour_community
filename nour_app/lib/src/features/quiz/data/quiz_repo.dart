import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/failures/failures.dart';
import 'package:nour/src/core/utils/typedefs.dart';

import 'datasources/quiz_remote_datasource.dart';
import 'models/quiz_result_model.dart';

final quizRepoProvider = Provider(
  (ref) => QuizRepo(remoteDatasource: ref.read(quizRemoteDataProvider)),
);

class QuizRepo {
  final QuizRemoteDatasource remoteDatasource;

  QuizRepo({required this.remoteDatasource});

  Future<SuccessOrError<QuizBundle>> getQuiz() async {
    return await Failure.exceptionsCatcher(() async {
      return await remoteDatasource.getQuiz();
    });
  }

  Future<SuccessOrError<QuizResultModel>> submitQuiz(
    Map<int, int> answers,
  ) async {
    return await Failure.exceptionsCatcher(() async {
      return await remoteDatasource.submitQuiz(answers);
    });
  }
}
