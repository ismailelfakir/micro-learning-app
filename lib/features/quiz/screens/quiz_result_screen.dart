import 'package:flutter/material.dart';
import '../services/quiz_service.dart';
import '../../../core/models/quiz.dart';

/// Écran affichant le résultat du quiz
/// 
/// Affiche le score (score / total) et un message de feedback
class QuizResultScreen extends StatelessWidget {
  final Quiz quiz;
  final ScoreResult scoreResult;
  final String lessonTitle;

  const QuizResultScreen({
    super.key,
    required this.quiz,
    required this.scoreResult,
    required this.lessonTitle,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPerfectScore = scoreResult.score == scoreResult.total;
    final bool isGoodScore = scoreResult.percentage >= 70.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultat du quiz'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // Icône de résultat
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPerfectScore
                    ? Colors.green.withOpacity(0.2)
                    : isGoodScore
                        ? Colors.blue.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.2),
              ),
              child: Icon(
                isPerfectScore
                    ? Icons.check_circle
                    : isGoodScore
                        ? Icons.sentiment_satisfied
                        : Icons.sentiment_neutral,
                size: 80,
                color: isPerfectScore
                    ? Colors.green
                    : isGoodScore
                        ? Colors.blue
                        : Colors.orange,
              ),
            ),

            const SizedBox(height: 32),

            // Titre du quiz
            Text(
              quiz.titre,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              lessonTitle,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // Score
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Text(
                      'Votre score',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${scoreResult.score} / ${scoreResult.total}',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${scoreResult.percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Message de feedback
            _buildFeedbackMessage(isPerfectScore, isGoodScore, scoreResult),

            const SizedBox(height: 40),

            // Bouton Retour
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Retourner à l'écran précédent (probablement LessonDetailScreen)
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Retour à la leçon',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackMessage(bool isPerfect, bool isGood, ScoreResult result) {
    String message;
    Color messageColor;

    if (isPerfect) {
      message = 'Excellent ! Vous avez répondu correctement à toutes les questions.';
      messageColor = Colors.green;
    } else if (isGood) {
      message = 'Bien joué ! Vous avez une bonne compréhension du sujet.';
      messageColor = Colors.blue;
    } else {
      message = 'Continuez à étudier pour améliorer votre score.';
      messageColor = Colors.orange;
    }

    return Card(
      color: messageColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isPerfect
                  ? Icons.emoji_events
                  : isGood
                      ? Icons.thumb_up
                      : Icons.school,
              color: messageColor,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: messageColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
