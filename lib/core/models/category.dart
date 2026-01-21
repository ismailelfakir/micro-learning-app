/// Modèle Catégorie
/// 
/// Représente une catégorie thématique de contenus éducatifs
class Category {
  final int? id;
  final String nom;
  final String? description;
  final String? icone; // Nom de l'icône Material (ex: "book", "school", "code")
  final DateTime dateCreation;

  const Category({
    this.id,
    required this.nom,
    this.description,
    this.icone,
    required this.dateCreation,
  });

  /// Crée un Category à partir d'une Map (résultat de requête SQLite)
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      nom: map['nom'] as String,
      description: map['description'] as String?,
      icone: map['icone'] as String?,
      dateCreation: DateTime.fromMillisecondsSinceEpoch(
        map['date_creation'] as int,
      ),
    );
  }

  /// Convertit un Category en Map pour insertion/mise à jour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nom': nom,
      'description': description,
      'icone': icone,
      'date_creation': dateCreation.millisecondsSinceEpoch,
    };
  }

  /// Crée une copie du Category avec des valeurs modifiées
  Category copyWith({
    int? id,
    String? nom,
    String? description,
    String? icone,
    DateTime? dateCreation,
  }) {
    return Category(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      icone: icone ?? this.icone,
      dateCreation: dateCreation ?? this.dateCreation,
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, nom: $nom, icone: $icone, dateCreation: $dateCreation)';
  }
}
