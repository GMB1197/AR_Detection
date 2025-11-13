import 'dart:async';
import 'dart:math' as math;

import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

import '../data/paintings_data.dart';
import '../models/painting_model.dart';
import '../services/ar_service.dart';

import '../widgets/transparency_slider.dart';
import '../widgets/transition_controls.dart';
import '../widgets/info_overlay_panel.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/instructions_card.dart';
import '../widgets/detection_banner.dart';
import '../widgets/alt_info_fab.dart';
import '../widgets/hotspot_hint.dart';
import '../widgets/hotspot_detail_view.dart';

class ARViewScreen extends StatefulWidget {
  final PaintingModel? painting;

  const ARViewScreen({super.key, this.painting});

  @override
  State<ARViewScreen> createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen> {
  ARKitController? arkitController;
  Key _arViewKey = UniqueKey();
  bool imageDetected = false;

  String? cachedImageUrl;
  String? cachedSecondaryImageUrl;
  double transparency = 1.0;
  ARKitImageAnchor? currentAnchor;
  Timer? _bannerTimer;
  bool _showBanner = false;
  bool _isARKitReady = false;
  bool _updateScheduled = false;

  bool _showInfo = false;      // pannello info painting-8
  bool _showAltInfo = false;   // pannello info immagini alternate (6/10)

  PaintingModel? currentPainting;

  bool _showHotspotHint = false;
  Timer? _hintTimer;

  int _currentImageIndex = 0;
  List<String>? _cachedTransitionImages;

  ARKitNode? _overlayNode;
  ARKitNode? _secondaryOverlayNode;

  int? _selectedHotspot;
  List<String>? _cachedDetailImages;

  final double _whiteVeilAlpha = 0.45;

  PaintingModel? get painting => widget.painting ?? currentPainting;

  @override
  void initState() {
    super.initState();
    if (widget.painting != null) {
      _preloadImages();
    }
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _hintTimer?.cancel();
    arkitController?.dispose();
    super.dispose();
  }

  Future<void> _preloadImages() async {
    final paintingToLoad = painting;
    if (paintingToLoad == null) return;

    if (paintingToLoad.alternateImages == null) {
      cachedImageUrl = await ARService.preloadImage(paintingToLoad.restoredImagePath);
    } else {
      cachedImageUrl = null;
    }

    if (paintingToLoad.secondaryOverlayPath != null) {
      cachedSecondaryImageUrl = await ARService.preloadImage(paintingToLoad.secondaryOverlayPath!);
    }

    if (paintingToLoad.hasInteractiveHotspots == true &&
        paintingToLoad.detailImagePaths != null) {
      _cachedDetailImages = [];
      for (final p in paintingToLoad.detailImagePaths!) {
        final c = await ARService.preloadImage(p);
        if (c != null) _cachedDetailImages!.add(c);
      }
    }

    if (paintingToLoad.alternateImages != null) {
      _cachedTransitionImages = [];
      for (final img in paintingToLoad.alternateImages!) {
        final path = img['path'] as String;
        final c = await ARService.preloadImage(path);
        if (c != null) _cachedTransitionImages!.add(c);
      }
    }
  }

  void _clearOverlayNodesLight() {
    try {
      for (final name in [
        'overlayStencils','overlaySecondary','overlayFront','overlayFixed',
        'churchBackground','paintingInChurch','backgroundDimmed',
        'overlayTransition',
        'detail_image_0','detail_image_1','detail_image_2','detail_image_3',
        'hit_area_0','hit_area_1','hit_area_2','hit_area_3',
      ]) {
        arkitController?.remove(name);
      }
    } catch (_) {}
    _selectedHotspot = null;
    _showInfo = false;
    _showAltInfo = false;
    _showHotspotHint = false;
    _overlayNode = null;
    _secondaryOverlayNode = null;
  }

  void _resetDetection() {
    try {
      for (final name in [
        'overlayStencils','overlaySecondary','overlayFront','overlayFixed',
        'churchBackground','paintingInChurch','backgroundDimmed','overlayTransition',
        'detail_image_0','detail_image_1','detail_image_2','detail_image_3',
        'hit_area_0','hit_area_1','hit_area_2','hit_area_3',
      ]) {
        arkitController?.remove(name);
      }
    } catch (_) {}

    _hintTimer?.cancel();
    _bannerTimer?.cancel();

    try { arkitController?.dispose(); } catch (_) {}
    arkitController = null;

    setState(() {
      imageDetected = false;
      _showBanner = false;
      _showInfo = false;
      _showAltInfo = false;
      _showHotspotHint = false;
      transparency = 1.0;
      currentAnchor = null;
      _overlayNode = null;
      _secondaryOverlayNode = null;
      _selectedHotspot = null;
      _currentImageIndex = 0;

      if (widget.painting == null) {
        currentPainting = null;
        cachedImageUrl = null;
        cachedSecondaryImageUrl = null;
        _cachedDetailImages = null;
        _cachedTransitionImages = null;
      }

      _isARKitReady = false;
      _arViewKey = UniqueKey();
    });
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
    final currentPaintingModel = painting;

    final bool showSlider;
    final bool isSpecialEffect;
    if (currentPaintingModel != null) {
      showSlider = !['painting-4','painting-6','painting-7','painting-8','painting-9','painting-10']
          .contains(currentPaintingModel.id);
      isSpecialEffect = ['painting-4','painting-7'].contains(currentPaintingModel.id);
    } else {
      showSlider = false;
      isSpecialEffect = false;
    }

    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final bool isInfoPainting = currentPaintingModel?.id == 'painting-8';
    final bool isInteractive = currentPaintingModel?.hasInteractiveHotspots == true;
    final bool isManualTransition = currentPaintingModel?.alternateImages != null;
    final bool isPainting10 = currentPaintingModel?.id == 'painting-10';
    final bool isPainting6  = currentPaintingModel?.id == 'painting-6';
    final bool isManualSwitcher = isPainting10 || isPainting6;

    String appBarTitle;
    if (currentPaintingModel != null) {
      appBarTitle = currentPaintingModel.title;
    } else if (widget.painting == null && !imageDetected) {
      appBarTitle = 'Scansiona un dipinto';
    } else {
      appBarTitle = 'AR Museum';
    }

    String instructionText;
    if (currentPaintingModel == null) {
      instructionText = 'Inquadra un qualsiasi dipinto per scoprire i contenuti AR';
    } else if (isInfoPainting) {
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

    // Nomi per i pulsanti del selettore manuale (6/10)
    final List<String> artistNames = isManualSwitcher
        ? ((currentPaintingModel?.alternateImages ?? const [])
        .map<String>((img) => (img['title'] as String?) ?? '')
        .toList())
        : const [];

    // Info per pannello alternate
    final altMaps = currentPaintingModel?.alternateImages;
    final int altLen = altMaps?.length ?? 0;
    final int safeIdx = altLen == 0 ? 0 : _currentImageIndex.clamp(0, altLen - 1);
    final Map<String, dynamic>? alt = altLen > 0 ? altMaps![safeIdx] : null;
    final String altTitle = alt?['title'] as String? ?? 'Versione di confronto';
    final String altSubtitle = (alt?['subtitle'] as String?) ?? (alt?['source'] as String?) ?? '';
    final String altDesc = (alt?['info'] as String?) ?? 'Scheda informativa in aggiornamento.';

    // Testo banner detection
    String bannerSubtext = 'Effetto AR attivato!';
    if (currentPaintingModel != null) {
      final bool showSliderBanner = !['painting-4','painting-6','painting-7','painting-8','painting-9']
          .contains(currentPaintingModel.id);
      if (isInfoPainting) {
        bannerSubtext = 'Premi l\'icona info per i dettagli';
      } else if (isInteractive) {
        bannerSubtext = 'Tocca gli stencil per esplorare!';
      } else if (showSliderBanner) {
        bannerSubtext = 'Usa lo slider per confrontare';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          if (imageDetected && currentPaintingModel?.id == 'painting-8')
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
            key: _arViewKey,
            detectionImagesGroupName: 'AR Resources',
            maximumNumberOfTrackedImages: 2,
            enableTapRecognizer: true,
            onARKitViewCreated: _onARKitViewCreated,
          ),

          if (!_isARKitReady) const LoadingOverlay(),

          if (!imageDetected && _isARKitReady)
            InstructionsCard(
              isLandscape: isLandscape,
              instructionText: instructionText,
              targetTitle: painting?.title,
            ),

          if (imageDetected && _showBanner)
            DetectionBanner(
              title: painting?.title ?? 'Dipinto',
              subtitle: bannerSubtext,
            ),

          // Pannello info painting-8
          if (imageDetected && currentPaintingModel?.id == 'painting-8' && _showInfo)
            InfoOverlayPanel(
              title: painting?.title ?? '',
              subtitle: painting?.artist,
              body: painting?.info ?? painting?.description ?? '',
              leadingIcon: Icons.history_edu,
              onClose: () => setState(() => _showInfo = false),
            ),

          // FAB Info per immagini alternate (6/10)
          if (imageDetected && isManualSwitcher && (_cachedTransitionImages?.isNotEmpty ?? false))
            AltInfoFab(
              isLandscape: isLandscape,
              onTap: () => setState(() => _showAltInfo = !_showAltInfo),
              highlighted: _showAltInfo,
            ),

          // Pannello info per l'immagine alternate corrente
          if (imageDetected && isManualSwitcher && _showAltInfo)
            InfoOverlayPanel(
              title: altTitle,
              subtitle: altSubtitle.isEmpty ? null : altSubtitle,
              body: altDesc,
              leadingIcon: Icons.image,
              onClose: () => setState(() => _showAltInfo = false),
            ),

          // Hint hotspot (p-9)
          if (imageDetected &&
              currentPaintingModel?.id == 'painting-9' &&
              _selectedHotspot == null &&
              _showHotspotHint)
            HotspotHint(isLandscape: isLandscape),

          // Dettaglio hotspot
          if (_selectedHotspot != null)
            _buildHotspotDetailView(),

          // Slider trasparenza quando non ho transizione manuale o hotspot aperti
          if (imageDetected && showSlider && _selectedHotspot == null)
            (isLandscape ? _buildLandscapeSlider() : _buildPortraitSlider()),

          // Controlli transizione manuale (6/10)
          if (imageDetected && isManualSwitcher)
            TransitionControls(
              currentIndex: _currentImageIndex,
              totalImages: _cachedTransitionImages?.length ?? 0,
              artistNames: artistNames,
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

  // ————— ARKit callbacks —————
  void _onARKitViewCreated(ARKitController controller) {
    arkitController = controller;
    arkitController!.onAddNodeForAnchor = _handleAddAnchor;

    arkitController!.onNodeTap = (List<String> nodes) {
      debugPrint('Tap: $nodes');

      final pid = painting?.id;
      if ((pid == 'painting-10' || pid == 'painting-6') && nodes.contains('overlayTransition')) {
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
            _showHotspotHint = false;
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

    final wp = widget.painting;
    if (wp != null) {
      debugPrint('ARKit initialized for: ${wp.title}');
      debugPrint('Waiting for: ${wp.referenceImageName}');
    } else {
      debugPrint('ARKit initialized in universal mode - waiting for any painting');
    }
  }

  void _handleAddAnchor(ARKitAnchor anchor) async {
    if (anchor is! ARKitImageAnchor) return;

    final newRefName = anchor.referenceImageName ?? '';
    final currentRefName = currentAnchor?.referenceImageName ?? '';

    PaintingModel? matchedPainting;
    final wp = widget.painting;
    if (wp != null) {
      if (newRefName == wp.referenceImageName) {
        matchedPainting = wp;
      } else {
        return;
      }
    } else {
      matchedPainting = PaintingsData.getPaintingByReferenceName(newRefName);
    }

    if (matchedPainting == null) return;

    // Per painting-4, rimuoviamo e ricarichiamo sempre i nodi per aggiornare la posizione
    final isPainting4 = matchedPainting.id == 'painting-4';

    if (imageDetected && newRefName == currentRefName) {
      if (isPainting4) {
        debugPrint('Painting-4 rilevato di nuovo - ricreo i nodi con nuove coordinate');
        _clearOverlayNodesLight();
        // Non ritorniamo, continuiamo per ricreare i nodi
      } else {
        debugPrint('Anchor per lo stesso dipinto già attivo: $newRefName');
        return;
      }
    }

    final switching = imageDetected && widget.painting == null && newRefName != currentRefName && !isPainting4;
    if (switching) {
      debugPrint('Switch a nuovo dipinto: $newRefName (da $currentRefName)');
      _clearOverlayNodesLight();
    } else {
      debugPrint('Primo dipinto riconosciuto: $newRefName');
    }

    setState(() {
      imageDetected = true;
      _showBanner = true;
      currentAnchor = anchor;
      currentPainting = matchedPainting;
    });

    await _preloadImages();

    _bannerTimer?.cancel();
    _bannerTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _showBanner = false);
    });

    final isPainting4  = matchedPainting.id == 'painting-4';
    final isPainting8  = matchedPainting.id == 'painting-8';
    final isPainting9  = matchedPainting.id == 'painting-9';
    final isPainting10 = matchedPainting.id == 'painting-10';
    final isPainting6  = matchedPainting.id == 'painting-6';

    if (isPainting8) {
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted && imageDetected) setState(() => _showInfo = true);
      });
    }
    if (isPainting9) {
      setState(() => _showHotspotHint = true);
      _hintTimer?.cancel();
      _hintTimer = Timer(const Duration(seconds: 6), () {
        if (mounted) setState(() => _showHotspotHint = false);
      });
    }

    final controller = arkitController;
    if (controller == null) return;

    if (isPainting4) {
      _createImmersiveChurchBackground(anchor);
    } else if (isPainting8) {
      debugPrint('Painting-8 detected - info only');
    } else if (isPainting9) {
      _createIconographyOverlays(anchor);
    } else if (isPainting10 || isPainting6) {
      _createManualTransitionOverlay(anchor);
    } else if (cachedImageUrl != null) {
      final overlay = ARService.buildOverlayNode(
        anchor: anchor,
        painting: matchedPainting,
        cachedImageUrl: cachedImageUrl!,
        transparency: transparency,
      );
      controller.add(overlay, parentNodeName: anchor.nodeName);
      _overlayNode = overlay;
    }

    if (matchedPainting.secondaryOverlayPath != null &&
        cachedSecondaryImageUrl != null &&
        !isPainting9 &&
        !(isPainting10 || isPainting6)) {
      final secondaryOverlay = ARService.buildSecondaryOverlayNode(
        anchor: anchor,
        painting: matchedPainting,
        cachedImageUrl: cachedSecondaryImageUrl!,
        transparency: transparency,
      );
      controller.add(secondaryOverlay, parentNodeName: anchor.nodeName);
      _secondaryOverlayNode = secondaryOverlay;
    }
  }

  void _createIconographyOverlays(ARKitImageAnchor anchor) {
    debugPrint('Iconography: SOLO HOTSPOTS (stencil nascosto, velo bianco)');
    final cp = painting;
    if (cp == null) return;

    final w  = anchor.referenceImagePhysicalSize.x * cp.widthRatio;
    final h  = anchor.referenceImagePhysicalSize.y * cp.heightRatio;
    final ox = cp.offsetX;
    final oy = cp.offsetY;
    final oz = cp.offsetZ;

    final bg = ARKitPlane(width: w, height: h);
    bg.materials.value = [
      ARKitMaterial(
        diffuse: ARKitMaterialProperty.color(Colors.white),
        transparency: _whiteVeilAlpha,
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

    if (cp.hotspots == null || _cachedDetailImages == null) return;

    for (int i = 0; i < cp.hotspots!.length; i++) {
      final hs = cp.hotspots![i];
      final dx = (hs['x'] as num?)?.toDouble() ?? 0.0;
      final dy = (hs['y'] as num?)?.toDouble() ?? 0.0;
      const double epsilon = 0.0002;

      final localX = ox + (dx * w);
      final localY = oy + epsilon;
      final localZ = oz + (-dy * h);

      final wPct = (hs['wPct'] as num?)?.toDouble();
      final hPct = (hs['hPct'] as num?)?.toDouble();
      final sizePct = (hs['sizePct'] as num?)?.toDouble() ?? 0.22;

      late double planeW, planeH;
      if (wPct != null || hPct != null) {
        planeW = (wPct ?? sizePct) * w;
        planeH = (hPct ?? (wPct ?? sizePct)) * h;
      } else {
        final side = math.min(w, h) * sizePct;
        planeW = side;
        planeH = side;
      }

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
        position: vector.Vector3(localX, localY, localZ + 0.002),
        eulerAngles: vector.Vector3(0, math.pi / 2 + math.pi, 0),
        renderingOrder: 2060,
      );
      arkitController!.add(hitNode, parentNodeName: anchor.nodeName);
    }

    debugPrint('Velo bianco + ${cp.hotspots!.length} HOTSPOTS creati');
  }

  void _createImmersiveChurchBackground(ARKitImageAnchor anchor) {
    final t = anchor.transform;
    final ax = t.getColumn(3).x;
    final ay = t.getColumn(3).y;
    final az = t.getColumn(3).z;

    final bgUrl = cachedImageUrl;
    if (bgUrl == null) {
      debugPrint('Nessuna immagine background caricata');
      return;
    }

    final backgroundGeometry = ARKitPlane(width: 4.0, height: 6.0);
    final backgroundMaterial = ARKitMaterial(
      diffuse: ARKitMaterialProperty.image(bgUrl),
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
    final cp = painting;
    if (cp == null) return;

    final paintingGeometry = ARKitPlane(width: 1.0, height: 1.7);
    final paintingMaterial = ARKitMaterial(
      diffuse: ARKitMaterialProperty.image(cp.damagedImagePath),
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

  void _createManualTransitionOverlay(ARKitImageAnchor anchor) {
    debugPrint('Manual-transition: Setup transizione manuale tra ${_cachedTransitionImages?.length ?? 0} immagini');

    final cp = painting;
    if (cp == null) return;

    if (_cachedTransitionImages == null || _cachedTransitionImages!.isEmpty) {
      debugPrint('Errore: Nessuna immagine caricata per la transizione');
      return;
    }
    if (cp.alternateImages == null || cp.alternateImages!.isEmpty) {
      debugPrint('Errore: Nessuna configurazione alternateImages');
      return;
    }

    final baseW = anchor.referenceImagePhysicalSize.x;
    final baseH = anchor.referenceImagePhysicalSize.y;

    final firstImg = cp.alternateImages![0];
    final widthRatio = (firstImg['widthRatio'] as num?)?.toDouble() ?? cp.widthRatio;
    final heightRatio = (firstImg['heightRatio'] as num?)?.toDouble() ?? cp.heightRatio;
    final offsetX = (firstImg['offsetX'] as num?)?.toDouble() ?? cp.offsetX;
    final offsetY = (firstImg['offsetY'] as num?)?.toDouble() ?? cp.offsetY;
    final offsetZ = (firstImg['offsetZ'] as num?)?.toDouble() ?? cp.offsetZ;

    final w = baseW * widthRatio;
    final h = baseH * heightRatio;

    final plane = ARKitPlane(width: w, height: h);
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
      position: vector.Vector3(offsetX, offsetY, offsetZ),
      eulerAngles: vector.Vector3(0, math.pi / 2 + math.pi, 0),
      renderingOrder: 2000,
    );

    arkitController!.add(_overlayNode!, parentNodeName: anchor.nodeName);
    _currentImageIndex = 0;

    debugPrint('Transizione manuale creata: ${_cachedTransitionImages!.length} immagini '
        '(prima: w=${w.toStringAsFixed(3)}m, h=${h.toStringAsFixed(3)}m, pos=($offsetX, $offsetY, $offsetZ))');
  }

  void _updateTransitionImage({bool animated = true}) {
    if (_overlayNode?.geometry == null ||
        _cachedTransitionImages == null ||
        _cachedTransitionImages!.isEmpty) {
      return;
    }

    try {
      if (animated) {
        _animateTransparency(1.0, 0.0, const Duration(milliseconds: 400), () {
          _recreateOverlayWithScale();
          Future.delayed(const Duration(milliseconds: 50), () {
            if (mounted && _overlayNode != null) {
              _animateTransparency(0.0, 1.0, const Duration(milliseconds: 400), null);
            }
          });
        });
      } else {
        _recreateOverlayWithScale();
      }
    } catch (e) {
      debugPrint('Errore durante la transizione: $e');
    }
  }

  void _recreateOverlayWithScale() {
    final anchor = currentAnchor;
    if (anchor == null) return;

    final cp = painting;
    if (cp == null) return;

    if (cp.alternateImages == null ||
        _currentImageIndex >= (cp.alternateImages?.length ?? 0)) {
      debugPrint('Errore: configurazione alternateImages non valida');
      return;
    }

    final baseW = anchor.referenceImagePhysicalSize.x;
    final baseH = anchor.referenceImagePhysicalSize.y;

    final currentImg = cp.alternateImages![_currentImageIndex];
    final widthRatio = (currentImg['widthRatio'] as num?)?.toDouble() ?? cp.widthRatio;
    final heightRatio = (currentImg['heightRatio'] as num?)?.toDouble() ?? cp.heightRatio;
    final offsetX = (currentImg['offsetX'] as num?)?.toDouble() ?? cp.offsetX;
    final offsetY = (currentImg['offsetY'] as num?)?.toDouble() ?? cp.offsetY;
    final offsetZ = (currentImg['offsetZ'] as num?)?.toDouble() ?? cp.offsetZ;

    final w = baseW * widthRatio;
    final h = baseH * heightRatio;

    try { arkitController?.remove('overlayTransition'); } catch (e) { debugPrint('Errore rimozione nodo: $e'); }

    final plane = ARKitPlane(width: w, height: h);
    plane.materials.value = [
      ARKitMaterial(
        diffuse: ARKitMaterialProperty.image(_cachedTransitionImages![_currentImageIndex]),
        transparency: 0.0,
        doubleSided: true,
        lightingModelName: ARKitLightingModel.constant,
      ),
    ];

    _overlayNode = ARKitNode(
      name: 'overlayTransition',
      geometry: plane,
      position: vector.Vector3(offsetX, offsetY, offsetZ),
      eulerAngles: vector.Vector3(0, math.pi * 1.5, 0),
      renderingOrder: 2000,
    );

    try {
      arkitController?.add(_overlayNode!, parentNodeName: anchor.nodeName);
      debugPrint('Nuovo nodo aggiunto: w=${w.toStringAsFixed(3)}m, h=${h.toStringAsFixed(3)}m, pos=($offsetX, $offsetY, $offsetZ)');
    } catch (e) {
      debugPrint('Errore aggiunta nodo: $e');
    }
  }

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

  void _goToNextImage({bool animated = true}) {
    if (_cachedTransitionImages == null) return;
    setState(() {
      _currentImageIndex = (_currentImageIndex + 1) % _cachedTransitionImages!.length;
      _showAltInfo = false;
    });
    _updateTransitionImage(animated: animated);
  }

  void _goToPreviousImage({bool animated = true}) {
    if (_cachedTransitionImages == null) return;
    setState(() {
      _currentImageIndex = (_currentImageIndex - 1 + _cachedTransitionImages!.length) % _cachedTransitionImages!.length;
      _showAltInfo = false;
    });
    _updateTransitionImage(animated: animated);
  }

  // ———— wrapper per il widget estratto del dettaglio hotspot ————
  Widget _buildHotspotDetailView() {
    final cp = painting;
    if (_selectedHotspot == null || cp?.hotspots == null) return const SizedBox.shrink();
    final hotspot = cp!.hotspots![_selectedHotspot!];

    final detailImageUrl =
    (_cachedDetailImages != null && _selectedHotspot! < _cachedDetailImages!.length)
        ? _cachedDetailImages![_selectedHotspot!]
        : null;

    return HotspotDetailView(
      title: hotspot['title'] as String,
      description: hotspot['description'] as String,
      imageUrl: detailImageUrl,
      onBack: () => setState(() => _selectedHotspot = null),
    );
  }
}
