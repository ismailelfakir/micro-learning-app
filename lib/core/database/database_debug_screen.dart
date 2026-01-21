import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database_debug_helper.dart';

/// Écran de debug pour visualiser la base de données SQLite
/// 
/// Permet d'inspecter les tables, voir les données, et exécuter des requêtes
class DatabaseDebugScreen extends StatefulWidget {
  const DatabaseDebugScreen({super.key});

  @override
  State<DatabaseDebugScreen> createState() => _DatabaseDebugScreenState();
}

class _DatabaseDebugScreenState extends State<DatabaseDebugScreen> {
  final DatabaseDebugHelper _helper = DatabaseDebugHelper();
  
  Map<String, int> _stats = {};
  bool _isLoading = true;
  String _selectedView = 'stats';

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final Map<String, int> stats = await _helper.getTablesStats();
      
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showError('Erreur lors du chargement: ${e.toString()}');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Base de Données'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
            tooltip: 'Rafraîchir',
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'export') {
                await _exportData();
              } else if (value == 'clear') {
                await _confirmClearData();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 20),
                    SizedBox(width: 8),
                    Text('Exporter les données'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Vider la base'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Navigation tabs
                _buildNavigationBar(),
                
                // Content
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            _buildNavButton('Statistiques', 'stats', Icons.bar_chart),
            _buildNavButton('Utilisateurs', 'users', Icons.people),
            _buildNavButton('Catégories', 'categories', Icons.category),
            _buildNavButton('Leçons', 'lessons', Icons.book),
            _buildNavButton('Quiz', 'quizzes', Icons.quiz),
            _buildNavButton('Tables', 'tables', Icons.table_chart),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(String label, String view, IconData icon) {
    final bool isSelected = _selectedView == view;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _selectedView = view;
          });
        },
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? Theme.of(context).primaryColor
              : Colors.grey[300],
          foregroundColor: isSelected ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedView) {
      case 'stats':
        return _buildStatsView();
      case 'users':
        return _buildUsersView();
      case 'categories':
        return _buildCategoriesView();
      case 'lessons':
        return _buildLessonsView();
      case 'quizzes':
        return _buildQuizzesView();
      case 'tables':
        return _buildTablesView();
      default:
        return const Center(child: Text('Vue non disponible'));
    }
  }

  Widget _buildStatsView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Statistiques Générales',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._stats.entries.map((entry) {
          return Card(
            child: ListTile(
              leading: Icon(
                _getIconForTable(entry.key),
                color: Theme.of(context).primaryColor,
              ),
              title: Text(entry.key),
              trailing: Chip(
                label: Text(
                  '${entry.value}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildUsersView() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _helper.getUsersWithStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }
        
        final List<Map<String, dynamic>> users = snapshot.data ?? [];
        
        if (users.isEmpty) {
          return const Center(child: Text('Aucun utilisateur'));
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final Map<String, dynamic> user = users[index];
            return Card(
              child: ExpansionTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(user['nom'] ?? 'N/A'),
                subtitle: Text(user['email'] ?? 'N/A'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('ID', '${user['id']}'),
                        _buildInfoRow('Téléchargements', '${user['nb_telechargements']}'),
                        _buildInfoRow('Quiz complétés', '${user['nb_quiz_completes']}'),
                        _buildInfoRow(
                          'Date création',
                          _formatTimestamp(user['date_creation'] as int),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoriesView() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _helper.getCategoriesWithLessonCount(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }
        
        final List<Map<String, dynamic>> categories = snapshot.data ?? [];
        
        if (categories.isEmpty) {
          return const Center(child: Text('Aucune catégorie'));
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final Map<String, dynamic> category = categories[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.category),
                title: Text(category['nom'] ?? 'N/A'),
                subtitle: Text(category['description'] ?? 'Pas de description'),
                trailing: Chip(
                  label: Text('${category['nb_lecons']} leçons'),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLessonsView() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _helper.getLessonsWithDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }
        
        final List<Map<String, dynamic>> lessons = snapshot.data ?? [];
        
        if (lessons.isEmpty) {
          return const Center(child: Text('Aucune leçon'));
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            final Map<String, dynamic> lesson = lessons[index];
            return Card(
              child: ExpansionTile(
                leading: Icon(_getIconForContentType(lesson['contenu_type'] as String)),
                title: Text(lesson['titre'] ?? 'N/A'),
                subtitle: Text(lesson['categorie'] ?? 'N/A'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('ID', '${lesson['id']}'),
                        _buildInfoRow('Type', '${lesson['contenu_type']}'),
                        _buildInfoRow('Durée', '${lesson['duree_estimee']} min'),
                        _buildInfoRow('Quiz', '${lesson['a_quiz']}'),
                        _buildInfoRow('Téléchargements', '${lesson['nb_telechargements']}'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuizzesView() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _helper.getQuizzesWithQuestionCount(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }
        
        final List<Map<String, dynamic>> quizzes = snapshot.data ?? [];
        
        if (quizzes.isEmpty) {
          return const Center(child: Text('Aucun quiz'));
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final Map<String, dynamic> quiz = quizzes[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.quiz),
                title: Text(quiz['titre'] ?? 'N/A'),
                subtitle: Text('Leçon: ${quiz['lecon'] ?? 'N/A'}'),
                trailing: Chip(
                  label: Text('${quiz['nb_questions']} questions'),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTablesView() {
    return FutureBuilder<List<String>>(
      future: _helper.getAllTables(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }
        
        final List<String> tables = snapshot.data ?? [];
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tables.length,
          itemBuilder: (context, index) {
            final String tableName = tables[index];
            return Card(
              child: ExpansionTile(
                leading: Icon(
                  _getIconForTable(tableName),
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(tableName),
                subtitle: Text('${_stats[tableName] ?? 0} lignes'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _viewTableData(tableName),
                          icon: const Icon(Icons.visibility),
                          label: const Text('Voir les données'),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () => _viewTableSchema(tableName),
                          icon: const Icon(Icons.schema),
                          label: const Text('Voir la structure'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _viewTableData(String tableName) async {
    try {
      final List<Map<String, dynamic>> data = await _helper.getTableData(tableName);
      
      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Données: $tableName'),
          content: SizedBox(
            width: double.maxFinite,
            child: data.isEmpty
                ? const Text('Table vide')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            data[index].toString(),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showError('Erreur: ${e.toString()}');
    }
  }

  Future<void> _viewTableSchema(String tableName) async {
    try {
      final List<Map<String, dynamic>> schema = await _helper.getTableSchema(tableName);
      
      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Structure: $tableName'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: schema.length,
              itemBuilder: (context, index) {
                final Map<String, dynamic> column = schema[index];
                return ListTile(
                  title: Text(column['name'] as String),
                  subtitle: Text('Type: ${column['type']}'),
                  trailing: column['pk'] == 1
                      ? const Chip(label: Text('PK'))
                      : null,
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showError('Erreur: ${e.toString()}');
    }
  }

  Future<void> _exportData() async {
    try {
      final String data = await _helper.exportAllData();
      
      await Clipboard.setData(ClipboardData(text: data));
      
      if (mounted) {
        _showSuccess('Données exportées dans le presse-papier !');
      }
    } catch (e) {
      _showError('Erreur lors de l\'export: ${e.toString()}');
    }
  }

  Future<void> _confirmClearData() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Attention'),
        content: const Text(
          'Êtes-vous sûr de vouloir vider TOUTE la base de données ?\n\n'
          'Cette action est IRRÉVERSIBLE et supprimera :\n'
          '• Tous les utilisateurs\n'
          '• Toutes les catégories\n'
          '• Toutes les leçons\n'
          '• Tous les quiz\n'
          '• Tous les téléchargements\n'
          '• Tous les résultats',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('VIDER LA BASE'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _helper.clearAllData();
        await _loadStats();
        if (mounted) {
          _showSuccess('Base de données vidée avec succès');
        }
      } catch (e) {
        _showError('Erreur: ${e.toString()}');
      }
    }
  }

  IconData _getIconForTable(String tableName) {
    switch (tableName.toUpperCase()) {
      case 'UTILISATEUR':
        return Icons.person;
      case 'CATEGORIE':
        return Icons.category;
      case 'LECON':
        return Icons.book;
      case 'TELECHARGEMENT':
        return Icons.download;
      case 'QUIZ':
        return Icons.quiz;
      case 'QUESTION':
        return Icons.help_outline;
      case 'REPONSE':
        return Icons.check_circle_outline;
      case 'RESULTAT_QUIZ':
        return Icons.grade;
      default:
        return Icons.table_chart;
    }
  }

  IconData _getIconForContentType(String type) {
    switch (type.toUpperCase()) {
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'VIDEO':
        return Icons.video_library;
      case 'TEXTE':
        return Icons.article;
      case 'IMAGE':
        return Icons.image;
      default:
        return Icons.description;
    }
  }

  String _formatTimestamp(int timestamp) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}
