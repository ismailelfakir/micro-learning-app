import 'package:flutter/material.dart';
import '../services/quiz_service.dart';
import '../../../core/models/question.dart';
import '../../../core/models/answer.dart';
import 'quiz_result_screen.dart';

/// Écran de quiz affichant une question à la fois
/// 
/// UX: Une question à la fois, pas de retour en arrière, pas de timer
class QuizScreen extends StatefulWidget {
  final int leconId;
  final String lessonTitle;

  const QuizScreen({
    super.key,
    required this.leconId,
    required this.lessonTitle,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizService _quizService = QuizService();

  QuizWithContent? _quizContent;
  int _currentQuestionIndex = 0;
  int? _selectedAnswerId;
  bool _isLoading = true;
  Map<int, int> _userAnswers = {}; // questionId -> answerId

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  /// Charge le quiz avec ses questions et réponses
  Future<void> _loadQuiz() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final QuizWithContent? content =
          await _quizService.getQuizWithContentByLeconId(widget.leconId);

      if (mounted) {
        setState(() {
          _quizContent = content;
          _isLoading = false;
        });

        if (content == null || content.questions.isEmpty) {
          // Pas de quiz ou quiz vide
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Aucun quiz disponible pour cette leçon'),
                backgroundColor: Colors.red,
              ),
            );
            Navigator.of(context).pop();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Passe à la question suivante
  void _nextQuestion() {
    if (_quizContent == null) return;

    final Question currentQuestion = _quizContent!.questions[_currentQuestionIndex].question;

    // Sauvegarder la réponse sélectionnée
    if (_selectedAnswerId != null) {
      _userAnswers[currentQuestion.id!] = _selectedAnswerId!;
    }

    // Vérifier si c'est la dernière question
    if (_currentQuestionIndex < _quizContent!.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerId = _userAnswers[_quizContent!.questions[_currentQuestionIndex].question.id!];
      });
    } else {
      // Fin du quiz, calculer le score et naviguer vers le résultat
      _finishQuiz();
    }
  }

  /// Termine le quiz et calcule le score
  Future<void> _finishQuiz() async {
    if (_quizContent == null) return;

    // Sauvegarder la dernière réponse si sélectionnée
    final Question lastQuestion = _quizContent!.questions[_currentQuestionIndex].question;
    if (_selectedAnswerId != null) {
      _userAnswers[lastQuestion.id!] = _selectedAnswerId!;
    }

    // Calculer le score
    final ScoreResult scoreResult = await _quizService.calculateScore(
      quiz: _quizContent!.quiz,
      questions: _quizContent!.questions,
      userAnswers: _userAnswers,
    );

    // Naviguer vers l'écran de résultat
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => QuizResultScreen(
            quiz: _quizContent!.quiz,
            scoreResult: scoreResult,
            lessonTitle: widget.lessonTitle,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;
        
        // Empêcher la navigation en arrière pendant le quiz
        final bool? shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Quitter le quiz ?'),
            content: const Text(
              'Voulez-vous vraiment quitter le quiz ? Votre progression sera perdue.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Continuer'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Quitter'),
              ),
            ],
          ),
        );
        
        if (shouldPop == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_quizContent?.quiz.titre ?? 'Quiz'),
          automaticallyImplyLeading: false, // Pas de bouton retour
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _quizContent == null
                ? const Center(child: Text('Erreur de chargement'))
                : _buildQuizContent(),
      ),
    );
  }

  Widget _buildQuizContent() {
    final QuestionWithAnswers currentQwa =
        _quizContent!.questions[_currentQuestionIndex];
    final Question question = currentQwa.question;
    final List<Answer> answers = currentQwa.answers;
    final int totalQuestions = _quizContent!.questions.length;
    final int currentQuestionNumber = _currentQuestionIndex + 1;

    return Column(
      children: [
        // Indicateur de progression
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: currentQuestionNumber / totalQuestions,
                  backgroundColor: Colors.grey[300],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '$currentQuestionNumber / $totalQuestions',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Contenu de la question
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question
                Text(
                  question.texte,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),

                // Réponses (QCM)
                ...answers.map((answer) => _buildAnswerCard(answer)),
              ],
            ),
          ),
        ),

        // Bouton Suivant
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedAnswerId == null ? null : _nextQuestion,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                currentQuestionNumber < totalQuestions
                    ? 'Suivant'
                    : 'Terminer',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerCard(Answer answer) {
    final bool isSelected = _selectedAnswerId == answer.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      color: isSelected
          ? Theme.of(context).primaryColor.withOpacity(0.1)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedAnswerId = answer.id;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    width: 2,
                  ),
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  answer.texte,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
