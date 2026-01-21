/// Modèle Quiz
/// 
/// Représente un quiz associé à une leçon
class Quiz {
  final int? id;
  final int leconId;
  final String titre;
  final String? description;
  final DateTime dateCreation;

  const Quiz({
    this.id,
    required this.leconId,
    required this.titre,
    this.description,
    required this.dateCreation,
  });

  /// Crée un Quiz à partir d'une Map (résultat de requête SQLite)
  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      id: map['id'] as int?,
      leconId: map['lecon_id'] as int,
      titre: map['titre'] as String,
      description: map['description'] as String?,
      dateCreation: DateTime.fromMillisecondsSinceEpoch(
        map['date_creation'] as int,
      ),
    );
  }

  /// Convertit un Quiz en Map pour insertion/mise à jour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'lecon_id': leconId,
      'titre': titre,
      'description': description,
      'date_creation': dateCreation.millisecondsSinceEpoch,
    };
  }

  /// Crée une copie du Quiz avec des valeurs modifiées
  Quiz copyWith({
    int? id,
    int? leconId,
    String? titre,
    String? description,
    DateTime? dateCreation,
  }) {
    return Quiz(
      id: id ?? this.id,
      leconId: leconId ?? this.leconId,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      dateCreation: dateCreation ?? this.dateCreation,
    );
  }

  @override
  String toString() {
    return 'Quiz(id: $id, titre: $titre, leconId: $leconId)';
  }
}
