/// Modèle Answer (Réponse)
/// 
/// Représente une réponse possible à une question
class Answer {
  final int? id;
  final int questionId;
  final String texte;
  final bool estCorrecte;
  final int ordre;

  const Answer({
    this.id,
    required this.questionId,
    required this.texte,
    required this.estCorrecte,
    required this.ordre,
  });

  /// Crée un Answer à partir d'une Map (résultat de requête SQLite)
  /// 
  /// Note: est_correcte est stocké comme INTEGER (0 ou 1) dans SQLite
  factory Answer.fromMap(Map<String, dynamic> map) {
    return Answer(
      id: map['id'] as int?,
      questionId: map['question_id'] as int,
      texte: map['texte'] as String,
      estCorrecte: (map['est_correcte'] as int) == 1,
      ordre: map['ordre'] as int,
    );
  }

  /// Convertit un Answer en Map pour insertion/mise à jour SQLite
  /// 
  /// Note: est_correcte est converti en INTEGER (0 ou 1)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'question_id': questionId,
      'texte': texte,
      'est_correcte': estCorrecte ? 1 : 0,
      'ordre': ordre,
    };
  }

  /// Crée une copie du Answer avec des valeurs modifiées
  Answer copyWith({
    int? id,
    int? questionId,
    String? texte,
    bool? estCorrecte,
    int? ordre,
  }) {
    return Answer(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      texte: texte ?? this.texte,
      estCorrecte: estCorrecte ?? this.estCorrecte,
      ordre: ordre ?? this.ordre,
    );
  }

  @override
  String toString() {
    return 'Answer(id: $id, texte: $texte, estCorrecte: $estCorrecte, ordre: $ordre)';
  }
}
