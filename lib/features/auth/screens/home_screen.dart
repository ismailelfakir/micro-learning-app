import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../../../core/models/user.dart';
import '../../catalog/screens/categories_list_screen.dart';

/// Écran d'accueil (temporaire)
/// 
/// Affiche les informations de l'utilisateur connecté
/// Sera remplacé par le vrai écran d'accueil dans les prochaines features
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final User? user = await _authService.getCurrentUser();
    setState(() {
      _currentUser = user;
      _isLoading = false;
    });
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentUser == null
              ? const Center(child: Text('Aucun utilisateur connecté'))
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 80,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Connexion réussie !',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Informations utilisateur',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildInfoRow('Nom', _currentUser!.nom),
                                const SizedBox(height: 8),
                                _buildInfoRow('Email', _currentUser!.email),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  'Date d\'inscription',
                                  _formatDate(_currentUser!.dateCreation),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Module d\'authentification fonctionnel ✓',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
