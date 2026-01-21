import '../../../core/models/quiz.dart';
import '../../../core/models/question.dart';
import '../../../core/models/answer.dart';
import '../data/quiz_dao.dart';
import '../data/question_dao.dart';
import '../data/answer_dao.dart';

/// Service métier pour les quiz
/// 
/// Encapsule la logique métier liée aux quiz, questions et réponses
class QuizService {
  final QuizDao _quizDao = QuizDao();
  final QuestionDao _questionDao = QuestionDao();
  final AnswerDao _answerDao = AnswerDao();

  /// Récupère un quiz avec toutes ses questions et réponses
  /// 
  /// Retourne null si aucun quiz trouvé pour la leçon
  Future<QuizWithContent?> getQuizWithContentByLeconId(int leconId) async {
    final Quiz? quiz = await _quizDao.getQuizByLeconId(leconId);
    if (quiz == null) {
      return null;
    }

    final List<Question> questions = await _questionDao.getQuestionsByQuizId(quiz.id!);
    
    // Charger les réponses pour chaque question
    final List<QuestionWithAnswers> questionsWithAnswers = [];
    for (final Question question in questions) {
      final List<Answer> answers = await _answerDao.getAnswersByQuestionId(question.id!);
      questionsWithAnswers.add(QuestionWithAnswers(question: question, answers: answers));
    }

    return QuizWithContent(quiz: quiz, questions: questionsWithAnswers);
  }

  /// Calcule le score d'un quiz
  /// 
  /// userAnswers: Map<questionId, answerId> - Réponses de l'utilisateur
  /// Retourne un ScoreResult avec le score et le total
  Future<ScoreResult> calculateScore({
    required Quiz quiz,
    required List<QuestionWithAnswers> questions,
    required Map<int, int> userAnswers, // questionId -> answerId
  }) async {
    int correctAnswers = 0;
    final int totalQuestions = questions.length;

    for (final QuestionWithAnswers qwa in questions) {
      final int? selectedAnswerId = userAnswers[qwa.question.id];
      
      if (selectedAnswerId != null) {
        // Trouver la réponse sélectionnée (non null grâce à orElse qui lance une exception)
        final Answer selectedAnswer = qwa.answers.firstWhere(
          (answer) => answer.id == selectedAnswerId,
          orElse: () => throw Exception('Réponse introuvable'),
        );

        // Vérifier si la réponse est correcte
        if (selectedAnswer.estCorrecte) {
          correctAnswers++;
        }
      }
    }

    // Calculer le score en pourcentage
    final double scorePercentage = totalQuestions > 0
        ? (correctAnswers / totalQuestions) * 100.0
        : 0.0;

    return ScoreResult(
      score: correctAnswers,
      total: totalQuestions,
      percentage: scorePercentage,
    );
  }
}

/// Structure pour représenter un quiz avec ses questions et réponses
class QuizWithContent {
  final Quiz quiz;
  final List<QuestionWithAnswers> questions;

  QuizWithContent({
    required this.quiz,
    required this.questions,
  });
}

/// Structure pour représenter une question avec ses réponses
class QuestionWithAnswers {
  final Question question;
  final List<Answer> answers;

  QuestionWithAnswers({
    required this.question,
    required this.answers,
  });
}

/// Résultat du calcul de score
class ScoreResult {
  final int score;
  final int total;
  final double percentage;

  ScoreResult({
    required this.score,
    required this.total,
    required this.percentage,
  });
}
