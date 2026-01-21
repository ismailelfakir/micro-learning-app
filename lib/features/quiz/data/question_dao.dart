import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_manager.dart';
import '../../../core/database/database_schema.dart';
import '../../../core/models/question.dart';

/// DAO (Data Access Object) pour les opérations sur la table QUESTION
/// 
/// Encapsule toutes les requêtes SQL relatives aux questions
class QuestionDao {
  final DatabaseManager _dbManager = DatabaseManager();

  /// Crée une nouvelle question dans la base de données
  /// 
  /// Retourne l'ID de la question créée
  Future<int> createQuestion(Question question) async {
    final Database db = await _dbManager.database;
    final int id = await db.insert(
      DatabaseSchema.tableQuestion,
      question.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
    return id;
  }

  /// Récupère toutes les questions d'un quiz
  /// 
  /// Triées par ordre d'affichage (ordre ASC)
  Future<List<Question>> getQuestionsByQuizId(int quizId) async {
    final Database db = await _dbManager.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseSchema.tableQuestion,
      where: 'quiz_id = ?',
      whereArgs: [quizId],
      orderBy: 'ordre ASC',
    );

    return maps.map((map) => Question.fromMap(map)).toList();
  }

  /// Récupère une question par son ID
  /// 
  /// Retourne null si aucune question trouvée
  Future<Question?> getQuestionById(int id) async {
    final Database db = await _dbManager.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseSchema.tableQuestion,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Question.fromMap(maps.first);
  }
}
