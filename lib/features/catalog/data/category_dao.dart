import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_manager.dart';
import '../../../core/database/database_schema.dart';
import '../../../core/models/category.dart';

/// DAO (Data Access Object) pour les opérations sur la table CATEGORIE
/// 
/// Encapsule toutes les requêtes SQL relatives aux catégories
class CategoryDao {
  final DatabaseManager _dbManager = DatabaseManager();

  /// Crée une nouvelle catégorie dans la base de données
  /// 
  /// Retourne l'ID de la catégorie créée
  Future<int> createCategory(Category category) async {
    final Database db = await _dbManager.database;
    final int id = await db.insert(
      DatabaseSchema.tableCategorie,
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
    return id;
  }

  /// Récupère toutes les catégories
  /// 
  /// Optionnellement triées par date de création (plus récentes en premier)
  Future<List<Category>> getAllCategories({bool orderByDate = true}) async {
    final Database db = await _dbManager.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseSchema.tableCategorie,
      orderBy: orderByDate ? 'date_creation DESC' : 'nom ASC',
    );

    return maps.map((map) => Category.fromMap(map)).toList();
  }

  /// Récupère une catégorie par son ID
  /// 
  /// Retourne null si aucune catégorie trouvée
  Future<Category?> getCategoryById(int id) async {
    final Database db = await _dbManager.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseSchema.tableCategorie,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Category.fromMap(maps.first);
  }

  /// Vérifie si une catégorie existe
  Future<bool> categoryExists(int id) async {
    final Category? category = await getCategoryById(id);
    return category != null;
  }

  /// Met à jour une catégorie existante
  Future<int> updateCategory(Category category) async {
    if (category.id == null) {
      throw Exception('Impossible de mettre à jour une catégorie sans ID');
    }

    final Database db = await _dbManager.database;
    return await db.update(
      DatabaseSchema.tableCategorie,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// Supprime une catégorie par son ID
  /// 
  /// Note: Les CASCADE delete supprimeront aussi les leçons associées
  Future<int> deleteCategory(int id) async {
    final Database db = await _dbManager.database;
    return await db.delete(
      DatabaseSchema.tableCategorie,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Compte le nombre de catégories dans la base
  Future<int> countCategories() async {
    final Database db = await _dbManager.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseSchema.tableCategorie}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
