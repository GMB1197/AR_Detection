import 'package:flutter/material.dart';

class HotspotHint extends StatelessWidget {
  final bool isLandscape;

  const HotspotHint({super.key, required this.isLandscape});

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
  }
}
