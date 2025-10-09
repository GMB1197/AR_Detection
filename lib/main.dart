import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AR Quadro Restaurato',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const PaintingARView(),
    );
  }
}

class PaintingARView extends StatefulWidget {
  const PaintingARView({super.key});

  @override
  State<PaintingARView> createState() => _PaintingARViewState();
}

class _PaintingARViewState extends State<PaintingARView> {
  late ARKitController arkitController;
  Timer? timer;
  bool imageDetected = false;
  String? detectedImageName;
  String? cachedImageUrl;

  static const String referenceImageName = 'painting-1';
  static const bool useTexture = true;
  static const double planeOffset = 0.002;

  static const double paintingWidthRatio = 1.43;
  static const double paintingHeightRatio = 0.94;

  @override
  void initState() {
    super.initState();
    _preloadImage();
  }

  @override
  void dispose() {
    timer?.cancel();
    arkitController.dispose();
    super.dispose();
  }

  Future<void> _preloadImage() async {
    try {
      final data = await rootBundle.load('assets/painting.png');
      final bytes = data.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/painting.png');
      await file.writeAsBytes(bytes, flush: true);

      cachedImageUrl = file.uri.toString();
      debugPrint('✅ Immagine pre-caricata: $cachedImageUrl');
    } catch (e) {
      debugPrint('❌ Errore pre-caricamento immagine: $e');
    }
  }

  void _resetDetection() {
    setState(() {
      imageDetected = false;
      detectedImageName = null;
    });

    try {
      arkitController.remove('overlayFront');
    } catch (e) {
      debugPrint('⚠️ Errore rimozione overlay: $e');
    }

    debugPrint('🔄 Detection resettata');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Restauro Dipinto'),
        backgroundColor: Colors.deepPurple,
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
            onARKitViewCreated: onARKitViewCreated,
          ),
          if (!imageDetected)
            Positioned(
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
                child: const Column(
                  children: [
                    Text(
                      'Punta la fotocamera sulla cartolina\ndel quadro rovinato',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
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
            ),
          if (imageDetected)
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 1.0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 32),
                    SizedBox(height: 8),
                    Text(
                      'Dipinto rilevato!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Versione restaurata sovrapposta',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void onARKitViewCreated(ARKitController controller) {
    arkitController = controller;
    arkitController.onAddNodeForAnchor = _handleAddAnchor;

    debugPrint('✅ ARKit inizializzato correttamente');
    debugPrint('🔍 In attesa di rilevare l\'immagine: $referenceImageName');
    debugPrint('📁 Gruppo detection: AR Resources');
  }

  void _handleAddAnchor(ARKitAnchor anchor) async {
    debugPrint('🎯 Anchor rilevato! Tipo: ${anchor.runtimeType}');
    debugPrint('📍 Nome anchor: ${anchor.nodeName}');
    debugPrint('📊 Identificatore: ${anchor.identifier}');

    if (anchor is ARKitImageAnchor) {
      debugPrint('📸 ✅ È UN IMAGE ANCHOR!');
      debugPrint('📸 Nome immagine: ${anchor.referenceImageName}');
      debugPrint('📏 Dimensioni: ${anchor.referenceImagePhysicalSize}');
      debugPrint('🔍 Tracked: ${anchor.isTracked}');

      if (anchor.referenceImageName == referenceImageName) {
        debugPrint('✅ MATCH! È l\'immagine corretta: $referenceImageName');

        setState(() {
          imageDetected = true;
          detectedImageName = anchor.referenceImageName;
        });

        final overlay = await _buildOverlayNode(anchor, planeOffset);
        arkitController.add(overlay, parentNodeName: anchor.nodeName);

        debugPrint('🎨 Overlay aggiunto');
      } else {
        debugPrint('❌ MISMATCH! Rilevata: ${anchor.referenceImageName}, Attesa: $referenceImageName');
      }
    } else {
      debugPrint('❌ NON è un image anchor, è: ${anchor.runtimeType}');
    }
  }

  Future<ARKitNode> _buildOverlayNode(
      ARKitImageAnchor anchor,
      double zOffset,
      ) async {
    final double w = anchor.referenceImagePhysicalSize.x * paintingWidthRatio;
    final double h = anchor.referenceImagePhysicalSize.y * paintingHeightRatio;

    debugPrint('📐 Overlay size (m): width=$w, height=$h (zOffset=$zOffset)');

    ARKitMaterial material;

    if (useTexture && cachedImageUrl != null) {
      material = ARKitMaterial(
        diffuse: ARKitMaterialProperty.image(cachedImageUrl!),
        doubleSided: true,
        transparency: 1.0,
        lightingModelName: ARKitLightingModel.constant,
      );
    } else if (useTexture) {
      final data = await rootBundle.load('assets/painting.png');
      final bytes = data.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/painting.png');
      await file.writeAsBytes(bytes, flush: true);

      material = ARKitMaterial(
        diffuse: ARKitMaterialProperty.image(file.uri.toString()),
        doubleSided: true,
        transparency: 1.0,
        lightingModelName: ARKitLightingModel.constant,
      );
    } else {
      material = ARKitMaterial(
        diffuse: ARKitMaterialProperty.color(Colors.green),
        doubleSided: true,
        transparency: 1.0,
        lightingModelName: ARKitLightingModel.constant,
      );
    }

    final plane = ARKitPlane(width: w, height: h, materials: [material]);

    return ARKitNode(
      name: 'overlayFront',
      geometry: plane,
      position: vector.Vector3(0, 0, zOffset),
      // Ruota di 180° per girare il quadro
      eulerAngles: vector.Vector3(0 , math.pi / 2 + math.pi, 0),
      renderingOrder: 2000,
    );
  }
}