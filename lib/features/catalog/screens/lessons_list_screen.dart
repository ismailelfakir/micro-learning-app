import 'package:flutter/material.dart';
import '../services/catalog_service.dart';
import '../../../core/models/category.dart';
import '../../../core/models/lesson.dart';
import 'lesson_detail_screen.dart';

/// Écran affichant la liste des leçons d'une catégorie
class LessonsListScreen extends StatefulWidget {
  final Category category;

  const LessonsListScreen({
    super.key,
    required this.category,
  });

  @override
  State<LessonsListScreen> createState() => _LessonsListScreenState();
}

class _LessonsListScreenState extends State<LessonsListScreen> {
  final CatalogService _catalogService = CatalogService();

  List<Lesson> _lessons = [];
  String _selectedTypeFilter = 'ALL'; // ALL, TEXTE, IMAGE, PDF, VIDEO
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  /// Charge les leçons de la catégorie depuis la base de données
  Future<void> _loadLessons() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<Lesson> lessons =
          await _catalogService.getLessonsByCategoryId(widget.category.id!);

      if (mounted) {
        setState(() {
          _lessons = lessons;
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

  @override
  Widget build(BuildContext context) {
    final List<Lesson> filteredLessons = _selectedTypeFilter == 'ALL'
        ? _lessons
        : _lessons
            .where(
              (lesson) =>
                  lesson.contenuType.toUpperCase() == _selectedTypeFilter,
            )
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.nom),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _lessons.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.book_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Aucune leçon disponible',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Dans la catégorie ${widget.category.nom}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadLessons,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _TypeFilterBar(
                        selected: _selectedTypeFilter,
                        availableTypes: _availableTypes(_lessons),
                        onSelected: (value) {
                          setState(() {
                            _selectedTypeFilter = value;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${filteredLessons.length} leçon(s) affichée(s)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...filteredLessons.map(
                        (lesson) => _LessonCard(
                          lesson: lesson,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => LessonDetailScreen(
                                  lessonId: lesson.id!,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  /// Déduit les types disponibles à partir des leçons chargées
  List<String> _availableTypes(List<Lesson> lessons) {
    final Set<String> types = lessons
        .map((l) => l.contenuType.toUpperCase())
        .where((t) => t.isNotEmpty)
        .toSet();

    // Ordre stable et pro
    final List<String> ordered = ['TEXTE', 'IMAGE', 'PDF', 'VIDEO'];
    return ordered.where(types.contains).toList();
  }
}

/// Barre de filtres par type (pro, simple, mobile-friendly)
class _TypeFilterBar extends StatelessWidget {
  final String selected;
  final List<String> availableTypes;
  final ValueChanged<String> onSelected;

  const _TypeFilterBar({
    required this.selected,
    required this.availableTypes,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> chips = ['ALL', ...availableTypes];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips.map((value) {
          final bool isSelected = selected == value;
          final String label = value == 'ALL' ? 'Tous' : value;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => onSelected(value),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Widget carte pour afficher une leçon
class _LessonCard extends StatelessWidget {
  final Lesson lesson;
  final VoidCallback onTap;

  const _LessonCard({
    required this.lesson,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconForType(lesson.contenuType),
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.titre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (lesson.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        lesson.description!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildInfoChip(
                          Icons.access_time,
                          '${lesson.dureeEstimee ?? '?'} min',
                          context,
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          Icons.type_specimen,
                          lesson.contenuType,
                          context,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  IconData _getIconForType(String type) {
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
}
