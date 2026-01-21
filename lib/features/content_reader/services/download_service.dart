import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import '../../../core/models/lesson.dart';
import '../../../core/models/download.dart';
import '../../../core/services/session_manager.dart';
import '../data/download_dao.dart';

/// Service de gestion des téléchargements pour mode offline
/// 
/// Responsabilités:
/// - Télécharger (copier) les fichiers depuis assets vers stockage local
/// - Supprimer les fichiers téléchargés
/// - Vérifier le statut de téléchargement
/// - Obtenir le chemin local d'un fichier téléchargé
class DownloadService {
  final DownloadDao _downloadDao = DownloadDao();
  final SessionManager _sessionManager = SessionManager();

  /// Télécharge une leçon (copie depuis assets vers stockage local)
  /// 
  /// Supporte uniquement les leçons de type PDF et VIDEO
  /// Retourne le chemin local du fichier téléchargé
  Future<String> downloadLesson(Lesson lesson) async {
    // Vérifier que la leçon a un type téléchargeable
    if (lesson.contenuType != 'PDF' && lesson.contenuType != 'VIDEO') {
      throw Exception('Seuls les contenus PDF et VIDEO peuvent être téléchargés');
    }

    // Vérifier que la leçon a un chemin de fichier
    if (lesson.cheminFichier == null || lesson.cheminFichier!.isEmpty) {
      throw Exception('La leçon n\'a pas de fichier associé');
    }

    // Récupérer l'utilisateur courant
    final int? userId = await _sessionManager.getCurrentUserId();
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }

    // Vérifier si déjà téléchargé
    final Download? existingDownload = await _downloadDao.getDownloadByUserAndLesson(userId, lesson.id!);
    if (existingDownload != null && existingDownload.statut == 'completed') {
      // Déjà téléchargé, retourner le chemin local
      if (existingDownload.cheminLocal != null) {
        final file = File(existingDownload.cheminLocal!);
        if (await file.exists()) {
          return existingDownload.cheminLocal!;
        }
        // Le fichier n'existe plus, on va le re-télécharger
        await _downloadDao.deleteDownload(existingDownload.id!);
      }
    }

    try {
      // Créer un enregistrement de téléchargement en cours
      final Download downloadRecord = Download(
        utilisateurId: userId,
        leconId: lesson.id!,
        dateTelechargement: DateTime.now(),
        statut: 'downloading',
        cheminLocal: null,
      );
      
      final int downloadId = await _downloadDao.createDownload(downloadRecord);

      // Copier le fichier depuis assets vers stockage local
      final String localPath = await _copyAssetToLocal(lesson.cheminFichier!, lesson.contenuType);

      // Mettre à jour l'enregistrement avec le statut 'completed'
      await _downloadDao.updateDownload(
        downloadRecord.copyWith(
          id: downloadId,
          statut: 'completed',
          cheminLocal: localPath,
        ),
      );

      return localPath;
    } catch (e) {
      // En cas d'erreur, mettre à jour le statut à 'failed'
      final Download? failedDownload = await _downloadDao.getDownloadByUserAndLesson(userId, lesson.id!);
      if (failedDownload != null) {
        await _downloadDao.updateDownload(
          failedDownload.copyWith(statut: 'failed'),
        );
      }
      
      throw Exception('Erreur lors du téléchargement: $e');
    }
  }

  /// Copie un fichier depuis assets vers le stockage local
  Future<String> _copyAssetToLocal(String assetPath, String contentType) async {
    // Obtenir le répertoire de documents de l'application
    final Directory appDir = await getApplicationDocumentsDirectory();
    
    // Créer un sous-dossier selon le type de contenu
    final String subfolder = contentType == 'PDF' ? 'pdfs' : 'videos';
    final Directory contentDir = Directory('${appDir.path}/$subfolder');
    
    // Créer le dossier s'il n'existe pas
    if (!await contentDir.exists()) {
      await contentDir.create(recursive: true);
    }

    // Extraire le nom du fichier depuis le chemin asset
    final String fileName = assetPath.split('/').last;
    final String localPath = '${contentDir.path}/$fileName';

    // Vérifier si le fichier existe déjà
    final File localFile = File(localPath);
    if (await localFile.exists()) {
      // Le fichier existe déjà, pas besoin de le recopier
      return localPath;
    }

    // Charger le fichier depuis assets
    final ByteData data = await rootBundle.load(assetPath);
    final List<int> bytes = data.buffer.asUint8List();

    // Écrire le fichier dans le stockage local
    await localFile.writeAsBytes(bytes);

    return localPath;
  }

  /// Supprime le téléchargement d'une leçon
  /// 
  /// Supprime le fichier local et l'enregistrement de la base de données
  Future<void> deleteDownload(Lesson lesson) async {
    final int? userId = await _sessionManager.getCurrentUserId();
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }

    // Récupérer l'enregistrement de téléchargement
    final Download? download = await _downloadDao.getDownloadByUserAndLesson(userId, lesson.id!);
    if (download == null) {
      return; // Pas de téléchargement à supprimer
    }

    // Supprimer le fichier local s'il existe
    if (download.cheminLocal != null) {
      final File file = File(download.cheminLocal!);
      if (await file.exists()) {
        await file.delete();
      }
    }

    // Supprimer l'enregistrement de la base de données
    await _downloadDao.deleteDownloadByUserAndLesson(userId, lesson.id!);
  }

  /// Vérifie si une leçon est téléchargée
  Future<bool> isLessonDownloaded(Lesson lesson) async {
    final int? userId = await _sessionManager.getCurrentUserId();
    if (userId == null) {
      return false;
    }

    return await _downloadDao.isLessonDownloaded(userId, lesson.id!);
  }

  /// Obtient le chemin local d'une leçon téléchargée
  /// 
  /// Retourne null si la leçon n'est pas téléchargée ou si le fichier n'existe pas
  Future<String?> getLocalPath(Lesson lesson) async {
    final int? userId = await _sessionManager.getCurrentUserId();
    if (userId == null) {
      return null;
    }

    final Download? download = await _downloadDao.getDownloadByUserAndLesson(userId, lesson.id!);
    if (download == null || download.statut != 'completed') {
      return null;
    }

    // Vérifier que le fichier existe toujours
    if (download.cheminLocal != null) {
      final File file = File(download.cheminLocal!);
      if (await file.exists()) {
        return download.cheminLocal;
      }
    }

    return null;
  }

  /// Vérifie si une leçon peut être téléchargée
  bool canDownload(Lesson lesson) {
    return (lesson.contenuType == 'PDF' || lesson.contenuType == 'VIDEO') &&
        lesson.cheminFichier != null &&
        lesson.cheminFichier!.isNotEmpty;
  }

  /// Récupère toutes les leçons téléchargées par l'utilisateur courant
  Future<List<Download>> getUserDownloads() async {
    final int? userId = await _sessionManager.getCurrentUserId();
    if (userId == null) {
      return [];
    }

    return await _downloadDao.getCompletedDownloadsByUser(userId);
  }

  /// Compte le nombre de téléchargements complétés de l'utilisateur courant
  Future<int> getDownloadCount() async {
    final int? userId = await _sessionManager.getCurrentUserId();
    if (userId == null) {
      return 0;
    }

    return await _downloadDao.countCompletedDownloads(userId);
  }
}
