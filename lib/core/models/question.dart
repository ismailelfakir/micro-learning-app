/// Modèle Question
/// 
/// Représente une question d'un quiz
class Question {
  final int? id;
  final int quizId;
  final String texte;
  final String type;
  final int ordre;

  const Question({
    this.id,
    required this.quizId,
    required this.texte,
    required this.type,
    required this.ordre,
  });

  /// Crée un Question à partir d'une Map (résultat de requête SQLite)
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] as int?,
      quizId: map['quiz_id'] as int,
      texte: map['texte'] as String,
      type: map['type'] as String,
      ordre: map['ordre'] as int,
    );
  }

  /// Convertit un Question en Map pour insertion/mise à jour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'quiz_id': quizId,
      'texte': texte,
      'type': type,
      'ordre': ordre,
    };
  }

  /// Crée une copie du Question avec des valeurs modifiées
  Question copyWith({
    int? id,
    int? quizId,
    String? texte,
    String? type,
    int? ordre,
  }) {
    return Question(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      texte: texte ?? this.texte,
      type: type ?? this.type,
      ordre: ordre ?? this.ordre,
    );
  }

  @override
  String toString() {
    return 'Question(id: $id, texte: $texte, ordre: $ordre)';
  }
}
