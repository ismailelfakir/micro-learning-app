import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

/// Écran d'affichage PDF intégré
/// 
/// Affiche un PDF depuis les assets locaux ou depuis le stockage local
class PdfViewerScreen extends StatefulWidget {
  final String pdfAssetPath;
  final String? pdfLocalPath;
  final String lessonTitle;

  const PdfViewerScreen({
    super.key,
    required this.pdfAssetPath,
    this.pdfLocalPath,
    required this.lessonTitle,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  PdfControllerPinch? _pdfController;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  /// Charge le PDF depuis les assets ou le stockage local
  Future<void> _loadPdf() async {
    try {
      // Utiliser le chemin local si disponible, sinon utiliser le chemin asset
      final Future<PdfDocument> pdfDocument;
      
      if (widget.pdfLocalPath != null && widget.pdfLocalPath!.isNotEmpty) {
        // Charger depuis le fichier local
        pdfDocument = PdfDocument.openFile(widget.pdfLocalPath!);
      } else {
        // Charger depuis les assets
        pdfDocument = PdfDocument.openAsset(widget.pdfAssetPath);
      }
      
      // Dans pdfx 2.9.2, PdfControllerPinch attend un Future<PdfDocument>
      _pdfController = PdfControllerPinch(
        document: pdfDocument,
      );
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Erreur lors du chargement du PDF: ${e.toString()}';
        });
      }
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
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
              : _pdfController != null
                  ? PdfViewPinch(
                      controller: _pdfController!,
                    )
                  : const Center(
                      child: Text('Erreur: Contrôleur PDF non initialisé'),
                    ),
    );
  }
}
