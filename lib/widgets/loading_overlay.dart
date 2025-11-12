import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
  }
}
