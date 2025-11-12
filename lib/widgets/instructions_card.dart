import 'package:flutter/material.dart';

class InstructionsCard extends StatelessWidget {
  final bool isLandscape;
  final String instructionText;
  final String? targetTitle;

  const InstructionsCard({
    super.key,
    required this.isLandscape,
    required this.instructionText,
    this.targetTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
            if ((targetTitle ?? '').isNotEmpty) ...[
              Text(
                'Punta la fotocamera sulla cartolina di\n"$targetTitle"',
                style: TextStyle(color: Colors.white, fontSize: isLandscape ? 13 : 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isLandscape ? 6 : 8),
            ],
            Text(instructionText,
                style: TextStyle(color: Colors.white70, fontSize: isLandscape ? 10 : 12)),
          ],
        ),
      ),
    );
  }
}
