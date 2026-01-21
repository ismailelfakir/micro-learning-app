import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_manager.dart';
import '../../../core/database/database_schema.dart';
import '../../../core/models/lesson.dart';

/// DAO (Data Access Object) pour les opérations sur la table LECON
/// 
/// Encapsule toutes les requêtes SQL relatives aux leçons
class LessonDao {
  final DatabaseManager _dbManager = DatabaseManager();

  /// Crée une nouvelle leçon dans la base de données
  /// 
  /// Retourne l'ID de la leçon créée
  Future<int> createLesson(Lesson lesson) async {
    final Database db = await _dbManager.database;
    final int id = await db.insert(
      DatabaseSchema.tableLecon,
      lesson.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
    return id;
  }

  /// Récupère toutes les leçons d'une catégorie
  /// 
  /// Optionnellement triées par date de création
  Future<List<Lesson>> getLessonsByCategoryId(
    int categoryId, {
    bool orderByDate = true,
  }) async {
    final Database db = await _dbManager.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseSchema.tableLecon,
      where: 'categorie_id = ?',
      whereArgs: [categoryId],
      orderBy: orderByDate ? 'date_creation DESC' : 'titre ASC',
    );

    return maps.map((map) => Lesson.fromMap(map)).toList();
  }

  /// Récupère une leçon par son ID
  /// 
  /// Retourne null si aucune leçon trouvée
  Future<Lesson?> getLessonById(int id) async {
    final Database db = await _dbManager.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseSchema.tableLecon,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Lesson.fromMap(maps.first);
  }

  /// Récupère toutes les leçons
  /// 
  /// Utile pour des requêtes globales ou des statistiques
  Future<List<Lesson>> getAllLessons({bool orderByDate = true}) async {
    final Database db = await _dbManager.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseSchema.tableLecon,
      orderBy: orderByDate ? 'date_creation DESC' : 'titre ASC',
    );

    return maps.map((map) => Lesson.fromMap(map)).toList();
  }

  /// Met à jour une leçon existante
  Future<int> updateLesson(Lesson lesson) async {
    if (lesson.id == null) {
      throw Exception('Impossible de mettre à jour une leçon sans ID');
    }

    final Database db = await _dbManager.database;
    return await db.update(
      DatabaseSchema.tableLecon,
      lesson.toMap(),
      where: 'id = ?',
      whereArgs: [lesson.id],
    );
  }

  /// Supprime une leçon par son ID
  /// 
  /// Note: Les CASCADE delete supprimeront aussi les quiz et téléchargements associés
  Future<int> deleteLesson(int id) async {
    final Database db = await _dbManager.database;
    return await db.delete(
      DatabaseSchema.tableLecon,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Compte le nombre de leçons dans la base
  Future<int> countLessons() async {
    final Database db = await _dbManager.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseSchema.tableLecon}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Compte le nombre de leçons d'une catégorie
  Future<int> countLessonsByCategoryId(int categoryId) async {
    final Database db = await _dbManager.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseSchema.tableLecon} WHERE categorie_id = ?',
      [categoryId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
