import 'dart:async';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/material.dart';
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

  // Nome dell'immagine di riferimento (cartolina del quadro rovinato)
  static const String referenceImageName = 'painting-1';

  @override
  void dispose() {
    timer?.cancel();
    arkitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Restauro Dipinto'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          ARKitSceneView(
            detectionImagesGroupName: 'AR-Resources',
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
                      'Cartolina: 21cm x 15cm\n(Immagine quadro: 20cm x 10cm)',
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
              top: 100,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.9),
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
    arkitController.onUpdateNodeForAnchor = _handleUpdateAnchor;

    debugPrint('✅ ARKit inizializzato correttamente');
    debugPrint('🔍 In attesa di rilevare l\'immagine: $referenceImageName');
  }

  void _handleAddAnchor(ARKitAnchor anchor) {
    debugPrint('🎯 Anchor rilevato! Tipo: ${anchor.runtimeType}');

    if (anchor is ARKitImageAnchor) {
      debugPrint('📸 Immagine rilevata! Nome: ${anchor.referenceImageName}');
      debugPrint('📏 Dimensioni fisiche: ${anchor.referenceImagePhysicalSize}');

      // Verifica che sia l'immagine corretta
      if (anchor.referenceImageName == referenceImageName) {
        debugPrint('✅ MATCH! È l\'immagine corretta: $referenceImageName');

        setState(() {
          imageDetected = true;
          detectedImageName = anchor.referenceImageName;
        });

        // Crea il nodo con l'immagine restaurata
        final node = _createRestoredPaintingNode(anchor);
        arkitController.add(node, parentNodeName: anchor.nodeName);

        debugPrint('🎨 Overlay restaurato applicato alla cartolina');
      } else {
        debugPrint('❌ MISMATCH! Rilevata: ${anchor.referenceImageName}, Attesa: $referenceImageName');
      }
    } else {
      debugPrint('⚠️ Anchor non è un\'immagine, è: ${anchor.runtimeType}');
    }
  }

  void _handleUpdateAnchor(ARKitAnchor anchor) {
    if (anchor is ARKitImageAnchor && !imageDetected) {
      debugPrint('🔄 Update anchor immagine: ${anchor.referenceImageName}');
      _handleAddAnchor(anchor);
    }
  }

  ARKitNode _createRestoredPaintingNode(ARKitImageAnchor anchor) {
    final width = anchor.referenceImagePhysicalSize.x;
    final height = anchor.referenceImagePhysicalSize.y;

    final material = ARKitMaterial(
      diffuse: ARKitMaterialProperty.image('assets/painting.png'),
      doubleSided: true,
      transparency: 1.0,
      lightingModelName: ARKitLightingModel.constant,
    );

    final geometry = ARKitPlane(
      width: width,
      height: height,
      materials: [material],
    );

    return ARKitNode(
      name: 'restoredPaintingNodes',
      geometry: geometry,
      position: vector.Vector3(0, 0, 0.001), // Leggermente sopra l'immagine rilevata
      eulerAngles: vector.Vector3.zero(),
    );
  }
}