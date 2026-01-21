/// Schéma de la base de données SQLite
/// 
/// Définit toutes les tables et leurs relations selon PROJECT_TECHNICAL_SPEC.md
class DatabaseSchema {
  static const String dbName = 'micro_learning.db';
  static const int dbVersion = 1;

  // Noms des tables
  static const String tableUtilisateur = 'UTILISATEUR';
  static const String tableCategorie = 'CATEGORIE';
  static const String tableLecon = 'LECON';
  static const String tableTelechargement = 'TELECHARGEMENT';
  static const String tableQuiz = 'QUIZ';
  static const String tableQuestion = 'QUESTION';
  static const String tableReponse = 'REPONSE';
  static const String tableResultatQuiz = 'RESULTAT_QUIZ';

  /// Crée toutes les tables de la base de données
  static List<String> getCreateTableStatements() {
    return [
      createTableUtilisateur,
      createTableCategorie,
      createTableLecon,
      createTableTelechargement,
      createTableQuiz,
      createTableQuestion,
      createTableReponse,
      createTableResultatQuiz,
    ];
  }

  /// Table UTILISATEUR - Gestion des apprenants
  /// 
  /// Relation: Utilisateur ↔ TELECHARGEMENT ↔ LECON
  /// Relation: Utilisateur ↔ RESULTAT_QUIZ
  static const String createTableUtilisateur = '''
    CREATE TABLE $tableUtilisateur (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT NOT NULL UNIQUE,
      nom TEXT NOT NULL,
      mot_de_passe TEXT NOT NULL,
      date_creation INTEGER NOT NULL
    )
  ''';

  /// Table CATEGORIE - Catégories de contenus éducatifs
  /// 
  /// Relation: CATEGORIE → LECON (une catégorie contient plusieurs leçons)
  static const String createTableCategorie = '''
    CREATE TABLE $tableCategorie (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nom TEXT NOT NULL,
      description TEXT,
      icone TEXT,
      date_creation INTEGER NOT NULL
    )
  ''';

  /// Table LECON - Leçons éducatives
  /// 
  /// Relation: CATEGORIE → LECON (foreign key: categorie_id)
  /// Relation: LECON ↔ TELECHARGEMENT ↔ UTILISATEUR
  /// Relation: LECON ↔ QUIZ (une leçon peut avoir un quiz)
  static const String createTableLecon = '''
    CREATE TABLE $tableLecon (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      categorie_id INTEGER NOT NULL,
      titre TEXT NOT NULL,
      description TEXT,
      contenu_type TEXT NOT NULL,
      chemin_fichier TEXT,
      duree_estimee INTEGER,
      date_creation INTEGER NOT NULL,
      FOREIGN KEY (categorie_id) REFERENCES $tableCategorie(id) ON DELETE CASCADE
    )
  ''';

  /// Table TELECHARGEMENT - Suivi des téléchargements pour mode hors-ligne
  /// 
  /// Relation: UTILISATEUR ↔ TELECHARGEMENT ↔ LECON
  /// Table de liaison pour gérer les téléchargements des utilisateurs
  static const String createTableTelechargement = '''
    CREATE TABLE $tableTelechargement (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      utilisateur_id INTEGER NOT NULL,
      lecon_id INTEGER NOT NULL,
      date_telechargement INTEGER NOT NULL,
      statut TEXT NOT NULL,
      chemin_local TEXT,
      FOREIGN KEY (utilisateur_id) REFERENCES $tableUtilisateur(id) ON DELETE CASCADE,
      FOREIGN KEY (lecon_id) REFERENCES $tableLecon(id) ON DELETE CASCADE,
      UNIQUE(utilisateur_id, lecon_id)
    )
  ''';

