import 'package:flutter/material.dart';

class TransitionControls extends StatelessWidget {
  const TransitionControls({
    super.key,
    // stessi parametri che usi in ARViewScreen
    required this.currentIndex,
    required this.totalImages,
    this.artistNames,
    this.onPrevious,
    this.onNext,
    this.isLandscape, // solo per compatibilità; non usato direttamente

    // opzioni
    this.isVisible = true,
    this.margin,
    this.compactLandscape = true,
  });

  final int currentIndex;
  final int totalImages;
  final List<String>? artistNames;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final bool? isLandscape;

  final bool isVisible;
  final EdgeInsetsGeometry? margin;
  final bool compactLandscape;

  @override
  Widget build(BuildContext context) {
    final int safeTotal = totalImages.clamp(0, 1000000);
    final int safeIndex = safeTotal == 0 ? 0 : currentIndex.clamp(0, safeTotal - 1);

    final String labelText = (artistNames != null && safeIndex < (artistNames?.length ?? 0))
        ? artistNames![safeIndex]
        : (safeTotal > 0 ? '${safeIndex + 1} / $safeTotal' : '');

    return OrientationBuilder(
      builder: (context, orientation) {
        final bool landscape = orientation == Orientation.landscape;

        final Widget body = landscape
            ? _LandscapeRail(
          labelText: labelText,
          dotsCount: safeTotal,
          currentDot: safeIndex,
          onPrev: (safeTotal > 1) ? onPrevious : null,
          onNext: (safeTotal > 1) ? onNext : null,
          compact: compactLandscape,
        )
            : _PortraitBar(
          labelText: labelText,
          dotsCount: safeTotal,
          currentDot: safeIndex,
          onPrev: (safeTotal > 1) ? onPrevious : null,
          onNext: (safeTotal > 1) ? onNext : null,
        );

        return SafeArea(
          child: IgnorePointer(
            ignoring: !isVisible,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 220),
              opacity: isVisible ? 1.0 : 0.0,
              child: Align(
                alignment: landscape ? Alignment.centerRight : Alignment.bottomCenter,
                child: Container(
                  margin: margin ??
                      EdgeInsets.only(
                        right: landscape ? 16 : 0,
                        left: landscape ? 0 : 16,
                        bottom: landscape ? 0 : 16,
                      ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(landscape ? 16 : 14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: body,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/* ===================== PORTRAIT (BOTTOM BAR) ===================== */
class _PortraitBar extends StatelessWidget {
  const _PortraitBar({
    required this.labelText,
    required this.dotsCount,
    required this.currentDot,
    required this.onPrev,
    required this.onNext,
  });

  final String labelText;
  final int dotsCount;
  final int currentDot;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final shortest = MediaQuery.of(context).size.shortestSide;
    final bool isCompact = shortest < 380;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 10 : 14,
        vertical: isCompact ? 8 : 10,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          _roundBtn(icon: Icons.skip_previous, onTap: onPrev),
          SizedBox(width: isCompact ? 6 : 10),

          // Centro: etichetta + dots
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  labelText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                _DotsIndicator(
                  count: dotsCount,
                  current: currentDot,
                  axis: Axis.horizontal,
                ),
              ],
            ),
          ),

          SizedBox(width: isCompact ? 6 : 10),
          _roundBtn(icon: Icons.skip_next, onTap: onNext),
        ],
      ),
    );
  }

  Widget _roundBtn({required IconData icon, VoidCallback? onTap}) {
    return ClipOval(
      child: Material(
        color: Colors.white.withValues(alpha: onTap == null ? 0.08 : 0.14),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: Colors.white, size: 22), // ← ICONA VISIBILE
          ),
        ),
      ),
    );
  }
}

/* ===================== LANDSCAPE (RIGHT RAIL) ===================== */
class _LandscapeRail extends StatelessWidget {
  const _LandscapeRail({
    required this.labelText,
    required this.dotsCount,
    required this.currentDot,
    required this.onPrev,
    required this.onNext,
    required this.compact,
  });

  final String labelText;
  final int dotsCount;
  final int currentDot;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double railWidth = compact ? 72.0 : 92.0;
    final double railHeight = (size.height * (compact ? 0.58 : 0.68)).clamp(260.0, 560.0);

    return SizedBox(
      width: railWidth,
      height: railHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            _iconBtn(icon: Icons.skip_previous, onTap: onPrev),
            const SizedBox(height: 10),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // etichetta
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      labelText,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // dots verticali
                  _DotsIndicator(
                    count: dotsCount,
                    current: currentDot,
                    axis: Axis.vertical,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            _iconBtn(icon: Icons.skip_next, onTap: onNext),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn({required IconData icon, VoidCallback? onTap}) {
    return ClipOval(
      child: Material(
        color: Colors.white.withValues(alpha: onTap == null ? 0.08 : 0.14),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}

/* ===================== DOTS INDICATOR ===================== */
class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({
    required this.count,
    required this.current,
    this.axis = Axis.horizontal,
  });

  final int count;
  final int current;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    if (count <= 1) {
      return const SizedBox.shrink();
    }

    final shortest = MediaQuery.of(context).size.shortestSide;
    final bool compact = shortest < 380;

    final double dotSize = compact ? 6.0 : 7.0;
    final double activeSize = compact ? 9.0 : 10.0;
    final double spacing = compact ? 5.0 : 6.0;
    final BorderRadius radius = BorderRadius.circular(999);

    final children = List<Widget>.generate(count, (i) {
      final bool active = i == current;
      final double size = active ? activeSize : dotSize;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: active
              ? Colors.white.withValues(alpha: 0.95)
              : Colors.white.withValues(alpha: 0.35),
          borderRadius: radius,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.22),
            width: active ? 1.0 : 0.6,
          ),
        ),
      );
    });

    if (axis == Axis.vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: _withSpacing(children, spacing, vertical: true),
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: _withSpacing(children, spacing, vertical: false),
      );
    }
  }

  List<Widget> _withSpacing(List<Widget> items, double gap, {required bool vertical}) {
    if (items.isEmpty) return items;
    final spaced = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      spaced.add(items[i]);
      if (i != items.length - 1) {
        spaced.add(SizedBox(
          width: vertical ? 0 : gap,
          height: vertical ? gap : 0,
        ));
      }
    }
    return spaced;
  }
}
