/// Modèle utilisateur
/// 
/// Représente un apprenant dans l'application
class User {
  final int? id;
  final String email;
  final String nom;
  final String motDePasse; // Hash du mot de passe
  final DateTime dateCreation;

  const User({
    this.id,
    required this.email,
    required this.nom,
    required this.motDePasse,
    required this.dateCreation,
  });

  /// Crée un User à partir d'une Map (résultat de requête SQLite)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      email: map['email'] as String,
      nom: map['nom'] as String,
      motDePasse: map['mot_de_passe'] as String,
      dateCreation: DateTime.fromMillisecondsSinceEpoch(
        map['date_creation'] as int,
      ),
    );
  }

  /// Convertit un User en Map pour insertion/mise à jour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'email': email,
      'nom': nom,
      'mot_de_passe': motDePasse,
      'date_creation': dateCreation.millisecondsSinceEpoch,
    };
  }

  /// Crée une copie du User avec des valeurs modifiées
  User copyWith({
    int? id,
    String? email,
    String? nom,
    String? motDePasse,
    DateTime? dateCreation,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      nom: nom ?? this.nom,
      motDePasse: motDePasse ?? this.motDePasse,
      dateCreation: dateCreation ?? this.dateCreation,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, nom: $nom, dateCreation: $dateCreation)';
  }
}
