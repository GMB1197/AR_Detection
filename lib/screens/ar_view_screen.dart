import 'dart:async';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
  Timer? _bannerTimer;
  bool _showBanner = false;
  bool _isARKitReady = false;
  bool _updateScheduled = false;
  bool _showInfo = false;

  // Mantieni riferimenti ai nodi per aggiornamenti diretti
  ARKitNode? _overlayNode;
  ARKitNode? _secondaryOverlayNode;

  // Informazioni specifiche per painting-8
  final String _painting8Info = '''L'opera, realizzata nel 1518, ritrae al centro Papa Leone X, al secolo Giovanni de' Medici, seduto tra i suoi cugini cardinali Giulio de' Medici (futuro Papa Clemente VII) e Luigi de' Rossi.

• Il dipinto è noto per l'uso magistrale del colore, in particolare le varie sfumature di rosso, e per l'attenzione ai dettagli, come il riflesso della stanza sul pomello della sedia papale.

• Il papa è raffigurato con una lente d'ingrandimento in mano, un dettaglio che allude alla sua miopia, mentre si appoggia a un libro miniato.

• Il ritratto fu commissionato per essere inviato a Firenze in occasione delle nozze del nipote del papa, Lorenzo duca di Urbino, con Madeleine de La Tour d'Auvergne.

• L'opera originale è conservata presso le Gallerie degli Uffizi a Firenze, ma ne esistono diverse copie, tra cui una di Andrea del Sarto esposta al Museo di Capodimonte a Napoli.''';

  @override
  void initState() {
    super.initState();
    _preloadImages();
  }

  @override
  void dispose() {
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
      _showInfo = false;
      transparency = 1.0;
      currentAnchor = null;
      _updateScheduled = false;
      _overlayNode = null;
      _secondaryOverlayNode = null;
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

    // Aggiorna immediatamente, senza throttling
    if (!_updateScheduled) {
      _updateScheduled = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _updateScheduled = false;
        _updateMaterialDirectly();
      });
    }
  }

  void _updateMaterialDirectly() {
    if (!imageDetected || cachedImageUrl == null) return;

    try {
      // Aggiorna SOLO il materiale del nodo esistente (velocissimo)
      if (_overlayNode?.geometry != null) {
        final material = ARKitMaterial(
          diffuse: ARKitMaterialProperty.image(cachedImageUrl!),
          doubleSided: true,
          transparency: transparency,
          lightingModelName: ARKitLightingModel.constant,
        );
        _overlayNode!.geometry!.materials.value = [material];
      }

      // Aggiorna anche il secondario se esiste
      if (_secondaryOverlayNode?.geometry != null && cachedSecondaryImageUrl != null) {
        final secondaryMaterial = ARKitMaterial(
          diffuse: ARKitMaterialProperty.image(cachedSecondaryImageUrl!),
          doubleSided: true,
          transparency: transparency,
          lightingModelName: ARKitLightingModel.constant,
        );
        _secondaryOverlayNode!.geometry!.materials.value = [secondaryMaterial];
      }
    } catch (e) {
      debugPrint('Errore aggiornamento materiale: $e');
    }
  }

  void _onSliderChangeEnd(double value) {
    // Tutto già aggiornato in tempo reale
  }

  @override
  Widget build(BuildContext context) {
    final bool showSlider = !['painting-4', 'painting-6', 'painting-7', 'painting-8'].contains(widget.painting.id);
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.painting.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          if (imageDetected && widget.painting.id == 'painting-8')
            IconButton(
              tooltip: 'Mostra/Nascondi info',
              icon: Icon(_showInfo ? Icons.info : Icons.info_outline),
              onPressed: () {
                setState(() {
                  _showInfo = !_showInfo;
                });
              },
            ),
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

          if (!_isARKitReady) _buildLoadingOverlay(),

          if (!imageDetected && _isARKitReady) _buildInstructions(isLandscape),

          if (imageDetected && _showBanner) _buildDetectionBanner(),

          // Info panel per painting-8
          if (imageDetected && _showInfo && widget.painting.id == 'painting-8')
            _buildInfoPanel(),

          if (imageDetected && showSlider)
            isLandscape
                ? _buildLandscapeSlider()
                : _buildPortraitSlider(),
        ],
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Positioned(
      top: 80,
      left: 16,
      right: 16,
      bottom: 100,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.history_edu,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.painting.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.painting.artist,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _showInfo = false;
                      });
                    },
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _painting8Info,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.6,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLandscapeSlider() {
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      child: Center(
        child: TransparencySlider(
          value: transparency,
          onChanged: _updateTransparency,
          onChangeEnd: _onSliderChangeEnd,
        ),
      ),
    );
  }

  Widget _buildPortraitSlider() {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: TransparencySlider(
        value: transparency,
        onChanged: _updateTransparency,
        onChangeEnd: _onSliderChangeEnd,
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'Inizializzazione AR...',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Preparazione della fotocamera',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions(bool isLandscape) {
    final bool isInfoPainting = widget.painting.id == 'painting-8';
    final bool isSpecialEffect = ['painting-4', 'painting-6', 'painting-7'].contains(widget.painting.id);

    String instructionText;
    if (isInfoPainting) {
      instructionText = 'Inquadra il quadro per scoprire la sua storia';
    } else if (isSpecialEffect) {
      instructionText = 'Inquadra il quadro per vedere l\'effetto AR';
    } else {
      instructionText = 'Inquadra il quadro per vedere la versione restaurata';
    }

    return Positioned(
      bottom: isLandscape ? 15 : 30,
      left: 0,
      right: isLandscape ? 80 : 0,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: isLandscape ? 12 : 20),
        padding: EdgeInsets.all(isLandscape ? 12 : 16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              'Punta la fotocamera sulla cartolina di\n"${widget.painting.title}"',
              style: TextStyle(
                color: Colors.white,
                fontSize: isLandscape ? 13 : 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isLandscape ? 6 : 8),
            Text(
              instructionText,
              style: TextStyle(
                color: Colors.white70,
                fontSize: isLandscape ? 10 : 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectionBanner() {
    final bool isPainting8 = widget.painting.id == 'painting-8';
    final bool showSlider = !['painting-4', 'painting-6', 'painting-7', 'painting-8'].contains(widget.painting.id);

    String bannerSubtext;
    if (isPainting8) {
      bannerSubtext = 'Premi l\'icona info per i dettagli';
    } else if (showSlider) {
      bannerSubtext = 'Usa lo slider per confrontare';
    } else {
      bannerSubtext = 'Effetto AR attivato!';
    }

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

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isARKitReady = true;
        });
      }
    });

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

        // Per painting-8, mostra automaticamente le info dopo 2 secondi
        if (widget.painting.id == 'painting-8') {
          Future.delayed(const Duration(milliseconds: 2000), () {
            if (mounted && imageDetected) {
              setState(() {
                _showInfo = true;
              });
            }
          });
        }
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
        if (widget.painting.id == 'painting-4') {
          _createImmersiveChurchBackground(anchor);
        } else if (widget.painting.id == 'painting-8') {
          // Per painting-8 non mostriamo overlay, solo le info
          debugPrint('Painting-8 rilevato - modalità solo info');
        } else {
          // Crea il nodo e SALVA il riferimento
          final overlay = ARService.buildOverlayNode(
            anchor: anchor,
            painting: widget.painting,
            cachedImageUrl: cachedImageUrl!,
            transparency: transparency,
          );
          arkitController!.add(overlay, parentNodeName: anchor.nodeName);
          _overlayNode = overlay; // SALVA riferimento!

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
          _secondaryOverlayNode = secondaryOverlay; // SALVA riferimento!

          debugPrint('Overlay secondario aggiunto');
        }
      }
    } else {
      debugPrint('Quadro diverso rilevato, ignorato');
    }
  }

  void _createImmersiveChurchBackground(ARKitImageAnchor anchor) {
    debugPrint('Creazione sfondo chiesa immersivo...');

    final anchorTransform = anchor.transform;
    final anchorX = anchorTransform.getColumn(3).x;
    final anchorY = anchorTransform.getColumn(3).y;
    final anchorZ = anchorTransform.getColumn(3).z;

    final backgroundGeometry = ARKitPlane(
      width: 4.0,
      height: 6.0,
    );

    final backgroundMaterial = ARKitMaterial(
      diffuse: ARKitMaterialProperty.image(cachedImageUrl!),
      transparency: 1.0,
      doubleSided: true,
    );

    final backgroundNode = ARKitNode(
      name: 'churchBackground',
      geometry: backgroundGeometry,
      position: vector.Vector3(
        anchorX,
        anchorY + 0.5,
        anchorZ - 1.5,
      ),
    );

    backgroundNode.geometry?.materials.value = [backgroundMaterial];
    arkitController!.add(backgroundNode);

    debugPrint('Sfondo chiesa creato e SGANCIATO dal marker');

    _addPaintingInChurch(anchor, anchorX, anchorY, anchorZ);
  }

  void _addPaintingInChurch(ARKitImageAnchor anchor, double anchorX, double anchorY, double anchorZ) {
    debugPrint('Aggiunta dipinto nel riquadro chiesa...');

    final paintingWidth = 1.0;
    final paintingHeight = 1.7;

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
        anchorX,
        anchorY - 1.0,
        anchorZ - 1.49,
      ),
    );

    paintingNode.geometry?.materials.value = [paintingMaterial];
    arkitController!.add(paintingNode);

    debugPrint('Dipinto posizionato nel riquadro!');
  }
}