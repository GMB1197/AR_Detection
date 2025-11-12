import 'package:flutter/material.dart';

class AltInfoFab extends StatelessWidget {
  final bool isLandscape;
  final VoidCallback onTap;
  final bool highlighted;

  const AltInfoFab({
    super.key,
    required this.isLandscape,
    required this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: isLandscape ? 8 : 16,
      right: isLandscape ? 8 : 16,
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              shape: BoxShape.circle,
              border: Border.all(
                color: highlighted
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.info_outline, color: Colors.white, size: 22),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
