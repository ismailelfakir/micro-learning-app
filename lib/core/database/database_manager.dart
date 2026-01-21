import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_schema.dart';

/// Gestionnaire de base de données SQLite
/// 
/// Responsabilités:
/// - Initialisation de la base de données
/// - Création des tables
/// - Gestion des migrations
/// - Accès singleton à l'instance de la base de données
class DatabaseManager {
  static DatabaseManager? _instance;
  static Database? _database;

  DatabaseManager._internal();

  /// Instance singleton du gestionnaire de base de données
  factory DatabaseManager() {
    _instance ??= DatabaseManager._internal();
    return _instance!;
  }

  /// Accès à l'instance de la base de données
  /// 
  /// Initialise la base de données si elle n'existe pas encore
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialise la base de données et crée toutes les tables
  Future<Database> _initDatabase() async {
    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, DatabaseSchema.dbName);

    return await openDatabase(
      path,
      version: DatabaseSchema.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onDowngrade: _onDowngrade,
    );
  }

  /// Callback appelé lors de la création de la base de données
  /// 
  /// Crée toutes les tables et index selon le schéma défini
  Future<void> _onCreate(Database db, int version) async {
    // Création des tables
    for (final String statement in DatabaseSchema.getCreateTableStatements()) {
      await db.execute(statement);
    }

    // Création des index
    for (final String statement in DatabaseSchema.getCreateIndexStatements()) {
      await db.execute(statement);
    }
  }

  /// Callback appelé lors de la mise à jour de la base de données
  /// 
  /// Gère les migrations entre versions
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Pour l'instant, on récréé les tables en cas de migration
    // TODO: Implémenter des migrations incrémentales selon les besoins
    if (oldVersion < newVersion) {
      await _recreateDatabase(db);
    }
  }

  /// Callback appelé lors du downgrade de la base de données
  Future<void> _onDowngrade(Database db, int oldVersion, int newVersion) async {
    // Gestion du downgrade si nécessaire
    await _recreateDatabase(db);
  }

  /// Recrée toutes les tables de la base de données
  /// 
  /// Utilisé lors des migrations majeures
  Future<void> _recreateDatabase(Database db) async {
    // Suppression des tables existantes (dans l'ordre inverse des dépendances)
    final List<String> tables = [
      DatabaseSchema.tableResultatQuiz,
      DatabaseSchema.tableReponse,
      DatabaseSchema.tableQuestion,
      DatabaseSchema.tableQuiz,
      DatabaseSchema.tableTelechargement,
      DatabaseSchema.tableLecon,
      DatabaseSchema.tableCategorie,
      DatabaseSchema.tableUtilisateur,
    ];

    for (final String table in tables) {
      await db.execute('DROP TABLE IF EXISTS $table');
    }

    // Recréation des tables
    await _onCreate(db, DatabaseSchema.dbVersion);
  }

  /// Ferme la connexion à la base de données
  /// 
  /// À appeler lors de la fermeture de l'application
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _instance = null;
    }
  }

  /// Supprime la base de données (pour les tests ou réinitialisation)
  /// 
  /// ⚠️ Attention: Cette opération est destructive
  Future<void> deleteDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, DatabaseSchema.dbName);
    await databaseFactory.deleteDatabase(path);

    _instance = null;
  }

  /// Vérifie si la base de données existe déjà
  Future<bool> databaseExists() async {
    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, DatabaseSchema.dbName);
    return await databaseFactory.databaseExists(path);
  }

  /// Exécute une transaction
  /// 
  /// Permet d'exécuter plusieurs opérations de manière atomique
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final Database db = await database;
    return await db.transaction(action);
  }
}
