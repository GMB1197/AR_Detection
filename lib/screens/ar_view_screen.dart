import 'dart:async';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/material.dart';
import '../models/painting_model.dart';
import '../services/ar_service.dart';
import '../widgets/transparency_slider.dart';

class ARViewScreen extends StatefulWidget {
  final PaintingModel painting;

  const ARViewScreen({
    super.key,
    required this.painting,
  });

  @override
  State<ARViewScreen> createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen> {
  ARKitController? arkitController;
  bool imageDetected = false;
  String? cachedImageUrl;
  double transparency = 1.0;
  ARKitImageAnchor? currentAnchor;
  Timer? _debounceTimer;
  bool _isUpdatingAR = false;

  @override
  void initState() {
    super.initState();
    _preloadImage();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    arkitController?.dispose();
    super.dispose();
  }

  Future<void> _preloadImage() async {
    cachedImageUrl = await ARService.preloadImage(
      widget.painting.restoredImagePath,
    );
  }

  void _resetDetection() {
    // Cancella il timer attivo
    _debounceTimer?.cancel();

    // Rimuovi l'overlay
    try {
      arkitController?.remove('overlayFront');
    } catch (e) {
      debugPrint('Errore rimozione overlay: $e');
    }

    // Reset completo dello stato
    setState(() {
      imageDetected = false;
      transparency = 1.0;
      currentAnchor = null;
      _isUpdatingAR = false;
    });

    // Reinizializza il listener per anchor
    if (arkitController != null) {
      arkitController!.onAddNodeForAnchor = _handleAddAnchor;
    }

    debugPrint('Detection resettata per: ${widget.painting.title}');
    debugPrint('Pronto per nuovo rilevamento');
  }

  void _updateTransparency(double value) {
    // Aggiorna l'UI immediatamente per fluidità
    setState(() {
      transparency = value;
    });

    // Salta l'aggiornamento AR se uno è già in corso
    if (_isUpdatingAR) return;

    // Cancella il timer precedente
    _debounceTimer?.cancel();

    // Aggiorna l'AR con un debounce molto breve (16ms = ~60fps)
    _debounceTimer = Timer(const Duration(milliseconds: 16), () {
      if (imageDetected && currentAnchor != null && cachedImageUrl != null && arkitController != null) {
        _isUpdatingAR = true;

        try {
          ARService.updateOverlayTransparency(
            controller: arkitController!,
            anchor: currentAnchor!,
            painting: widget.painting,
            cachedImageUrl: cachedImageUrl!,
            transparency: value,
          );
        } catch (e) {
          debugPrint('Errore aggiornamento trasparenza: $e');
        } finally {
          _isUpdatingAR = false;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.painting.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          if (imageDetected)
            IconButton(
              tooltip: 'Reset rilevamento',
              icon: const Icon(Icons.refresh),
              onPressed: _resetDetection,
            ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          ARKitSceneView(
            detectionImagesGroupName: 'AR Resources',
            maximumNumberOfTrackedImages: 1,
            onARKitViewCreated: _onARKitViewCreated,
          ),

          if (!imageDetected) _buildInstructions(),

          if (imageDetected) _buildDetectionBanner(),

          if (imageDetected)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: TransparencySlider(
                value: transparency,
                onChanged: _updateTransparency,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              'Punta la fotocamera sulla cartolina di\n"${widget.painting.title}"',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Inquadra il quadro per vedere la versione restaurata',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectionBanner() {
    return Positioned(
      top: 10,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              '${widget.painting.title} rilevato!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Text(
              'Usa lo slider per confrontare',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _onARKitViewCreated(ARKitController controller) {
    arkitController = controller;
    arkitController!.onAddNodeForAnchor = _handleAddAnchor;

    debugPrint('ARKit inizializzato per: ${widget.painting.title}');
    debugPrint('In attesa di: ${widget.painting.referenceImageName}');
  }

  void _handleAddAnchor(ARKitAnchor anchor) {
    if (anchor is! ARKitImageAnchor) return;

    debugPrint('Image anchor rilevato: ${anchor.referenceImageName}');

    // Controlla se stiamo già tracciando un'immagine
    if (imageDetected) {
      debugPrint('Anchor già rilevato, ignoro nuovi anchor');
      return;
    }

    if (anchor.referenceImageName == widget.painting.referenceImageName) {
      debugPrint('MATCH! Quadro corretto rilevato');

      setState(() {
        imageDetected = true;
        currentAnchor = anchor;
      });

      if (cachedImageUrl != null && arkitController != null) {
        final overlay = ARService.buildOverlayNode(
          anchor: anchor,
          painting: widget.painting,
          cachedImageUrl: cachedImageUrl!,
          transparency: transparency,
        );
        arkitController!.add(overlay, parentNodeName: anchor.nodeName);
        debugPrint('Overlay aggiunto per: ${widget.painting.title}');
      }
    } else {
      debugPrint('Quadro diverso rilevato, ignorato');
    }
  }
}