/// Modèle Téléchargement
/// 
/// Représente le téléchargement d'une leçon par un utilisateur pour mode offline
class Download {
  final int? id;
  final int utilisateurId;
  final int leconId;
  final DateTime dateTelechargement;
  final String statut; // 'completed', 'downloading', 'failed'
  final String? cheminLocal;

  const Download({
    this.id,
    required this.utilisateurId,
    required this.leconId,
    required this.dateTelechargement,
    required this.statut,
    this.cheminLocal,
  });

  /// Crée un Download à partir d'une Map (résultat de requête SQLite)
  factory Download.fromMap(Map<String, dynamic> map) {
    return Download(
      id: map['id'] as int?,
      utilisateurId: map['utilisateur_id'] as int,
      leconId: map['lecon_id'] as int,
      dateTelechargement: DateTime.fromMillisecondsSinceEpoch(
        map['date_telechargement'] as int,
      ),
      statut: map['statut'] as String,
      cheminLocal: map['chemin_local'] as String?,
    );
  }

  /// Convertit un Download en Map pour insertion/mise à jour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'utilisateur_id': utilisateurId,
      'lecon_id': leconId,
      'date_telechargement': dateTelechargement.millisecondsSinceEpoch,
      'statut': statut,
      'chemin_local': cheminLocal,
    };
  }

  /// Crée une copie du Download avec des valeurs modifiées
  Download copyWith({
    int? id,
    int? utilisateurId,
    int? leconId,
    DateTime? dateTelechargement,
    String? statut,
    String? cheminLocal,
  }) {
    return Download(
      id: id ?? this.id,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      leconId: leconId ?? this.leconId,
      dateTelechargement: dateTelechargement ?? this.dateTelechargement,
      statut: statut ?? this.statut,
      cheminLocal: cheminLocal ?? this.cheminLocal,
    );
  }

  @override
  String toString() {
    return 'Download(id: $id, leconId: $leconId, statut: $statut)';
  }
}
