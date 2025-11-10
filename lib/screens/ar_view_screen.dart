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
import '../widgets/transition_controls.dart';

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
  String? cachedImageUrl;            // per painting-9 = (non usato come overlay)
  String? cachedSecondaryImageUrl;
  double transparency = 1.0;
  ARKitImageAnchor? currentAnchor;
  Timer? _bannerTimer;
  bool _showBanner = false;
  bool _isARKitReady = false;
  bool _updateScheduled = false;
  bool _showInfo = false;

  // Hint "tocca gli stencil"
  bool _showHotspotHint = false;
  Timer? _hintTimer;

  // Transizione manuale per painting-10
  int _currentImageIndex = 0;
  List<String>? _cachedTransitionImages;

  ARKitNode? _overlayNode;          // overlay/stencil (altri dipinti)
  ARKitNode? _secondaryOverlayNode; // overlay secondario (altri dipinti)

  int? _selectedHotspot;
  List<String>? _cachedDetailImages;

  // Opacità del velo bianco (0=trasparente, 1=opaco)
  final double _whiteVeilAlpha = 0.45;

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
    _hintTimer?.cancel();
    arkitController?.dispose();
    super.dispose();
  }

  Future<void> _preloadImages() async {
    // Carico comunque (potrebbe servire altrove)
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

    // Pre-caricamento per transizione manuale (painting-10)
    if (widget.painting.alternateImagePaths != null) {
      _cachedTransitionImages = [];
      for (final p in widget.painting.alternateImagePaths!) {
        final c = await ARService.preloadImage(p);
        if (c != null) _cachedTransitionImages!.add(c);
      }
      debugPrint('${_cachedTransitionImages!.length} immagini di transizione precaricate');
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

    _hintTimer?.cancel();

    setState(() {
      imageDetected = false;
      _showBanner = false;
      _showInfo = false;
      _showHotspotHint = false;
      transparency = 1.0;
      currentAnchor = null;
      _overlayNode = null;
      _secondaryOverlayNode = null;
      _selectedHotspot = null;
      _currentImageIndex = 0;
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
    if (!imageDetected) return;
    try {
      if (_overlayNode?.geometry != null && cachedImageUrl != null) {
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
    final bool showSlider = !['painting-4','painting-6','painting-7','painting-8','painting-9','painting-10']
        .contains(widget.painting.id);
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    final bool isInfoPainting = widget.painting.id == 'painting-8';
    final bool isSpecialEffect = ['painting-4','painting-6','painting-7'].contains(widget.painting.id);
    final bool isInteractive = widget.painting.hasInteractiveHotspots == true;
    final bool isManualTransition = widget.painting.alternateImagePaths != null;

    String instructionText;
    if (isInfoPainting) {
      instructionText = 'Inquadra il quadro per scoprire la sua storia';
    } else if (isInteractive) {
      instructionText = 'Inquadra il quadro e tocca gli stencil';
    } else if (isManualTransition) {
      instructionText = 'Inquadra il quadro per il confronto manuale';
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
            enableTapRecognizer: true, // necessario per i tap
            onARKitViewCreated: _onARKitViewCreated,
          ),

          if (!_isARKitReady) _buildLoadingOverlay(),
          if (!imageDetected && _isARKitReady) _buildInstructions(isLandscape, instructionText),
          if (imageDetected && _showBanner) _buildDetectionBanner(),
          if (imageDetected && _showInfo && widget.painting.id == 'painting-8') _buildInfoPanel(),

          // Hint in basso (solo painting-9, nessun dettaglio aperto)
          if (imageDetected &&
              widget.painting.id == 'painting-9' &&
              _selectedHotspot == null &&
              _showHotspotHint)
            _buildBottomHotspotHint(isLandscape),

          if (_selectedHotspot != null) _buildHotspotDetailView(),

          if (imageDetected && showSlider && _selectedHotspot == null)
            (isLandscape ? _buildLandscapeSlider() : _buildPortraitSlider()),

          // Controlli per painting-10
          if (imageDetected && widget.painting.id == 'painting-10')
            TransitionControls(
              currentIndex: _currentImageIndex,
              totalImages: _cachedTransitionImages?.length ?? 0,
              artistNames: const ['Giorgione - Venere dormiente', 'Manet - Olympia'],
              onPrevious: () => _goToPreviousImage(animated: true),
              onNext: () => _goToNextImage(animated: true),
              isLandscape: isLandscape,
            ),
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

  // HINT in basso, non intercetta i tap (IgnorePointer), responsivo
  Widget _buildBottomHotspotHint(bool isLandscape) => Positioned(
    left: isLandscape ? 12 : 16,
    right: isLandscape ? 12 : 16,
    bottom: isLandscape ? 8 : 16,
    child: IgnorePointer(
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.touch_app, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Tocca gli stencil per vederli in dettaglio',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isLandscape ? 12 : 13.5,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
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
      debugPrint('Tap: $nodes');

      // Painting-10: tap sull'overlay per passare all'immagine successiva
      if (widget.painting.id == 'painting-10' && nodes.contains('overlayTransition')) {
        _goToNextImage(animated: true);
        debugPrint('Tap su overlay transizione - passo all\'immagine successiva');
        return;
      }

      // Painting-9: tap su hotspot
      for (final n in nodes) {
        final m1 = RegExp(r'detail_image_(\d+)').firstMatch(n);
        final m2 = RegExp(r'hit_area_(\d+)').firstMatch(n);
        final m = m1 ?? m2;
        if (m != null) {
          final idx = int.parse(m.group(1)!);
          setState(() {
            _selectedHotspot = idx;
            _showHotspotHint = false; // nascondi hint quando entro nel dettaglio
          });
          debugPrint('Open detail index=$idx (node=$n)');
          return;
        }
      }
      debugPrint('No hotspot recognized: $nodes');
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

      // Attiva hint per painting-9 e auto-hide dopo 6s
      if (widget.painting.id == 'painting-9') {
        setState(() => _showHotspotHint = true);
        _hintTimer?.cancel();
        _hintTimer = Timer(const Duration(seconds: 6), () {
          if (mounted) setState(() => _showHotspotHint = false);
        });
      }

      if (arkitController != null) {
        if (widget.painting.id == 'painting-4') {
          _createImmersiveChurchBackground(anchor);
        } else if (widget.painting.id == 'painting-8') {
          debugPrint('Painting-8 detected - info only');
        } else if (widget.painting.id == 'painting-9') {
          _createIconographyOverlays(anchor); // velo bianco + hotspot
        } else if (widget.painting.id == 'painting-10') {
          _createManualTransitionOverlay(anchor); // transizione manuale
        } else if (cachedImageUrl != null) {
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
            widget.painting.id != 'painting-9' &&
            widget.painting.id != 'painting-10') {
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

  // painting-9 — SOLO velo bianco + hotspot (mini-immagine + hit-area invisibile)
  void _createIconographyOverlays(ARKitImageAnchor anchor) {
    debugPrint('Iconography: SOLO HOTSPOTS (stencil nascosto, velo bianco)');

    final w  = anchor.referenceImagePhysicalSize.x * widget.painting.widthRatio;
    final h  = anchor.referenceImagePhysicalSize.y * widget.painting.heightRatio;
    final ox = widget.painting.offsetX;
    final oy = widget.painting.offsetY;
    final oz = widget.painting.offsetZ;

    // 1) VELO BIANCO (senza stencil)
    final bg = ARKitPlane(width: w, height: h);
    bg.materials.value = [
      ARKitMaterial(
        diffuse: ARKitMaterialProperty.color(Colors.white),
        transparency: _whiteVeilAlpha, // ← opacità velo bianco
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

    // 2) NIENTE overlay stencil

    // 3) HOTSPOT = mini-immagine + hit-area invisibile
    if (widget.painting.hotspots == null || _cachedDetailImages == null) return;

    for (int i = 0; i < widget.painting.hotspots!.length; i++) {
      final hs = widget.painting.hotspots![i];
      final dx = (hs['x'] as num?)?.toDouble() ?? 0.0; // percent of width
      final dy = (hs['y'] as num?)?.toDouble() ?? 0.0; // percent of height
      const double epsilon = 0.0002;

      // Posizione complanare al velo
      final localX = ox + (dx * w);
      final localY = oy + epsilon;
      final localZ = oz + (-dy * h);

      // Larghezze/Altezze per-hotspot dai dati (wPct/hPct) o fallback sizePct
      final wPct = (hs['wPct'] as num?)?.toDouble();
      final hPct = (hs['hPct'] as num?)?.toDouble();
      final sizePct = (hs['sizePct'] as num?)?.toDouble() ?? 0.22;

      late double planeW, planeH;
      if (wPct != null || hPct != null) {
        planeW = (wPct ?? sizePct) * w;
        planeH = (hPct ?? (wPct ?? sizePct)) * h;
      } else {
        final side = math.min(w, h) * sizePct; // quadrato
        planeW = side;
        planeH = side;
      }

      // --- Immagine di dettaglio (visibile e tappabile) ---
      if (_cachedDetailImages != null && i < _cachedDetailImages!.length) {
        final plane = ARKitPlane(width: planeW, height: planeH);
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
      }

      // --- Hit area invisibile (un filo di alpha) ---
      final hitW = planeW * 1.25;
      final hitH = planeH * 1.25;
      final hitPlane = ARKitPlane(width: hitW, height: hitH);
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
        position: vector.Vector3(localX, localY, localZ + 0.002), // davanti
        eulerAngles: vector.Vector3(0, math.pi / 2 + math.pi, 0),
        renderingOrder: 2060,
      );
      arkitController!.add(hitNode, parentNodeName: anchor.nodeName);
    }

    debugPrint('Velo bianco + ${widget.painting.hotspots!.length} HOTSPOTS creati');
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

  // painting-10 — Transizione manuale tra immagini multiple
  void _createManualTransitionOverlay(ARKitImageAnchor anchor) {
    debugPrint('Manual-transition: Setup transizione manuale tra ${_cachedTransitionImages?.length ?? 0} immagini');

    if (_cachedTransitionImages == null || _cachedTransitionImages!.isEmpty) {
      debugPrint('Errore: Nessuna immagine caricata per la transizione');
      return;
    }

    final baseW = anchor.referenceImagePhysicalSize.x * widget.painting.widthRatio;
    final baseH = anchor.referenceImagePhysicalSize.y * widget.painting.heightRatio;
    final ox = widget.painting.offsetX;
    final oy = widget.painting.offsetY;
    final oz = widget.painting.offsetZ;

    // Applica scale del primo elemento
    final firstScale = widget.painting.alternateScales?[0] ?? 1.0;
    final w = baseW * firstScale;
    final h = baseH * firstScale;

    // Crea il piano per l'overlay
    final plane = ARKitPlane(width: w, height: h);

    // Inizia con la prima immagine
    plane.materials.value = [
      ARKitMaterial(
        diffuse: ARKitMaterialProperty.image(_cachedTransitionImages![0]),
        transparency: 1.0,
        doubleSided: true,
        lightingModelName: ARKitLightingModel.constant,
      ),
    ];

    _overlayNode = ARKitNode(
      name: 'overlayTransition',
      geometry: plane,
      position: vector.Vector3(ox, oy, oz),
      eulerAngles: vector.Vector3(0, math.pi / 2 + math.pi, 0),
      renderingOrder: 2000,
    );

    arkitController!.add(_overlayNode!, parentNodeName: anchor.nodeName);

    // Inizializza l'indice alla prima immagine
    _currentImageIndex = 0;

    debugPrint('Transizione manuale creata: ${_cachedTransitionImages!.length} immagini');
  }

  // Aggiorna l'immagine dell'overlay con fade (e scale corretto)
  void _updateTransitionImage({bool animated = true}) {
    if (_overlayNode?.geometry == null ||
        _cachedTransitionImages == null ||
        _cachedTransitionImages!.isEmpty ||
        currentAnchor == null) {
      return;
    }

    final artistName = _currentImageIndex == 0 ? 'Giorgione' : 'Manet';
    debugPrint('Transizione a $_currentImageIndex ($artistName)');

    try {
      if (animated) {
        // Fade out
        _animateTransparency(1.0, 0.0, const Duration(milliseconds: 400), () {
          // Ricreo la geometria con lo scale corretto
          _recreateOverlayWithScale();

          // Attendo che il nuovo nodo sia aggiunto prima di fare fade in
          Future.delayed(const Duration(milliseconds: 50), () {
            if (mounted && _overlayNode != null) {
              // Fade in
              _animateTransparency(0.0, 1.0, const Duration(milliseconds: 400), null);
            }
          });
        });
      } else {
        // Cambio istantaneo senza animazione
        _recreateOverlayWithScale();
      }
    } catch (e) {
      debugPrint('Errore durante la transizione: $e');
    }
  }

  // Ricrea l'overlay con le dimensioni corrette per l'immagine corrente
  void _recreateOverlayWithScale() {
    if (currentAnchor == null) return;

    final baseW = currentAnchor!.referenceImagePhysicalSize.x * widget.painting.widthRatio;
    final baseH = currentAnchor!.referenceImagePhysicalSize.y * widget.painting.heightRatio;

    // Applica lo scale specifico per l'immagine corrente
    final scale = (widget.painting.alternateScales != null &&
        _currentImageIndex < widget.painting.alternateScales!.length)
        ? widget.painting.alternateScales![_currentImageIndex]
        : 1.0;

    final w = baseW * scale;
    final h = baseH * scale;

    // Rimuovi il vecchio nodo in modo sicuro
    try {
      arkitController?.remove('overlayTransition');
      debugPrint('Nodo vecchio rimosso');
    } catch (e) {
      debugPrint('Errore rimozione nodo: $e');
    }

    // Crea nuovo piano con dimensioni corrette
    final plane = ARKitPlane(width: w, height: h);
    plane.materials.value = [
      ARKitMaterial(
        diffuse: ARKitMaterialProperty.image(_cachedTransitionImages![_currentImageIndex]),
        transparency: 0.0, // Inizia trasparente per il fade in
        doubleSided: true,
        lightingModelName: ARKitLightingModel.constant,
      ),
    ];

    // Usa esattamente gli stessi offset configurati
    _overlayNode = ARKitNode(
      name: 'overlayTransition',
      geometry: plane,
      position: vector.Vector3(
        widget.painting.offsetX,
        widget.painting.offsetY,
        widget.painting.offsetZ,
      ),
      eulerAngles: vector.Vector3(0, math.pi * 1.5, 0), // 270° = pi * 1.5
      renderingOrder: 2000,
    );

    try {
      arkitController?.add(_overlayNode!, parentNodeName: currentAnchor!.nodeName);
      debugPrint('Nuovo nodo aggiunto con scale $scale (w: ${w.toStringAsFixed(3)}, h: ${h.toStringAsFixed(3)})');
    } catch (e) {
      debugPrint('Errore aggiunta nodo: $e');
    }
  }

  // Anima la trasparenza da startValue a endValue
  void _animateTransparency(double startValue, double endValue, Duration duration, VoidCallback? onComplete) {
    const steps = 20;
    final stepDuration = duration.inMilliseconds ~/ steps;
    int currentStep = 0;

    Timer.periodic(Duration(milliseconds: stepDuration), (timer) {
      if (!mounted || currentStep >= steps) {
        timer.cancel();
        if (onComplete != null) onComplete();
        return;
      }

      currentStep++;
      final progress = currentStep / steps;
      final currentValue = startValue + (endValue - startValue) * progress;

      try {
        if (_overlayNode?.geometry != null && _cachedTransitionImages != null) {
          _overlayNode!.geometry!.materials.value = [
            ARKitMaterial(
              diffuse: ARKitMaterialProperty.image(_cachedTransitionImages![_currentImageIndex]),
              transparency: currentValue,
              doubleSided: true,
              lightingModelName: ARKitLightingModel.constant,
            ),
          ];
        }
      } catch (_) {
        timer.cancel();
      }
    });
  }

  // Navigazione manuale - Immagine successiva
  void _goToNextImage({bool animated = true}) {
    if (_cachedTransitionImages == null) return;
    setState(() {
      _currentImageIndex = (_currentImageIndex + 1) % _cachedTransitionImages!.length;
    });
    _updateTransitionImage(animated: animated);
  }

  // Navigazione manuale - Immagine precedente
  void _goToPreviousImage({bool animated = true}) {
    if (_cachedTransitionImages == null) return;
    setState(() {
      _currentImageIndex = (_currentImageIndex - 1 + _cachedTransitionImages!.length) % _cachedTransitionImages!.length;
    });
    _updateTransitionImage(animated: animated);
  }
}