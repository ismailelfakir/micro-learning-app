import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_manager.dart';
import '../../../core/database/database_schema.dart';
import '../../../core/models/quiz.dart';

/// DAO (Data Access Object) pour les opérations sur la table QUIZ
/// 
/// Encapsule toutes les requêtes SQL relatives aux quiz
class QuizDao {
  final DatabaseManager _dbManager = DatabaseManager();

  /// Crée un nouveau quiz dans la base de données
  /// 
  /// Retourne l'ID du quiz créé
  Future<int> createQuiz(Quiz quiz) async {
    final Database db = await _dbManager.database;
    try {
      final int id = await db.insert(
        DatabaseSchema.tableQuiz,
        quiz.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
      return id;
    } on DatabaseException catch (e) {
      if (e.toString().contains('UNIQUE constraint failed')) {
        throw Exception('Un quiz existe déjà pour cette leçon');
      }
      rethrow;
    }
  }

  /// Récupère un quiz par son ID
  /// 
  /// Retourne null si aucun quiz trouvé
  Future<Quiz?> getQuizById(int id) async {
    final Database db = await _dbManager.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseSchema.tableQuiz,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Quiz.fromMap(maps.first);
  }

  /// Récupère un quiz par l'ID de la leçon
  /// 
  /// Retourne null si aucun quiz trouvé pour cette leçon
  /// Relation 1:1 entre Quiz et Leçon
  Future<Quiz?> getQuizByLeconId(int leconId) async {
    final Database db = await _dbManager.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseSchema.tableQuiz,
      where: 'lecon_id = ?',
      whereArgs: [leconId],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Quiz.fromMap(maps.first);
  }

  /// Supprime un quiz par l'ID de la leçon (cascade questions/réponses)
  Future<int> deleteQuizByLeconId(int leconId) async {
    final Database db = await _dbManager.database;
    return await db.delete(
      DatabaseSchema.tableQuiz,
      where: 'lecon_id = ?',
      whereArgs: [leconId],
    );
  }

  /// Compte le nombre de quiz dans la base
  Future<int> countQuizzes() async {
    final Database db = await _dbManager.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseSchema.tableQuiz}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
