import 'package:flutter/material.dart';

class TransparencySlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;

  const TransparencySlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    if (isLandscape) {
      return _buildLandscapeSlider();
    } else {
      return _buildPortraitSlider();
    }
  }

  Widget _buildPortraitSlider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rovinato',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(value * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Restaurato',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
              thumbColor: Colors.white,
              overlayColor: Colors.white.withValues(alpha: 0.2),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 11,
              ),
              overlayShape: const RoundSliderOverlayShape(
                overlayRadius: 22,
              ),
              trackHeight: 3.5,
            ),
            child: Slider(
              value: value,
              min: 0.0,
              max: 1.0,
              onChanged: onChanged,
              onChangeStart: onChangeStart,
              onChangeEnd: onChangeEnd,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeSlider() {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Restaurato',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${(value * 100).toInt()}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: RotatedBox(
              quarterTurns: 3,
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
                  thumbColor: Colors.white,
                  overlayColor: Colors.white.withValues(alpha: 0.2),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 11,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 22,
                  ),
                  trackHeight: 3.5,
                ),
                child: Slider(
                  value: value,
                  min: 0.0,
                  max: 1.0,
                  onChanged: onChanged,
                  onChangeStart: onChangeStart,
                  onChangeEnd: onChangeEnd,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Rovinato',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}