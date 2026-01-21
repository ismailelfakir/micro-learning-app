import 'package:sqflite/sqflite.dart';
import 'database_manager.dart';

/// Helper pour visualiser et déboguer la base de données
/// 
/// Fournit des méthodes pour afficher le contenu des tables
class DatabaseDebugHelper {
  final DatabaseManager _dbManager = DatabaseManager();

  /// Affiche toutes les données d'une table
  Future<List<Map<String, dynamic>>> getTableData(String tableName) async {
    final Database db = await _dbManager.database;
    return await db.query(tableName);
  }

  /// Compte le nombre de lignes dans une table
  Future<int> countRows(String tableName) async {
    final Database db = await _dbManager.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName',
    );
    return result.first['count'] as int;
  }

  /// Récupère toutes les tables de la base de données
  Future<List<String>> getAllTables() async {
    final Database db = await _dbManager.database;
    final List<Map<String, dynamic>> tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
    );
    return tables.map((table) => table['name'] as String).toList();
  }

  /// Obtient des statistiques sur toutes les tables
  Future<Map<String, int>> getTablesStats() async {
    final List<String> tables = await getAllTables();
    final Map<String, int> stats = {};
    
    for (final String table in tables) {
      stats[table] = await countRows(table);
    }
    
    return stats;
  }

  /// Exécute une requête SQL personnalisée (lecture seule)
  Future<List<Map<String, dynamic>>> executeQuery(String query) async {
    final Database db = await _dbManager.database;
    return await db.rawQuery(query);
  }

  /// Récupère la structure d'une table
  Future<List<Map<String, dynamic>>> getTableSchema(String tableName) async {
    final Database db = await _dbManager.database;
    return await db.rawQuery('PRAGMA table_info($tableName)');
  }

  /// Affiche les utilisateurs avec leurs statistiques
  Future<List<Map<String, dynamic>>> getUsersWithStats() async {
    final Database db = await _dbManager.database;
    return await db.rawQuery('''
      SELECT 
        u.id,
        u.nom,
        u.email,
        u.date_creation,
        COUNT(DISTINCT t.id) as nb_telechargements,
        COUNT(DISTINCT r.id) as nb_quiz_completes
      FROM UTILISATEUR u
      LEFT JOIN TELECHARGEMENT t ON u.id = t.utilisateur_id
      LEFT JOIN RESULTAT_QUIZ r ON u.id = r.utilisateur_id
      GROUP BY u.id
    ''');
  }

  /// Affiche les catégories avec le nombre de leçons
  Future<List<Map<String, dynamic>>> getCategoriesWithLessonCount() async {
    final Database db = await _dbManager.database;
    return await db.rawQuery('''
      SELECT 
        c.id,
        c.nom,
        c.description,
        COUNT(l.id) as nb_lecons
      FROM CATEGORIE c
      LEFT JOIN LECON l ON c.id = l.categorie_id
      GROUP BY c.id
    ''');
  }

  /// Affiche les leçons avec leurs informations complètes
  Future<List<Map<String, dynamic>>> getLessonsWithDetails() async {
    final Database db = await _dbManager.database;
    return await db.rawQuery('''
      SELECT 
        l.id,
        l.titre,
        l.contenu_type,
        l.duree_estimee,
        c.nom as categorie,
        COUNT(DISTINCT t.id) as nb_telechargements,
        CASE WHEN q.id IS NOT NULL THEN 'Oui' ELSE 'Non' END as a_quiz
      FROM LECON l
      LEFT JOIN CATEGORIE c ON l.categorie_id = c.id
      LEFT JOIN TELECHARGEMENT t ON l.id = t.lecon_id
      LEFT JOIN QUIZ q ON l.id = q.lecon_id
      GROUP BY l.id
    ''');
  }

  /// Affiche les quiz avec le nombre de questions
  Future<List<Map<String, dynamic>>> getQuizzesWithQuestionCount() async {
    final Database db = await _dbManager.database;
    return await db.rawQuery('''
      SELECT 
        q.id,
        q.titre,
        l.titre as lecon,
        COUNT(qu.id) as nb_questions
      FROM QUIZ q
      LEFT JOIN LECON l ON q.lecon_id = l.id
      LEFT JOIN QUESTION qu ON q.id = qu.quiz_id
      GROUP BY q.id
    ''');
  }

  /// Vide complètement la base de données (ATTENTION: destructif!)
  Future<void> clearAllData() async {
    final Database db = await _dbManager.database;
    
    // Désactiver temporairement les foreign keys
    await db.execute('PRAGMA foreign_keys = OFF');
    
    // Supprimer toutes les données (dans l'ordre inverse des dépendances)
    final List<String> tables = [
      'RESULTAT_QUIZ',
      'REPONSE',
      'QUESTION',
      'QUIZ',
      'TELECHARGEMENT',
      'LECON',
      'CATEGORIE',
      'UTILISATEUR',
    ];
    
    for (final String table in tables) {
      await db.delete(table);
    }
    
    // Réactiver les foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Exporte toutes les données en format texte lisible
  Future<String> exportAllData() async {
    final StringBuffer buffer = StringBuffer();
    final List<String> tables = await getAllTables();
    
    buffer.writeln('=== EXPORT BASE DE DONNÉES ===\n');
    buffer.writeln('Date: ${DateTime.now()}\n');
    
    for (final String table in tables) {
      final int count = await countRows(table);
      buffer.writeln('--- TABLE: $table ($count lignes) ---');
      
      if (count > 0) {
        final List<Map<String, dynamic>> data = await getTableData(table);
        for (final Map<String, dynamic> row in data) {
          buffer.writeln(row.toString());
        }
      } else {
        buffer.writeln('(vide)');
      }
      
      buffer.writeln('');
    }
    
    return buffer.toString();
  }
}
