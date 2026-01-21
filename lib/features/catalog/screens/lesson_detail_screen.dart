import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/catalog_service.dart';
import '../../../core/models/lesson.dart';
import '../../../core/models/category.dart';
import '../../quiz/services/quiz_service.dart';
import '../../quiz/screens/quiz_screen.dart';
import '../../content_reader/screens/pdf_viewer_screen.dart';
import '../../content_reader/screens/video_player_screen.dart';
import '../../content_reader/services/download_service.dart';

/// Écran affichant les détails d'une leçon
/// 
/// Pour l'instant, affiche uniquement les informations (pas de média)
class LessonDetailScreen extends StatefulWidget {
  final int lessonId;

  const LessonDetailScreen({
    super.key,
    required this.lessonId,
  });

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  final CatalogService _catalogService = CatalogService();
  final QuizService _quizService = QuizService();
  final DownloadService _downloadService = DownloadService();

  Lesson? _lesson;
  Category? _category;
  bool _isLoading = true;
  bool _hasQuiz = false;
  bool _isDownloaded = false;
  bool _isDownloading = false;
  String? _localPath;

  @override
  void initState() {
    super.initState();
    _loadLesson();
  }

  /// Charge la leçon avec sa catégorie associée
  Future<void> _loadLesson() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _catalogService.getLessonWithCategory(widget.lessonId);

