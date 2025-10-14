import 'dart:async';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
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
  String? cachedSecondaryImageUrl;
  double transparency = 1.0;
  ARKitImageAnchor? currentAnchor;
  Timer? _debounceTimer;
  Timer? _bannerTimer;
  bool _showBanner = false;
  bool _isUpdatingAR = false;

  @override
  void initState() {
    super.initState();
    _preloadImages();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _bannerTimer?.cancel();
    arkitController?.dispose();
    super.dispose();
  }

  Future<void> _preloadImages() async {
    cachedImageUrl = await ARService.preloadImage(
      widget.painting.restoredImagePath,
    );

    if (widget.painting.secondaryOverlayPath != null) {
      cachedSecondaryImageUrl = await ARService.preloadImage(
        widget.painting.secondaryOverlayPath!,
      );
      debugPrint('Secondo overlay precaricato: $cachedSecondaryImageUrl');
    }
  }

  void _resetDetection() {
    _debounceTimer?.cancel();
    _bannerTimer?.cancel();

    try {
      arkitController?.remove('overlayFront');
      arkitController?.remove('overlaySecondary');
      arkitController?.remove('overlayFixed');
      arkitController?.remove('churchBackground');
      arkitController?.remove('paintingInChurch');
    } catch (e) {
      debugPrint('Errore rimozione overlay: $e');
    }

    setState(() {
      imageDetected = false;
      _showBanner = false;
      transparency = 1.0;
      currentAnchor = null;
      _isUpdatingAR = false;
    });

    if (arkitController != null) {
      arkitController!.onAddNodeForAnchor = _handleAddAnchor;
    }

    debugPrint('Detection resettata per: ${widget.painting.title}');
  }

  void _updateTransparency(double value) {
    setState(() {
      transparency = value;
    });

    if (_isUpdatingAR) return;

    _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 16), () {
      if (imageDetected && currentAnchor != null && cachedImageUrl != null && arkitController != null) {
        _isUpdatingAR = true;

        try {
          ARService.updateOverlayTransparency(
            controller: arkitController!,
            anchor: currentAnchor!,
            painting: widget.painting,
            cachedImageUrl: cachedImageUrl!,
            cachedSecondaryImageUrl: cachedSecondaryImageUrl,
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
    final bool showSlider = !['painting-4', 'painting-6', 'painting-7'].contains(widget.painting.id);

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

          if (imageDetected && _showBanner) _buildDetectionBanner(),

          if (imageDetected && showSlider)
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
    final bool isSpecialEffect = ['painting-4', 'painting-6', 'painting-7'].contains(widget.painting.id);
    final String instructionText = isSpecialEffect
        ? 'Inquadra il quadro per vedere l\'effetto AR'
        : 'Inquadra il quadro per vedere la versione restaurata';

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
            Text(
              instructionText,
              style: const TextStyle(
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
    final bool showSlider = !['painting-4', 'painting-6', 'painting-7'].contains(widget.painting.id);
    final String bannerSubtext = showSlider
        ? 'Usa lo slider per confrontare'
        : 'Effetto AR attivato!';

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
            Text(
              bannerSubtext,
              style: const TextStyle(
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

    if (imageDetected) {
      debugPrint('Anchor già rilevato, ignoro nuovi anchor');
      return;
    }

    if (anchor.referenceImageName == widget.painting.referenceImageName) {
      debugPrint('MATCH! Quadro corretto rilevato');

      setState(() {
        imageDetected = true;
        _showBanner = true;
        currentAnchor = anchor;
      });

      _bannerTimer?.cancel();
      _bannerTimer = Timer(const Duration(milliseconds: 2500), () {
        if (mounted) {
          setState(() {
            _showBanner = false;
          });
        }
      });

      if (cachedImageUrl != null && arkitController != null) {
        // LOGICA PER PAINTING-4: Sfondo immersivo fisso
        if (widget.painting.id == 'painting-4') {
          _createImmersiveChurchBackground(anchor);
        } else {
          // Comportamento normale per altri dipinti
          final overlay = ARService.buildOverlayNode(
            anchor: anchor,
            painting: widget.painting,
            cachedImageUrl: cachedImageUrl!,
            transparency: transparency,
          );
          arkitController!.add(overlay, parentNodeName: anchor.nodeName);
          debugPrint('Overlay normale aggiunto per: ${widget.painting.title}');
        }

        if (widget.painting.secondaryOverlayPath != null && cachedSecondaryImageUrl != null) {
          final secondaryOverlay = ARService.buildSecondaryOverlayNode(
            anchor: anchor,
            painting: widget.painting,
            cachedImageUrl: cachedSecondaryImageUrl!,
            transparency: transparency,
          );
          arkitController!.add(secondaryOverlay, parentNodeName: anchor.nodeName);
          debugPrint('Overlay secondario aggiunto');
        }
      }
    } else {
      debugPrint('Quadro diverso rilevato, ignorato');
    }
  }

  // METODO: Crea sfondo chiesa immersivo fisso
  void _createImmersiveChurchBackground(ARKitImageAnchor anchor) {
    debugPrint('Creazione sfondo chiesa immersivo...');

    // Ottieni la posizione iniziale del marker
    final anchorTransform = anchor.transform;
    final anchorX = anchorTransform.getColumn(3).x;
    final anchorY = anchorTransform.getColumn(3).y;
    final anchorZ = anchorTransform.getColumn(3).z;

    // SFONDO FISSO: Pannello gigante con la chiesa
    final backgroundGeometry = ARKitPlane(
      width: 4.0,  // 4 metri di larghezza
      height: 6.0, // 6 metri di altezza
    );

    final backgroundMaterial = ARKitMaterial(
      diffuse: ARKitMaterialProperty.image(cachedImageUrl!),
      transparency: 1.0,
      doubleSided: true,
    );

    // Crea il nodo dello sfondo
    final backgroundNode = ARKitNode(
      name: 'churchBackground',
      geometry: backgroundGeometry,
      position: vector.Vector3(
        anchorX,      // Stessa X del marker
        anchorY + 0.5, // Leggermente più in alto
        anchorZ - 1.5, // 1.5 metri davanti (verso l'utente)
      ),
    );

    // Applica il materiale
    backgroundNode.geometry?.materials.value = [backgroundMaterial];

    // IMPORTANTE: Aggiungi direttamente alla scena root (NON come figlio dell'anchor!)
    arkitController!.add(backgroundNode);

    debugPrint('Sfondo chiesa creato e SGANCIATO dal marker');
    debugPrint('Posizione fissa in coordinate world');
    debugPrint('Dimensioni: 4m x 6m');

    // Ora aggiungi il dipinto nel riquadro nero
    _addPaintingInChurch(anchor, anchorX, anchorY, anchorZ);
  }

  // METODO: Posiziona il dipinto nel riquadro della chiesa
  void _addPaintingInChurch(ARKitImageAnchor anchor, double anchorX, double anchorY, double anchorZ) {
    debugPrint('Aggiunta dipinto nel riquadro chiesa...');

    // Dimensioni del dipinto - più grande per coprire tutta l'area trasparente
    final paintingWidth = 1.0;   // Aumentato per larghezza
    final paintingHeight = 1.7;  // Aumentato per altezza

    final paintingGeometry = ARKitPlane(
      width: paintingWidth,
      height: paintingHeight,
    );

    final paintingMaterial = ARKitMaterial(
      diffuse: ARKitMaterialProperty.image(widget.painting.damagedImagePath),
      transparency: 1.0,
    );

    final paintingNode = ARKitNode(
      name: 'paintingInChurch',
      geometry: paintingGeometry,
      position: vector.Vector3(
        anchorX,        // Stessa X
        anchorY - 1.0,  // MOLTO PIÙ IN BASSO per coprire area trasparente
        anchorZ - 1.49, // Leggermente davanti alla chiesa (evita z-fighting)
      ),
    );

    // Applica il materiale
    paintingNode.geometry?.materials.value = [paintingMaterial];

    arkitController!.add(paintingNode);

    debugPrint('Dipinto posizionato nel riquadro!');
    debugPrint('Dimensioni: ${paintingWidth}m x ${paintingHeight}m');
    debugPrint('Posizione Y: ${anchorY - 1.8}');
  }
}