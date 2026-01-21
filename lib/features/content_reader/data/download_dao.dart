import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_manager.dart';
import '../../../core/database/database_schema.dart';
import '../../../core/models/download.dart';

/// Data Access Object pour la table TELECHARGEMENT
/// 
/// Responsabilités:
/// - CRUD pour les téléchargements
/// - Vérification du statut de téléchargement
/// - Récupération des téléchargements par utilisateur ou leçon
class DownloadDao {
  final DatabaseManager _dbManager = DatabaseManager();

  /// Crée un nouveau téléchargement
  Future<int> createDownload(Download download) async {
    final Database db = await _dbManager.database;
    
    try {
      return await db.insert(
        DatabaseSchema.tableTelechargement,
        download.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Erreur lors de la création du téléchargement: $e');
    }
  }

  /// Récupère un téléchargement par utilisateur et leçon
  Future<Download?> getDownloadByUserAndLesson(int utilisateurId, int leconId) async {
    final Database db = await _dbManager.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseSchema.tableTelechargement,
      where: 'utilisateur_id = ? AND lecon_id = ?',
      whereArgs: [utilisateurId, leconId],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Download.fromMap(maps.first);
  }

  /// Récupère tous les téléchargements d'un utilisateur
  Future<List<Download>> getDownloadsByUser(int utilisateurId) async {
    final Database db = await _dbManager.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseSchema.tableTelechargement,
      where: 'utilisateur_id = ?',
      whereArgs: [utilisateurId],
      orderBy: 'date_telechargement DESC',
    );

    return maps.map((map) => Download.fromMap(map)).toList();
  }

  /// Récupère tous les téléchargements complétés d'un utilisateur
  Future<List<Download>> getCompletedDownloadsByUser(int utilisateurId) async {
    final Database db = await _dbManager.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseSchema.tableTelechargement,
      where: 'utilisateur_id = ? AND statut = ?',
      whereArgs: [utilisateurId, 'completed'],
      orderBy: 'date_telechargement DESC',
    );

    return maps.map((map) => Download.fromMap(map)).toList();
  }

  /// Met à jour un téléchargement
  Future<int> updateDownload(Download download) async {
    if (download.id == null) {
      throw Exception('Impossible de mettre à jour un téléchargement sans ID');
    }

    final Database db = await _dbManager.database;
    
    return await db.update(
      DatabaseSchema.tableTelechargement,
      download.toMap(),
      where: 'id = ?',
      whereArgs: [download.id],
    );
  }

  /// Supprime un téléchargement
  Future<int> deleteDownload(int id) async {
    final Database db = await _dbManager.database;
    
    return await db.delete(
      DatabaseSchema.tableTelechargement,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Supprime un téléchargement par utilisateur et leçon
  Future<int> deleteDownloadByUserAndLesson(int utilisateurId, int leconId) async {
    final Database db = await _dbManager.database;
    
    return await db.delete(
      DatabaseSchema.tableTelechargement,
      where: 'utilisateur_id = ? AND lecon_id = ?',
      whereArgs: [utilisateurId, leconId],
    );
  }

  /// Vérifie si une leçon est téléchargée par un utilisateur
  Future<bool> isLessonDownloaded(int utilisateurId, int leconId) async {
    final Download? download = await getDownloadByUserAndLesson(utilisateurId, leconId);
    return download != null && download.statut == 'completed';
  }

  /// Compte le nombre de téléchargements complétés d'un utilisateur
  Future<int> countCompletedDownloads(int utilisateurId) async {
    final Database db = await _dbManager.database;
    
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseSchema.tableTelechargement} WHERE utilisateur_id = ? AND statut = ?',
      [utilisateurId, 'completed'],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }
}