      if (mounted) {
        // Vérifier si un quiz existe pour cette leçon
        bool hasQuiz = false;
        if (result?.lesson.id != null) {
          final quizContent = await _quizService.getQuizWithContentByLeconId(result!.lesson.id!);
          hasQuiz = quizContent != null;
        }

        // Vérifier le statut de téléchargement
        bool isDownloaded = false;
        String? localPath;
        if (result?.lesson != null) {
          isDownloaded = await _downloadService.isLessonDownloaded(result!.lesson);
          if (isDownloaded) {
            localPath = await _downloadService.getLocalPath(result.lesson);
          }
        }

        setState(() {
          _lesson = result?.lesson;
          _category = result?.category;
          _hasQuiz = hasQuiz;
          _isDownloaded = isDownloaded;
          _localPath = localPath;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la leçon'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _lesson == null
              ? const Center(
                  child: Text('Leçon introuvable'),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // En-tête avec icône et type
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getIconForType(_lesson!.contenuType),
                                  size: 32,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _lesson!.titre,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        if (_category != null)
                                          Text(
                                            _category!.nom,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          ),
                                        if (_isDownloaded) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.download_done,
                                                  size: 12,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Téléchargé',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Informations de la leçon
                      _buildInfoSection(
                        title: 'Informations',
                        children: [
                          _buildInfoRow(
                            'Type de contenu',
                            _lesson!.contenuType,
                            Icons.type_specimen,
                          ),
                          if (_lesson!.dureeEstimee != null)
                            _buildInfoRow(
                              'Durée estimée',
                              '${_lesson!.dureeEstimee} minutes',
                              Icons.access_time,
                            ),
                          _buildInfoRow(
                            'Date de création',
                            _formatDate(_lesson!.dateCreation),
                            Icons.calendar_today,
                          ),
                        ],
                      ),

                      // Description
                      if (_lesson!.description != null) ...[
                        const SizedBox(height: 16),
                        _buildInfoSection(
                          title: 'Description',
                          children: [
                            Text(
                              _lesson!.description!,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Contenu selon le type de leçon
                      const SizedBox(height: 24),
                      _buildContentSection(),

                      // Bouton Quiz (si disponible)
                      if (_hasQuiz) ...[
                        const SizedBox(height: 24),
                        _buildQuizButton(),
                      ],
                    ],
                  ),
                ),
    );
  }

  /// Télécharge la leçon pour accès hors-ligne
  Future<void> _downloadLesson() async {
    if (_lesson == null) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      final String localPath = await _downloadService.downloadLesson(_lesson!);

      if (mounted) {
        setState(() {
          _isDownloaded = true;
          _localPath = localPath;
          _isDownloading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Téléchargement terminé !'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Supprime le téléchargement de la leçon
  Future<void> _deleteDownload() async {
    if (_lesson == null) return;

    // Demander confirmation
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le téléchargement'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer ce contenu téléchargé ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _downloadService.deleteDownload(_lesson!);

      if (mounted) {
        setState(() {
          _isDownloaded = false;
          _localPath = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Téléchargement supprimé'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Construit le bouton pour commencer le quiz
  Widget _buildQuizButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => QuizScreen(
                leconId: widget.lessonId,
                lessonTitle: _lesson!.titre,
              ),
            ),
          );
        },
        icon: const Icon(Icons.quiz),
        label: const Text('Commencer le quiz'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construit la section de contenu selon le type de leçon
  Widget _buildContentSection() {
    final String type = _lesson!.contenuType.toUpperCase();

    switch (type) {
      case 'TEXTE':
        return _buildTextContent();
      case 'IMAGE':
        return _buildImageContent();
      case 'PDF':
        return _buildPdfContent();
      case 'VIDEO':
        return _buildVideoContent();
      default:
        return _buildUnsupportedContent(type);
    }
  }

  /// Affiche le contenu texte formaté
  Widget _buildTextContent() {
    // Pour l'instant, utilise la description comme contenu texte
    // Plus tard, un champ contenu dédié pourra être ajouté
    final String content = _lesson!.description ?? 'Aucun contenu disponible.';

    return _buildInfoSection(
      title: 'Contenu',
      children: [
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  /// Affiche l'image pour les leçons de type IMAGE
  Widget _buildImageContent() {
    final String? imagePath = _lesson!.cheminFichier;

    return _buildInfoSection(
      title: 'Image',
      children: [
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 200),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: imagePath != null && imagePath.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildImageWidget(imagePath),
                )
              : Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Aucune image disponible',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  /// Construit le widget d'image approprié selon le format (SVG ou autre)
  Widget _buildImageWidget(String imagePath) {
    // Détecter si c'est un SVG
    final bool isSvg = imagePath.toLowerCase().endsWith('.svg');

    if (isSvg) {
      // Utiliser flutter_svg pour les SVG
      return SvgPicture.asset(
        imagePath,
        fit: BoxFit.contain,
        placeholderBuilder: (context) => Container(
          height: 200,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    } else {
      // Utiliser Image.asset pour PNG, JPG, etc.
      return Image.asset(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Si l'image ne peut pas être chargée, afficher un placeholder
          return Container(
            height: 200,
            color: Colors.grey[200],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Text(
                  'Image introuvable',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Chemin: $imagePath',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );
    }
  }

  /// Affiche le contenu PDF avec un bouton pour ouvrir le PDF
  Widget _buildPdfContent() {
    // Utiliser le chemin local si téléchargé, sinon utiliser le chemin asset
    final String pdfPath = _isDownloaded && _localPath != null
        ? _localPath!
        : (_lesson!.cheminFichier ?? 'assets/pdfs/css_flexbox.pdf');
    
    final bool isLocal = _isDownloaded && _localPath != null;

    return _buildInfoSection(
      title: 'Document PDF',
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              Icon(
                Icons.picture_as_pdf,
                size: 64,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              const Text(
                'Document PDF disponible',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _lesson!.description ?? 'Ouvrez le PDF pour consulter le contenu complet.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Bouton pour ouvrir le PDF
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PdfViewerScreen(
                          pdfAssetPath: isLocal ? '' : pdfPath,
                          pdfLocalPath: isLocal ? pdfPath : null,
                          lessonTitle: _lesson!.titre,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Ouvrir le PDF'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              // Bouton de téléchargement / suppression
              if (_downloadService.canDownload(_lesson!)) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: _isDownloading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : _isDownloaded
                          ? OutlinedButton.icon(
                              onPressed: _deleteDownload,
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Supprimer le téléchargement'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            )
                          : OutlinedButton.icon(
                              onPressed: _downloadLesson,
                              icon: const Icon(Icons.download),
                              label: const Text('Télécharger pour lecture hors-ligne'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Affiche le contenu vidéo avec un bouton pour lire la vidéo
  Widget _buildVideoContent() {
    // Utiliser le chemin local si téléchargé, sinon utiliser le chemin asset
    final String videoPath = _isDownloaded && _localPath != null
        ? _localPath!
        : (_lesson!.cheminFichier ?? 'assets/videos/javascript_variables.mp4');
    
    final bool isLocal = _isDownloaded && _localPath != null;

    return _buildInfoSection(
      title: 'Capsule Vidéo',
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              Icon(
                Icons.play_circle_outline,
                size: 64,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              const Text(
                'Vidéo disponible',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _lesson!.description ?? 'Regardez cette vidéo pour apprendre.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Bouton pour lire la vidéo
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => VideoPlayerScreen(
                          videoAssetPath: isLocal ? '' : videoPath,
                          videoLocalPath: isLocal ? videoPath : null,
                          lessonTitle: _lesson!.titre,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Lire la vidéo'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              // Bouton de téléchargement / suppression
              if (_downloadService.canDownload(_lesson!)) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: _isDownloading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : _isDownloaded
                          ? OutlinedButton.icon(
                              onPressed: _deleteDownload,
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Supprimer le téléchargement'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            )
                          : OutlinedButton.icon(
                              onPressed: _downloadLesson,
                              icon: const Icon(Icons.download),
                              label: const Text('Télécharger pour lecture hors-ligne'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Affiche un message pour les types non supportés
  Widget _buildUnsupportedContent(String type) {
    return Card(
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'Contenu $type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Le support pour les contenus de type $type sera disponible dans une prochaine version.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
