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
  bool imageDetected = false;
  String? detectedImageName;

  @override
  void dispose() {
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
        children: [
          ARKitSceneView(
            detectionImagesGroupName: 'AR-Resources',
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
                child: const Text(
                  'Punta la fotocamera sul dipinto rovinato...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
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
                      'Dipinto rilevato!\nEcco la versione restaurata',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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

    // Listener per il rilevamento delle immagini
    arkitController.onAddNodeForAnchor = _handleAddAnchor;
    arkitController.onUpdateNodeForAnchor = _handleUpdateAnchor;
  }

  void _handleAddAnchor(ARKitAnchor anchor) {
    if (anchor is ARKitImageAnchor) {
      _onImageDetected(anchor);
    }
  }

  void _handleUpdateAnchor(ARKitAnchor anchor) {
    if (anchor is ARKitImageAnchor && !imageDetected) {
      _onImageDetected(anchor);
    }
  }

  void _onImageDetected(ARKitImageAnchor anchor) {
    // Verifica che sia l'immagine corretta
    if (anchor.referenceImageName == 'painting-1') {
      setState(() {
        imageDetected = true;
        detectedImageName = anchor.referenceImageName;
      });

      // Crea il piano con l'immagine restaurata
      final node = _createRestoredPaintingNode(anchor);
      arkitController.add(node, parentNodeName: anchor.nodeName);

      debugPrint('✅ Dipinto rilevato: ${anchor.referenceImageName}');
    }
  }

  ARKitNode _createRestoredPaintingNode(ARKitImageAnchor anchor) {
    // Ottieni le dimensioni dell'immagine fisica rilevata
    final width = anchor.referenceImagePhysicalSize.x;
    final height = anchor.referenceImagePhysicalSize.y;

    // Crea il materiale con l'immagine restaurata
    final material = ARKitMaterial(
      diffuse: ARKitMaterialProperty.image('assets/painting.png'),
      doubleSided: true,
      transparency: 1.0,
      lightingModelName: ARKitLightingModel.constant,
    );

    // Crea un piano delle stesse dimensioni dell'immagine rilevata
    final geometry = ARKitPlane(
      width: width,
      height: height,
      materials: [material],
    );

    // Crea il nodo
    return ARKitNode(
      name: 'restored_painting',
      geometry: geometry,
      position: vector.Vector3(0, 0, 0.001),
      eulerAngles: vector.Vector3.zero(),
    );
  }
}