import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_manager.dart';
import '../../../core/database/database_schema.dart';
import '../../../core/models/answer.dart';

/// DAO (Data Access Object) pour les opérations sur la table REPONSE
/// 
/// Encapsule toutes les requêtes SQL relatives aux réponses
class AnswerDao {
  final DatabaseManager _dbManager = DatabaseManager();

  /// Crée une nouvelle réponse dans la base de données
  /// 
  /// Retourne l'ID de la réponse créée
  Future<int> createAnswer(Answer answer) async {
    final Database db = await _dbManager.database;
    final int id = await db.insert(
      DatabaseSchema.tableReponse,
      answer.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
    return id;
  }

  /// Récupère toutes les réponses d'une question
  /// 
  /// Triées par ordre d'affichage (ordre ASC)
  Future<List<Answer>> getAnswersByQuestionId(int questionId) async {
    final Database db = await _dbManager.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseSchema.tableReponse,
      where: 'question_id = ?',
      whereArgs: [questionId],
      orderBy: 'ordre ASC',
    );

    return maps.map((map) => Answer.fromMap(map)).toList();
  }

  /// Récupère une réponse par son ID
  /// 
  /// Retourne null si aucune réponse trouvée
  Future<Answer?> getAnswerById(int id) async {
    final Database db = await _dbManager.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseSchema.tableReponse,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Answer.fromMap(maps.first);
  }
}
