/// Modèle Leçon
/// 
/// Représente une leçon éducative liée à une catégorie
class Lesson {
  final int? id;
  final int categorieId;
  final String titre;
  final String? description;
  final String contenuType; // PDF, VIDEO, TEXTE
  final String? cheminFichier; // Pour l'instant, optionnel (pas de média)
  final int? dureeEstimee; // Durée estimée en minutes
  final DateTime dateCreation;

  const Lesson({
    this.id,
    required this.categorieId,
    required this.titre,
    this.description,
    required this.contenuType,
    this.cheminFichier,
    this.dureeEstimee,
    required this.dateCreation,
  });

  /// Crée un Lesson à partir d'une Map (résultat de requête SQLite)
  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'] as int?,
      categorieId: map['categorie_id'] as int,
      titre: map['titre'] as String,
      description: map['description'] as String?,
      contenuType: map['contenu_type'] as String,
      cheminFichier: map['chemin_fichier'] as String?,
      dureeEstimee: map['duree_estimee'] as int?,
      dateCreation: DateTime.fromMillisecondsSinceEpoch(
        map['date_creation'] as int,
      ),
    );
  }

  /// Convertit un Lesson en Map pour insertion/mise à jour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'categorie_id': categorieId,
      'titre': titre,
      'description': description,
      'contenu_type': contenuType,
      'chemin_fichier': cheminFichier,
      'duree_estimee': dureeEstimee,
      'date_creation': dateCreation.millisecondsSinceEpoch,
    };
  }

  /// Crée une copie du Lesson avec des valeurs modifiées
  Lesson copyWith({
    int? id,
    int? categorieId,
    String? titre,
    String? description,
    String? contenuType,
    String? cheminFichier,
    int? dureeEstimee,
    DateTime? dateCreation,
  }) {
    return Lesson(
      id: id ?? this.id,
      categorieId: categorieId ?? this.categorieId,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      contenuType: contenuType ?? this.contenuType,
      cheminFichier: cheminFichier ?? this.cheminFichier,
      dureeEstimee: dureeEstimee ?? this.dureeEstimee,
      dateCreation: dateCreation ?? this.dateCreation,
    );
  }

  @override
  String toString() {
    return 'Lesson(id: $id, titre: $titre, categorieId: $categorieId, type: $contenuType)';
  }
}
