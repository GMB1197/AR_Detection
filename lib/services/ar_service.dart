import 'dart:io';
import 'dart:math' as math;
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import '../models/painting_model.dart';

class ARService {
  static const double planeOffset = 0.003;

  /// Pre-carica l'immagine restaurata nella cache temporanea
  static Future<String?> preloadImage(String assetPath) async {
    try {
      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final fileName = assetPath.split('/').last;
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);

      debugPrint('Immagine pre-caricata: ${file.uri}');
      return file.uri.toString();
    } catch (e) {
      debugPrint('Errore pre-caricamento immagine: $e');
      return null;
    }
  }

  /// Crea il nodo overlay AR per il quadro
  static ARKitNode buildOverlayNode({
    required ARKitImageAnchor anchor,
    required PaintingModel painting,
    required String cachedImageUrl,
    required double transparency,
    double zOffset = planeOffset,
  }) {
    final double w = anchor.referenceImagePhysicalSize.x * painting.widthRatio;
    final double h = anchor.referenceImagePhysicalSize.y * painting.heightRatio;

    debugPrint('Overlay size (m): width=$w, height=$h (zOffset=$zOffset)');

    final material = ARKitMaterial(
      diffuse: ARKitMaterialProperty.image(cachedImageUrl),
      doubleSided: true,
      transparency: transparency,
      lightingModelName: ARKitLightingModel.constant,
    );

    final plane = ARKitPlane(
      width: w,
      height: h,
      materials: [material],
    );

    return ARKitNode(
      name: 'overlayFront',
      geometry: plane,
      position: vector.Vector3(0, 0, zOffset),
      eulerAngles: vector.Vector3(0, math.pi / 2 + math.pi, 0),
      renderingOrder: 2000,
    );
  }

  /// Aggiorna la trasparenza dell'overlay esistente
  static void updateOverlayTransparency({
    required ARKitController controller,
    required ARKitImageAnchor anchor,
    required PaintingModel painting,
    required String cachedImageUrl,
    required double transparency,
  }) {
    try {
      controller.remove('overlayFront');
      final overlay = buildOverlayNode(
        anchor: anchor,
        painting: painting,
        cachedImageUrl: cachedImageUrl,
        transparency: transparency,
      );
      controller.add(overlay, parentNodeName: anchor.nodeName);
      debugPrint('Trasparenza aggiornata: ${(transparency * 100).toInt()}%');
    } catch (e) {
      debugPrint('Errore aggiornamento trasparenza: $e');
    }
  }
}