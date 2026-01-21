import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../../core/models/user.dart';
import '../../../core/services/session_manager.dart';
import '../data/user_dao.dart';

/// Service d'authentification
/// 
/// Gère l'inscription, la connexion et la validation des utilisateurs
/// Utilise un hash SHA-256 pour sécuriser les mots de passe localement
class AuthService {
  final UserDao _userDao = UserDao();
  final SessionManager _sessionManager = SessionManager();

  /// Hash un mot de passe en SHA-256
  /// 
  /// Utilisé pour stocker les mots de passe de manière sécurisée
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Inscrit un nouvel utilisateur
  /// 
  /// Retourne le User créé avec son ID
  /// Lance une exception si l'email existe déjà ou si la validation échoue
  Future<User> register({
    required String email,
    required String nom,
    required String motDePasse,
  }) async {
    // Validation des données d'entrée
    if (email.trim().isEmpty) {
      throw Exception('L\'email est requis');
    }

    if (nom.trim().isEmpty) {
      throw Exception('Le nom est requis');
    }

    if (motDePasse.length < 6) {
      throw Exception('Le mot de passe doit contenir au moins 6 caractères');
    }

    // Validation de l'email (format basique)
    if (!email.contains('@') || !email.contains('.')) {
      throw Exception('Format d\'email invalide');
    }

    // Vérifier si l'email existe déjà
    final bool emailExists = await _userDao.emailExists(email);
    if (emailExists) {
      throw Exception('Cet email est déjà utilisé');
    }

    // Créer l'utilisateur avec mot de passe hashé
    final User newUser = User(
      email: email.trim().toLowerCase(),
      nom: nom.trim(),
      motDePasse: _hashPassword(motDePasse),
      dateCreation: DateTime.now(),
    );

    // Sauvegarder dans la base de données
    final int userId = await _userDao.createUser(newUser);

    // Retourner l'utilisateur créé avec son ID
    return newUser.copyWith(id: userId);
  }

  /// Connecte un utilisateur
  /// 
  /// Retourne le User connecté si les identifiants sont valides
  /// Lance une exception si l'email ou le mot de passe est incorrect
  Future<User> login({
    required String email,
    required String motDePasse,
  }) async {
    // Validation des données d'entrée
    if (email.trim().isEmpty) {
      throw Exception('L\'email est requis');
    }

    if (motDePasse.isEmpty) {
      throw Exception('Le mot de passe est requis');
    }

    // Récupérer l'utilisateur par email
    final User? user = await _userDao.getUserByEmail(email.trim().toLowerCase());

    if (user == null) {
      throw Exception('Email ou mot de passe incorrect');
    }

    // Vérifier le mot de passe
    final String hashedPassword = _hashPassword(motDePasse);
    if (user.motDePasse != hashedPassword) {
      throw Exception('Email ou mot de passe incorrect');
    }

    // Sauvegarder la session
    if (user.id != null) {
      await _sessionManager.saveSession(user.id!);
    }

    // Retourner l'utilisateur (sans le mot de passe pour la sécurité)
    return user;
  }

  /// Déconnecte l'utilisateur actuel
  /// 
  /// Supprime la session locale
  Future<void> logout() async {
    await _sessionManager.logout();
  }

  /// Récupère l'utilisateur actuellement connecté
  /// 
  /// Retourne null si aucun utilisateur n'est connecté
  Future<User?> getCurrentUser() async {
    final int? userId = await _sessionManager.getCurrentUserId();
    if (userId == null) {
      return null;
    }

    return await _userDao.getUserById(userId);
  }

  /// Vérifie si un utilisateur est connecté
  Future<bool> isLoggedIn() async {
    return await _sessionManager.isLoggedIn();
  }
}
