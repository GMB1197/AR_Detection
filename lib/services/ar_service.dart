import 'dart:io';
import 'dart:math' as math;
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import '../models/painting_model.dart';

class ARService {
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

  /// Crea il nodo overlay AR per il quadro con posizionamento personalizzato
  static ARKitNode buildOverlayNode({
    required ARKitImageAnchor anchor,
    required PaintingModel painting,
    required String cachedImageUrl,
    required double transparency,
  }) {
    // Calcola le dimensioni basate sui ratio del modello
    final double w = anchor.referenceImagePhysicalSize.x * painting.widthRatio;
    final double h = anchor.referenceImagePhysicalSize.y * painting.heightRatio;

    debugPrint('Overlay size: width=$w m, height=$h m');
    debugPrint('Position offset: x=${painting.offsetX}, y=${painting.offsetY}, z=${painting.offsetZ}');

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

    // Applica gli offset dal modello per posizionamento personalizzato
    return ARKitNode(
      name: 'overlayFront',
      geometry: plane,
      position: vector.Vector3(
        painting.offsetX,  // Offset orizzontale
        painting.offsetY,  // Offset verticale
        painting.offsetZ,  // Distanza dalla superficie
      ),
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
    String? cachedSecondaryImageUrl,
    required double transparency,
  }) {
    try {
      // Rimuovi overlay principale
      controller.remove('overlayFront');
      final overlay = buildOverlayNode(
        anchor: anchor,
        painting: painting,
        cachedImageUrl: cachedImageUrl,
        transparency: transparency,
      );
      controller.add(overlay, parentNodeName: anchor.nodeName);

      // Aggiorna anche il secondo overlay se presente
      if (painting.secondaryOverlayPath != null && cachedSecondaryImageUrl != null) {
        controller.remove('overlaySecondary');
        final secondaryOverlay = buildSecondaryOverlayNode(
          anchor: anchor,
          painting: painting,
          cachedImageUrl: cachedSecondaryImageUrl,
          transparency: transparency,
        );
        controller.add(secondaryOverlay, parentNodeName: anchor.nodeName);
      }

      debugPrint('Trasparenza aggiornata: ${(transparency * 100).toInt()}%');
    } catch (e) {
      debugPrint('Errore aggiornamento trasparenza: $e');
    }
  }

  /// Crea il nodo per il secondo overlay (es. dipinto dentro la chiesa)
  static ARKitNode buildSecondaryOverlayNode({
    required ARKitImageAnchor anchor,
    required PaintingModel painting,
    required String cachedImageUrl,
    required double transparency,
  }) {
    final double w = anchor.referenceImagePhysicalSize.x * (painting.secondaryWidthRatio ?? 1.0);
    final double h = anchor.referenceImagePhysicalSize.y * (painting.secondaryHeightRatio ?? 1.0);

    debugPrint('Secondary overlay size: width=$w m, height=$h m');
    debugPrint('Secondary position: x=${painting.secondaryOffsetX}, y=${painting.secondaryOffsetY}, z=${painting.secondaryOffsetZ}');

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
      name: 'overlaySecondary',
      geometry: plane,
      position: vector.Vector3(
        painting.secondaryOffsetX ?? 0.0,
        painting.secondaryOffsetY ?? 0.0,
        painting.secondaryOffsetZ ?? 0.002,  // DIETRO la chiesa
      ),
      eulerAngles: vector.Vector3(0, math.pi / 2 + math.pi, 0),
      renderingOrder: 1999,  // DIETRO la chiesa (che ha 2000)
    );
  }
}