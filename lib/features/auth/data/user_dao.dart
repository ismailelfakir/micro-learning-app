import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_manager.dart';
import '../../../core/database/database_schema.dart';
import '../../../core/models/user.dart';

/// DAO (Data Access Object) pour les opérations sur la table UTILISATEUR
/// 
/// Encapsule toutes les requêtes SQL relatives aux utilisateurs
class UserDao {
  final DatabaseManager _dbManager = DatabaseManager();

  /// Crée un nouvel utilisateur dans la base de données
  /// 
  /// Retourne l'ID du nouvel utilisateur créé
  /// Lance une exception si l'email existe déjà (UNIQUE constraint)
  Future<int> createUser(User user) async {
    final Database db = await _dbManager.database;
    try {
      final int id = await db.insert(
        DatabaseSchema.tableUtilisateur,
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
      return id;
    } on DatabaseException catch (e) {
      // Vérifier si c'est une erreur de contrainte UNIQUE (email déjà utilisé)
      if (e.isUniqueConstraintError() ||
          e.toString().contains('UNIQUE constraint failed')) {
        throw Exception('Cet email est déjà utilisé');
      }
      rethrow;
    }
  }

  /// Récupère un utilisateur par son email
  /// 
  /// Retourne null si aucun utilisateur trouvé
  Future<User?> getUserByEmail(String email) async {
    final Database db = await _dbManager.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseSchema.tableUtilisateur,
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return User.fromMap(maps.first);
  }

  /// Récupère un utilisateur par son ID
  /// 
  /// Retourne null si aucun utilisateur trouvé
  Future<User?> getUserById(int id) async {
    final Database db = await _dbManager.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseSchema.tableUtilisateur,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return User.fromMap(maps.first);
  }

  /// Vérifie si un email existe déjà dans la base
  Future<bool> emailExists(String email) async {
    final User? user = await getUserByEmail(email);
    return user != null;
  }

  /// Met à jour un utilisateur existant
  Future<int> updateUser(User user) async {
    if (user.id == null) {
      throw Exception('Impossible de mettre à jour un utilisateur sans ID');
    }

    final Database db = await _dbManager.database;
    return await db.update(
      DatabaseSchema.tableUtilisateur,
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  /// Supprime un utilisateur par son ID
  /// 
  /// Note: Les CASCADE delete supprimeront aussi les téléchargements
  /// et résultats de quiz associés
  Future<int> deleteUser(int id) async {
    final Database db = await _dbManager.database;
    return await db.delete(
      DatabaseSchema.tableUtilisateur,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
