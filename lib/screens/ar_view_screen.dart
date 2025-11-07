import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
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
  String? cachedImageUrl;            // per painting-9 = stencil
  String? cachedSecondaryImageUrl;
  double transparency = 1.0;
  ARKitImageAnchor? currentAnchor;
  Timer? _bannerTimer;
  bool _showBanner = false;
  bool _isARKitReady = false;
  bool _updateScheduled = false;
  bool _showInfo = false;

  ARKitNode? _overlayNode;          // overlay/stencil
  ARKitNode? _secondaryOverlayNode; // overlay secondario (altri dipinti)

  int? _selectedHotspot;
  List<String>? _cachedDetailImages;

  final String _painting8Info = """L'opera, realizzata nel 1518, ritrae al centro Papa Leone X, al secolo Giovanni de' Medici, seduto tra i suoi cugini cardinali Giulio de' Medici (futuro Papa Clemente VII) e Luigi de' Rossi.

• Il dipinto è noto per l'uso magistrale del colore, in particolare le varie sfumature di rosso, e per l'attenzione ai dettagli, come il riflesso della stanza sul pomello della sedia papale.
• Il papa è raffigurato con una lente d'ingrandimento in mano, un dettaglio che allude alla sua miopia, mentre si appoggia a un libro miniato.
• Il ritratto fu commissionato per essere inviato a Firenze in occasione delle nozze del nipote del papa, Lorenzo duca di Urbino, con Madeleine de La Tour d'Auvergne.
• L'opera originale è conservata presso le Gallerie degli Uffizi a Firenze, ma ne esistono diverse copie, tra cui una di Andrea del Sarto esposta al Museo di Capodimonte a Napoli.""";

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
    // Per painting-9: questa è l'immagine "stencil"
    cachedImageUrl = await ARService.preloadImage(widget.painting.restoredImagePath);

    if (widget.painting.secondaryOverlayPath != null) {
      cachedSecondaryImageUrl = await ARService.preloadImage(widget.painting.secondaryOverlayPath!);
    }

    if (widget.painting.hasInteractiveHotspots == true &&
        widget.painting.detailImagePaths != null) {
      _cachedDetailImages = [];
      for (final p in widget.painting.detailImagePaths!) {
        final c = await ARService.preloadImage(p);
        if (c != null) _cachedDetailImages!.add(c);
      }
      debugPrint('${_cachedDetailImages!.length} immagini dettaglio precaricate');
    }
  }

  void _resetDetection() {
    try {
      for (final name in [
        'overlayStencils',
        'overlaySecondary',
        'overlayFront',
        'overlayFixed',
        'churchBackground',
        'paintingInChurch',
        'backgroundDimmed',
        // hotspot nodes
        'detail_image_0','detail_image_1','detail_image_2','detail_image_3',
        'hit_area_0','hit_area_1','hit_area_2','hit_area_3',
      ]) {
        arkitController?.remove(name);
      }
    } catch (_) {}

    setState(() {
      imageDetected = false;
      _showBanner = false;
      _showInfo = false;
      transparency = 1.0;
      currentAnchor = null;
      _overlayNode = null;
      _secondaryOverlayNode = null;
      _selectedHotspot = null;
    });

    if (arkitController != null) {
      arkitController!.onAddNodeForAnchor = _handleAddAnchor;
    }
  }

  void _updateTransparency(double value) {
    setState(() => transparency = value);
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
      if (_overlayNode?.geometry != null) {
        _overlayNode!.geometry!.materials.value = [
          ARKitMaterial(
            diffuse: ARKitMaterialProperty.image(cachedImageUrl!),
            transparency: transparency,
            doubleSided: true,
            lightingModelName: ARKitLightingModel.constant,
          ),
        ];
      }
      if (_secondaryOverlayNode?.geometry != null && cachedSecondaryImageUrl != null) {
        _secondaryOverlayNode!.geometry!.materials.value = [
          ARKitMaterial(
            diffuse: ARKitMaterialProperty.image(cachedSecondaryImageUrl!),
            transparency: transparency,
            doubleSided: true,
            lightingModelName: ARKitLightingModel.constant,
          ),
        ];
      }
    } catch (e) {
      debugPrint('Errore aggiornamento materiale: $e');
    }
  }

  void _onSliderChangeEnd(double _) {}

  @override
  Widget build(BuildContext context) {
    final bool showSlider = !['painting-4','painting-6','painting-7','painting-8','painting-9']
        .contains(widget.painting.id);
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    final bool isInfoPainting = widget.painting.id == 'painting-8';
    final bool isSpecialEffect = ['painting-4','painting-6','painting-7'].contains(widget.painting.id);
    final bool isInteractive = widget.painting.hasInteractiveHotspots == true;

    String instructionText;
    if (isInfoPainting) {
      instructionText = 'Inquadra il quadro per scoprire la sua storia';
    } else if (isInteractive) {
      instructionText = 'Inquadra il quadro e tocca gli stencil';
    } else if (isSpecialEffect) {
      instructionText = 'Inquadra il quadro per vedere l\'effetto AR';
    } else {
      instructionText = 'Inquadra il quadro per vedere la versione restaurata';
    }

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
              onPressed: () => setState(() => _showInfo = !_showInfo),
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
            enableTapRecognizer: true, // ⬅️ necessario per i tap
            onARKitViewCreated: _onARKitViewCreated,
          ),

          if (!_isARKitReady) _buildLoadingOverlay(),
          if (!imageDetected && _isARKitReady) _buildInstructions(isLandscape, instructionText),
          if (imageDetected && _showBanner) _buildDetectionBanner(),
          if (imageDetected && _showInfo && widget.painting.id == 'painting-8') _buildInfoPanel(),

          if (_selectedHotspot != null) _buildHotspotDetailView(),

          if (imageDetected && showSlider && _selectedHotspot == null)
            (isLandscape ? _buildLandscapeSlider() : _buildPortraitSlider()),
        ],
      ),
    );
  }

  Widget _buildLandscapeSlider() => Positioned(
    right: 0, top: 0, bottom: 0,
    child: Center(
      child: TransparencySlider(
        value: transparency,
        onChanged: _updateTransparency,
        onChangeEnd: _onSliderChangeEnd,
      ),
    ),
  );

  Widget _buildPortraitSlider() => Positioned(
    bottom: 20, left: 0, right: 0,
    child: TransparencySlider(
      value: transparency,
      onChanged: _updateTransparency,
      onChangeEnd: _onSliderChangeEnd,
    ),
  );

  Widget _buildLoadingOverlay() => Container(
    color: Colors.black.withValues(alpha: 0.9),
    child: const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 3,
          ),
          SizedBox(height: 24),
          Text('Inizializzazione AR...', style: TextStyle(color: Colors.white)),
          SizedBox(height: 8),
          Text('Preparazione della fotocamera', style: TextStyle(color: Colors.white70)),
        ],
      ),
    ),
  );

  Widget _buildInstructions(bool isLandscape, String instructionText) => Positioned(
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
            style: TextStyle(color: Colors.white, fontSize: isLandscape ? 13 : 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isLandscape ? 6 : 8),
          Text(instructionText, style: TextStyle(color: Colors.white70, fontSize: isLandscape ? 10 : 12)),
        ],
      ),
    ),
  );

  Widget _buildDetectionBanner() {
    final bool isPainting8 = widget.painting.id == 'painting-8';
    final bool isInteractive = widget.painting.hasInteractiveHotspots == true;
    final bool showSlider = !['painting-4','painting-6','painting-7','painting-8','painting-9']
        .contains(widget.painting.id);

    String bannerSubtext;
    if (isPainting8) {
      bannerSubtext = 'Premi l\'icona info per i dettagli';
    } else if (isInteractive) {
      bannerSubtext = 'Tocca gli stencil per esplorare!';
    } else if (showSlider) {
      bannerSubtext = 'Usa lo slider per confrontare';
    } else {
      bannerSubtext = 'Effetto AR attivato!';
    }

    return Positioned(
      top: 10, left: 0, right: 0,
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
            Text('${widget.painting.title} rilevato!',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(bannerSubtext, style: const TextStyle(color: Colors.white70, fontSize: 14), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPanel() => Positioned(
    top: 80, left: 16, right: 16, bottom: 100,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 5)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.history_edu, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.painting.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(widget.painting.artist, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => setState(() => _showInfo = false)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Text(_painting8Info, style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.6)),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildHotspotDetailView() {
    if (_selectedHotspot == null || widget.painting.hotspots == null) return const SizedBox.shrink();
    final hotspot = widget.painting.hotspots![_selectedHotspot!];

    final detailImageUrl = _cachedDetailImages != null &&
        _selectedHotspot! < _cachedDetailImages!.length
        ? _cachedDetailImages![_selectedHotspot!]
        : null;

    return Container(
      color: Colors.black.withValues(alpha: 0.96),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () => setState(() => _selectedHotspot = null),
                  ),
                  Expanded(
                    child: Text(hotspot['title'] as String,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            if (detailImageUrl != null)
              Expanded(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.cyan.withValues(alpha: 0.3), blurRadius: 30, spreadRadius: 5)],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(File(Uri.parse(detailImageUrl).path), fit: BoxFit.contain),
                  ),
                ),
              ),
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Text(
                  hotspot['description'] as String,
                  style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ————— ARKit callbacks —————
  void _onARKitViewCreated(ARKitController controller) {
    arkitController = controller;
    arkitController!.onAddNodeForAnchor = _handleAddAnchor;

    // Tap gestito su immagini e hit-area invisibili
    arkitController!.onNodeTap = (List<String> nodes) {
      debugPrint('🔍 Tap: $nodes');
      for (final n in nodes) {
        final m1 = RegExp(r'detail_image_(\d+)').firstMatch(n);
        final m2 = RegExp(r'hit_area_(\d+)').firstMatch(n);
        final m = m1 ?? m2;
        if (m != null) {
          final idx = int.parse(m.group(1)!);
          setState(() => _selectedHotspot = idx);
          debugPrint('✅ Open detail index=$idx (node=$n)');
          return;
        }
      }
      debugPrint('⚠️ No hotspot recognized: $nodes');
    };

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _isARKitReady = true);
    });

    debugPrint('ARKit initialized for: ${widget.painting.title}');
    debugPrint('Waiting for: ${widget.painting.referenceImageName}');
  }

  void _handleAddAnchor(ARKitAnchor anchor) {
    if (anchor is! ARKitImageAnchor) return;

    debugPrint('Image anchor detected: ${anchor.referenceImageName}');
    if (imageDetected) return;

    if (anchor.referenceImageName == widget.painting.referenceImageName) {
      setState(() {
        imageDetected = true;
        _showBanner = true;
        currentAnchor = anchor;

        if (widget.painting.id == 'painting-8') {
          Future.delayed(const Duration(milliseconds: 2000), () {
            if (mounted && imageDetected) setState(() => _showInfo = true);
          });
        }
      });

      _bannerTimer?.cancel();
      _bannerTimer = Timer(const Duration(milliseconds: 2500), () {
        if (mounted) setState(() => _showBanner = false);
      });

      if (cachedImageUrl != null && arkitController != null) {
        if (widget.painting.id == 'painting-4') {
          _createImmersiveChurchBackground(anchor);
        } else if (widget.painting.id == 'painting-8') {
          debugPrint('Painting-8 detected - info only');
        } else if (widget.painting.id == 'painting-9') {
          _createIconographyOverlays(anchor); // ⭐
        } else {
          final overlay = ARService.buildOverlayNode(
            anchor: anchor,
            painting: widget.painting,
            cachedImageUrl: cachedImageUrl!,
            transparency: transparency,
          );
          arkitController!.add(overlay, parentNodeName: anchor.nodeName);
          _overlayNode = overlay;
        }

        if (widget.painting.secondaryOverlayPath != null &&
            cachedSecondaryImageUrl != null &&
            widget.painting.id != 'painting-9') {
          final secondaryOverlay = ARService.buildSecondaryOverlayNode(
            anchor: anchor,
            painting: widget.painting,
            cachedImageUrl: cachedSecondaryImageUrl!,
            transparency: transparency,
          );
          arkitController!.add(secondaryOverlay, parentNodeName: anchor.nodeName);
          _secondaryOverlayNode = secondaryOverlay;
        }
      }
    }
  }

  // ⭐ painting-9 — overlay + hotspot (mini-immagine + hit-area invisibile)
  void _createIconographyOverlays(ARKitImageAnchor anchor) {
    debugPrint('🎨 Iconography: overlay + clickable hotspots (no rings)');

    final w  = anchor.referenceImagePhysicalSize.x * widget.painting.widthRatio;
    final h  = anchor.referenceImagePhysicalSize.y * widget.painting.heightRatio;
    final ox = widget.painting.offsetX;
    final oy = widget.painting.offsetY;
    final oz = widget.painting.offsetZ;

    // 1) sfondo attenuato (opzionale: commenta se non serve)
    final bg = ARKitPlane(width: w, height: h);
    bg.materials.value = [
      ARKitMaterial(
        diffuse: ARKitMaterialProperty.image(widget.painting.damagedImagePath),
        transparency: 0.15,
        doubleSided: true,
        lightingModelName: ARKitLightingModel.constant,
      ),
    ];
    final bgNode = ARKitNode(
      name: 'backgroundDimmed',
      geometry: bg,
      position: vector.Vector3(ox, oy, oz),
      eulerAngles: vector.Vector3(0, math.pi / 2 + math.pi, 0),
    );
    arkitController!.add(bgNode, parentNodeName: anchor.nodeName);

    // 2) overlay stencil (complanare)
    if (cachedImageUrl != null) {
      final overlayPlane = ARKitPlane(width: w, height: h);
      overlayPlane.materials.value = [
        ARKitMaterial(
          diffuse: ARKitMaterialProperty.image(cachedImageUrl!),
          transparency: 1.0,
          doubleSided: true,
          lightingModelName: ARKitLightingModel.constant,
        ),
      ];
      final overlayNode = ARKitNode(
        name: 'overlayStencils',
        geometry: overlayPlane,
        position: vector.Vector3(ox, oy, oz + 0.0001),
        eulerAngles: vector.Vector3(0, math.pi / 2 + math.pi, 0),
      );
      arkitController!.add(overlayNode, parentNodeName: anchor.nodeName);
      _overlayNode = overlayNode;
    }

    // 3) hotspot = mini-immagine + hit-area invisibile
    if (widget.painting.hotspots == null || _cachedDetailImages == null) return;

    for (int i = 0; i < widget.painting.hotspots!.length; i++) {
      final hs = widget.painting.hotspots![i];
      final dx = (hs['x'] as num?)?.toDouble() ?? 0.0; // percent of width (-0.5..0.5 etc.)
      final dy = (hs['y'] as num?)?.toDouble() ?? 0.0; // percent of height
      const double epsilon = 0.0002;

      // mapping: X = ox + dx*w, Z = oz + (-dy*h), Y = oy + epsilon (piano)
      final localX = ox + (dx * w);
      final localY = oy + epsilon;
      final localZ = oz + (-dy * h);

      final size = math.min(w, h) * 0.22; // lato immagine
      if (i < _cachedDetailImages!.length) {
        final plane = ARKitPlane(width: size, height: size);
        plane.materials.value = [
          ARKitMaterial(
            diffuse: ARKitMaterialProperty.image(_cachedDetailImages![i]),
            transparency: 1.0,
            doubleSided: true,
            lightingModelName: ARKitLightingModel.constant,
          ),
        ];
        final node = ARKitNode(
          name: 'detail_image_$i',
          geometry: plane,
          position: vector.Vector3(localX, localY, localZ),
          eulerAngles: vector.Vector3(0, math.pi / 2 + math.pi, 0),
          renderingOrder: 2050,
        );
        arkitController!.add(node, parentNodeName: anchor.nodeName);
        debugPrint('✅ Added detail image $i @ local($localX,$localY,$localZ)');
      }

      // hit area invisibile (un filo di alpha per essere hittabile)
      final hitSize = size * 1.35;
      final hitPlane = ARKitPlane(width: hitSize, height: hitSize);
      hitPlane.materials.value = [
        ARKitMaterial(
          diffuse: ARKitMaterialProperty.color(Colors.white.withValues(alpha: 0.01)),
          transparency: 0.01,
          doubleSided: true,
          lightingModelName: ARKitLightingModel.constant,
        ),
      ];
      final hitNode = ARKitNode(
        name: 'hit_area_$i',
        geometry: hitPlane,
        position: vector.Vector3(localX, localY, localZ + 0.002), // davanti al dettaglio
        eulerAngles: vector.Vector3(0, math.pi / 2 + math.pi, 0),
        renderingOrder: 2060,
      );
      arkitController!.add(hitNode, parentNodeName: anchor.nodeName);
    }

    debugPrint('🎨 Overlay + ${widget.painting.hotspots!.length} HOTSPOTS creati');
  }

  // ————— Church effect (altri dipinti) —————
  void _createImmersiveChurchBackground(ARKitImageAnchor anchor) {
    final t = anchor.transform;
    final ax = t.getColumn(3).x;
    final ay = t.getColumn(3).y;
    final az = t.getColumn(3).z;

    final backgroundGeometry = ARKitPlane(width: 4.0, height: 6.0);
    final backgroundMaterial = ARKitMaterial(
      diffuse: ARKitMaterialProperty.image(cachedImageUrl!),
      transparency: 1.0,
      doubleSided: true,
    );

    final backgroundNode = ARKitNode(
      name: 'churchBackground',
      geometry: backgroundGeometry,
      position: vector.Vector3(ax, ay + 0.5, az - 1.5),
    );

    backgroundNode.geometry?.materials.value = [backgroundMaterial];
    arkitController!.add(backgroundNode);

    _addPaintingInChurch(anchor, ax, ay, az);
  }

  void _addPaintingInChurch(ARKitImageAnchor anchor, double ax, double ay, double az) {
    final paintingGeometry = ARKitPlane(width: 1.0, height: 1.7);
    final paintingMaterial = ARKitMaterial(
      diffuse: ARKitMaterialProperty.image(widget.painting.damagedImagePath),
      transparency: 1.0,
    );

    final paintingNode = ARKitNode(
      name: 'paintingInChurch',
      geometry: paintingGeometry,
      position: vector.Vector3(ax, ay - 1.0, az - 1.49),
    );

    paintingNode.geometry?.materials.value = [paintingMaterial];
    arkitController!.add(paintingNode);
  }
}