  /// Table QUIZ - Quiz associés aux leçons
  /// 
  /// Relation: LECON ↔ QUIZ (foreign key: lecon_id)
  /// Relation: QUIZ → QUESTION (un quiz contient plusieurs questions)
  /// Relation: QUIZ ↔ RESULTAT_QUIZ (résultats des quiz)
  static const String createTableQuiz = '''
    CREATE TABLE $tableQuiz (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      lecon_id INTEGER NOT NULL UNIQUE,
      titre TEXT NOT NULL,
      description TEXT,
      date_creation INTEGER NOT NULL,
      FOREIGN KEY (lecon_id) REFERENCES $tableLecon(id) ON DELETE CASCADE
    )
  ''';

  /// Table QUESTION - Questions d'un quiz (QCM)
  /// 
  /// Relation: QUIZ → QUESTION (foreign key: quiz_id)
  /// Relation: QUESTION → REPONSE (une question a plusieurs réponses)
  static const String createTableQuestion = '''
    CREATE TABLE $tableQuestion (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      quiz_id INTEGER NOT NULL,
      texte TEXT NOT NULL,
      type TEXT NOT NULL,
      ordre INTEGER NOT NULL,
      FOREIGN KEY (quiz_id) REFERENCES $tableQuiz(id) ON DELETE CASCADE
    )
  ''';

  /// Table REPONSE - Réponses possibles aux questions
  /// 
  /// Relation: QUESTION → REPONSE (foreign key: question_id)
  /// Chaque réponse indique si elle est correcte (est_correcte)
  static const String createTableReponse = '''
    CREATE TABLE $tableReponse (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      question_id INTEGER NOT NULL,
      texte TEXT NOT NULL,
      est_correcte INTEGER NOT NULL CHECK(est_correcte IN (0, 1)),
      ordre INTEGER NOT NULL,
      FOREIGN KEY (question_id) REFERENCES $tableQuestion(id) ON DELETE CASCADE
    )
  ''';

  /// Table RESULTAT_QUIZ - Résultats des quiz des utilisateurs
  /// 
  /// Relation: UTILISATEUR ↔ RESULTAT_QUIZ (foreign key: utilisateur_id)
  /// Relation: QUIZ ↔ RESULTAT_QUIZ (foreign key: quiz_id)
  static const String createTableResultatQuiz = '''
    CREATE TABLE $tableResultatQuiz (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      utilisateur_id INTEGER NOT NULL,
      quiz_id INTEGER NOT NULL,
      score REAL NOT NULL,
      date_completion INTEGER NOT NULL,
      FOREIGN KEY (utilisateur_id) REFERENCES $tableUtilisateur(id) ON DELETE CASCADE,
      FOREIGN KEY (quiz_id) REFERENCES $tableQuiz(id) ON DELETE CASCADE
    )
  ''';

  /// Crée les index pour améliorer les performances des requêtes
  static List<String> getCreateIndexStatements() {
    return [
      // Index sur les emails pour recherche rapide
      'CREATE INDEX IF NOT EXISTS idx_utilisateur_email ON $tableUtilisateur(email)',
      
      // Index sur les foreign keys
      'CREATE INDEX IF NOT EXISTS idx_lecon_categorie ON $tableLecon(categorie_id)',
      'CREATE INDEX IF NOT EXISTS idx_telechargement_utilisateur ON $tableTelechargement(utilisateur_id)',
      'CREATE INDEX IF NOT EXISTS idx_telechargement_lecon ON $tableTelechargement(lecon_id)',
      'CREATE INDEX IF NOT EXISTS idx_quiz_lecon ON $tableQuiz(lecon_id)',
      'CREATE INDEX IF NOT EXISTS idx_question_quiz ON $tableQuestion(quiz_id)',
      'CREATE INDEX IF NOT EXISTS idx_reponse_question ON $tableReponse(question_id)',
      'CREATE INDEX IF NOT EXISTS idx_resultat_utilisateur ON $tableResultatQuiz(utilisateur_id)',
      'CREATE INDEX IF NOT EXISTS idx_resultat_quiz ON $tableResultatQuiz(quiz_id)',
    ];
  }
}
