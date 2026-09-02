import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/janmaang_typography.dart';
import '../../core/theme/motion.dart';
import 'jm_photo_gallery.dart';

/// The dashboard's featured-photography card.
///
/// One slide at a time from [JanMaangGallery], advancing on a slow timer and
/// swipeable by hand. It exists to make the abstract — a demand, a rank, a
/// budget line — look like the concrete thing a citizen actually gets: a road,
/// a water connection, a transit line.
///
/// Rules it follows:
/// * Auto-advance stops the moment a finger or a cursor touches it, and does
///   not resume until the gesture ends. Nothing moves under the user's hand.
/// * Under reduce-motion it does not advance on its own at all; the dots and
///   the swipe still work.
/// * A missing photograph falls back to a designed tile rather than a broken
///   image, so a fresh clone still reads.
class JmFeaturedCarousel extends StatefulWidget {
  const JmFeaturedCarousel({
    super.key,
    this.slides = JanMaangGallery.slides,
    this.height = 208,
    this.interval = const Duration(seconds: 5),
  });

  final List<GallerySlide> slides;
  final double height;
  final Duration interval;

  @override
  State<JmFeaturedCarousel> createState() => _JmFeaturedCarouselState();
}

class _JmFeaturedCarouselState extends State<JmFeaturedCarousel> {
  final _controller = PageController();
  Timer? _timer;
  int _index = 0;
  bool _held = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _restart());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _restart() {
    _timer?.cancel();
    if (!mounted || widget.slides.length < 2) return;
    if (Motion.reduced(context)) return;
    _timer = Timer.periodic(widget.interval, (_) {
      if (!mounted || _held || !_controller.hasClients) return;
      _controller.animateToPage(
        (_index + 1) % widget.slides.length,
        duration: Motion.slow,
        curve: Motion.curve,
      );
    });
  }

  void _hold(bool value) {
    if (_held == value) return;
    _held = value;
    if (!value) _restart();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final slides = widget.slides;
    if (slides.isEmpty) return const SizedBox.shrink();

    return Semantics(
      label: 'Featured public works, slide ${_index + 1} of ${slides.length}',
      child: MouseRegion(
        onEnter: (_) => _hold(true),
        onExit: (_) => _hold(false),
        child: Listener(
          onPointerDown: (_) => _hold(true),
          onPointerUp: (_) => _hold(false),
          onPointerCancel: (_) => _hold(false),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Corners.xl),
              boxShadow: Shadows.level1,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Corners.xl),
              child: SizedBox(
                height: widget.height,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    PageView.builder(
                      controller: _controller,
                      itemCount: slides.length,
                      onPageChanged: (i) => setState(() => _index = i),
                      itemBuilder: (context, i) => _Slide(slide: slides[i]),
                    ),

                    // Dots. The active one stretches into a short bar rather
                    // than only changing colour, so the position is readable
                    // without relying on contrast against the photograph.
                    Positioned(
                      right: Insets.md,
                      bottom: Insets.md,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          for (var i = 0; i < slides.length; i++)
                            AnimatedContainer(
                              duration: Motion.medium,
                              curve: Motion.curve,
                              margin: const EdgeInsets.only(left: Insets.xs + 1),
                              width: i == _index ? 18 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: i == _index
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.45),
                                borderRadius:
                                    BorderRadius.circular(Corners.pill),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Hairline drawn on top so it is not clipped away by the
                    // photograph underneath.
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Corners.xl),
                            border:
                                Border.all(color: scheme.outlineVariant),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.slide});

  final GallerySlide slide;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Image.asset(
          slide.asset,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
          errorBuilder: (context, error, stack) => DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  slide.tint.withValues(alpha: 0.92),
                  slide.tint.withValues(alpha: 0.62),
                ],
              ),
            ),
            child: Center(
              child: Icon(
                slide.icon,
                size: 44,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
        ),

        // Scrim. Weighted to the bottom-left so the caption clears it and the
        // dots on the right stay on a lighter part of the frame.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0x1A0A1B36),
                Color(0x000A1B36),
                Color(0xD90A1B36),
              ],
              stops: <double>[0, 0.38, 1],
            ),
          ),
        ),

        Positioned(
          left: Insets.md,
          right: 96,
          bottom: Insets.md,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // A short bar in the slide's category colour: the one place the
              // accent hues appear on this card.
              Container(
                width: 26,
                height: 3,
                margin: const EdgeInsets.only(bottom: Insets.sm),
                decoration: BoxDecoration(
                  color: slide.tint,
                  borderRadius: BorderRadius.circular(Corners.pill),
                ),
              ),
              Text(
                slide.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: JanMaangTypography.withWeight(
                  JanMaangTypography.bodyLg,
                  FontWeight.w700,
                ).copyWith(color: Colors.white),
              ),
              const SizedBox(height: 2),
              Text(
                slide.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: JanMaangTypography.bodySm
                    .copyWith(color: Colors.white.withValues(alpha: 0.82)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
