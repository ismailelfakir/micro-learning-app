import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Écran de lecture vidéo intégré
/// 
/// Lit une vidéo depuis les assets locaux ou depuis le stockage local avec contrôles de lecture
class VideoPlayerScreen extends StatefulWidget {
  final String videoAssetPath;
  final String? videoLocalPath;
  final String lessonTitle;

  const VideoPlayerScreen({
    super.key,
    required this.videoAssetPath,
    this.videoLocalPath,
    required this.lessonTitle,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  String? _error;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  /// Initialise le contrôleur vidéo
  Future<void> _initializeVideo() async {
    try {
      // Utiliser le chemin local si disponible, sinon utiliser le chemin asset
      if (widget.videoLocalPath != null && widget.videoLocalPath!.isNotEmpty) {
        // Charger depuis le fichier local
        _controller = VideoPlayerController.file(File(widget.videoLocalPath!));
      } else {
        // Charger depuis les assets
        _controller = VideoPlayerController.asset(widget.videoAssetPath);
      }
      
      await _controller!.initialize();
      
      // Écouter les changements d'état de lecture
      _controller!.addListener(() {
        if (mounted) {
          final isPlaying = _controller!.value.isPlaying;
          if (_isPlaying != isPlaying) {
            setState(() {
              _isPlaying = isPlaying;
            });
          }
        }
      });
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Erreur lors du chargement de la vidéo: ${e.toString()}';
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// Toggle play/pause
  void _togglePlayPause() {
    if (_controller == null) return;
    
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    });
  }

  /// Formate la durée en mm:ss
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lessonTitle),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Retour'),
                        ),
                      ],
                    ),
                  ),
                )
              : _controller != null
                  ? Column(
                      children: [
                        // Lecteur vidéo
                        AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: VideoPlayer(_controller!),
                        ),
                        
                        // Contrôles
                        Container(
                          color: Colors.black87,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // Barre de progression
                              VideoProgressIndicator(
                                _controller!,
                                allowScrubbing: true,
                                colors: VideoProgressColors(
                                  playedColor: Theme.of(context).primaryColor,
                                  bufferedColor: Colors.grey,
                                  backgroundColor: Colors.white24,
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Temps et bouton play/pause
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Temps
                                  ValueListenableBuilder(
                                    valueListenable: _controller!,
                                    builder: (context, VideoPlayerValue value, child) {
                                      return Text(
                                        '${_formatDuration(value.position)} / ${_formatDuration(value.duration)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      );
                                    },
                                  ),
                                  
                                  // Bouton play/pause
                                  IconButton(
                                    onPressed: _togglePlayPause,
                                    icon: Icon(
                                      _isPlaying ? Icons.pause : Icons.play_arrow,
                                      color: Colors.white,
                                      size: 36,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Description ou informations supplémentaires
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'À propos de cette vidéo',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Capsule vidéo de micro-learning',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Center(
                      child: Text('Erreur: Contrôleur vidéo non initialisé'),
                    ),
    );
  }
}
