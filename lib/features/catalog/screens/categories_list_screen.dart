import 'package:flutter/material.dart';
import '../services/catalog_service.dart';
import '../services/seed_service.dart';
import '../../../core/models/category.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/screens/login_screen.dart';
import 'lessons_list_screen.dart';
import '../../../core/database/database_debug_screen.dart';

/// Écran affichant la liste des catégories
/// 
/// Point d'entrée principal pour naviguer dans le catalogue
class CategoriesListScreen extends StatefulWidget {
  const CategoriesListScreen({super.key});

  @override
  State<CategoriesListScreen> createState() => _CategoriesListScreenState();
}

class _CategoriesListScreenState extends State<CategoriesListScreen> {
  final CatalogService _catalogService = CatalogService();
  final SeedService _seedService = SeedService();
  final AuthService _authService = AuthService();

  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  /// Charge les catégories depuis la base de données
  /// 
  /// Insère des données de démo si les tables sont vides
  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Insérer des données de démo si nécessaire (seulement si tables vides)
      await _seedService.seedDemoDataIfEmpty();

      // Charger les catégories
      final List<Category> categories = await _catalogService.getAllCategories();

      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Déconnecte l'utilisateur et redirige vers l'écran de connexion
  Future<void> _handleLogout() async {
    // Demander confirmation avant de déconnecter
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // Nettoyer la session
      await _authService.logout();

      // Rediriger vers l'écran de connexion
      // Utiliser pushReplacementNamed pour empêcher le retour
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false, // Supprime toutes les routes précédentes
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogue'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const DatabaseDebugScreen(),
                ),
              );
            },
            tooltip: 'Debug Base de Données',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
              ? const Center(
                  child: Text('Aucune catégorie disponible'),
                )
              : RefreshIndicator(
                  onRefresh: _loadCategories,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final Category category = _categories[index];
                      return _CategoryCard(
                        category: category,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => LessonsListScreen(
                                category: category,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
    );
  }
}

/// Widget carte pour afficher une catégorie
class _CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getIconData(category.icone),
                size: 40,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                category.nom,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (category.description != null) ...[
                const SizedBox(height: 6),
                Flexible(
                  child: Text(
                    category.description!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Convertit un nom d'icône Material en IconData
  /// 
  /// Retourne une icône par défaut si le nom n'est pas reconnu
  IconData _getIconData(String? iconName) {
    if (iconName == null || iconName.isEmpty) {
      return Icons.category;
    }

    // Mapping des noms d'icônes Material communs
    final Map<String, IconData> iconMap = {
      'code': Icons.code,
      'translate': Icons.translate,
      'calculate': Icons.calculate,
      'science': Icons.science,
      'book': Icons.book,
      'school': Icons.school,
      'menu_book': Icons.menu_book,
      'library_books': Icons.library_books,
      'category': Icons.category,
    };

    return iconMap[iconName] ?? Icons.category;
  }
}
