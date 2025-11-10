import 'package:flutter/material.dart';

/// Widget per i controlli di transizione del painting-10
/// Include: bottoni prev/next, indicatore artista, dots
class TransitionControls extends StatelessWidget {
  final int currentIndex;
  final int totalImages;
  final List<String> artistNames;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool isLandscape;

  const TransitionControls({
    super.key,
    required this.currentIndex,
    required this.totalImages,
    required this.artistNames,
    required this.onPrevious,
    required this.onNext,
    this.isLandscape = false,
  });

  @override
  Widget build(BuildContext context) {
    final currentArtist = currentIndex < artistNames.length
        ? artistNames[currentIndex]
        : 'Sconosciuto';

    return Positioned(
      bottom: isLandscape ? 20 : 30,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicatore artista corrente
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.art_track,
                    size: 18,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      currentArtist,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Controlli di navigazione
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Bottone Previous
                _buildControlButton(
                  icon: Icons.skip_previous,
                  onPressed: onPrevious,
                  tooltip: 'Immagine precedente',
                ),

                const SizedBox(width: 40),

                // Bottone Next
                _buildControlButton(
                  icon: Icons.skip_next,
                  onPressed: onNext,
                  tooltip: 'Immagine successiva',
                ),
              ],
            ),

            // Indicatori pagina (dots)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  totalImages,
                      (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == currentIndex ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == currentIndex
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper per creare bottoni dei controlli
  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}