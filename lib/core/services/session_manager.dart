import 'package:shared_preferences/shared_preferences.dart';

/// Gestionnaire de session utilisateur local
/// 
/// Stocke l'ID de l'utilisateur connecté de manière persistante
/// Utilise SharedPreferences pour le stockage local
class SessionManager {
  static SessionManager? _instance;
  static SharedPreferences? _prefs;
  static const String _userIdKey = 'current_user_id';

  SessionManager._internal();

  /// Instance singleton du gestionnaire de session
  factory SessionManager() {
    _instance ??= SessionManager._internal();
    return _instance!;
  }

  /// Initialise SharedPreferences (à appeler au démarrage de l'app)
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Enregistre l'ID de l'utilisateur connecté
  /// 
  /// Appelé après une connexion réussie
  Future<void> saveSession(int userId) async {
    await init();
    await _prefs!.setInt(_userIdKey, userId);
  }

  /// Récupère l'ID de l'utilisateur connecté
  /// 
  /// Retourne null si aucun utilisateur n'est connecté
  Future<int?> getCurrentUserId() async {
    await init();
    return _prefs!.getInt(_userIdKey);
  }

  /// Vérifie si un utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final int? userId = await getCurrentUserId();
    return userId != null;
  }

  /// Déconnecte l'utilisateur actuel
  /// 
  /// Supprime l'ID stocké
  Future<void> logout() async {
    await init();
    await _prefs!.remove(_userIdKey);
  }

  /// Efface toutes les données de session
  Future<void> clearSession() async {
    await init();
    await _prefs!.clear();
  }
}
