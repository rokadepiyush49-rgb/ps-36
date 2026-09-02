import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/janmaang_colors.dart';
import '../../core/theme/janmaang_typography.dart';

/// One frame of the storytelling gallery.
@immutable
class GallerySlide {
  const GallerySlide({
    required this.asset,
    required this.title,
    required this.caption,
    required this.icon,
    required this.tint,
  });

  final String asset;
  final String title;
  final String caption;
  final IconData icon;

  /// Used by the fallback treatment, and as the scrim tint over the photo.
  final Color tint;
}

/// The four civic-infrastructure photographs, in order.
abstract final class JanMaangGallery {
  static const slides = <GallerySlide>[
    GallerySlide(
      asset: 'assets/gallery/roads.jpg',
      title: 'Roads that get resurfaced',
      caption: 'Approach road works, Yadgir block',
      icon: Icons.add_road,
      tint: JanMaangColors.brandOrange,
    ),
    GallerySlide(
      asset: 'assets/gallery/transit.jpg',
      title: 'Transit that reaches the last ward',
      caption: 'Metro corridor at dusk',
      icon: Icons.directions_transit,
      tint: JanMaangColors.brandBlue,
    ),
    GallerySlide(
      asset: 'assets/gallery/civic.jpg',
      title: 'Public spaces, publicly funded',
      caption: 'Civic architecture open to everyone',
      icon: Icons.account_balance,
      tint: JanMaangColors.brandNavy,
    ),
    GallerySlide(
      asset: 'assets/gallery/water.jpg',
      title: 'Water that actually arrives',
      caption: 'Treatment works serving seven habitations',
      icon: Icons.water_drop,
      tint: JanMaangColors.brandGreen,
    ),
  ];
}

/// Continuously scrolling horizontal gallery.
///
/// Motion is a slow constant drift driven by a [Ticker] rather than a repeating
/// animation over a fixed distance, which is what keeps the loop seamless — the
/// offset wraps on the width of one full set, so there is no jump at the seam.
///
/// Pauses on hover and while the user is dragging; drag and fling work exactly
/// as they would on a normal list. Honours the platform's reduce-motion setting
/// by holding still and letting the user scroll manually.
class JmPhotoGallery extends StatefulWidget {
  const JmPhotoGallery({
    super.key,
    this.slides = JanMaangGallery.slides,
    this.height = 200,
    this.itemWidth = 300,
    this.pixelsPerSecond = 26,
  });

  final List<GallerySlide> slides;
  final double height;
  final double itemWidth;

  /// Drift speed. Slow enough to read, fast enough to feel alive.
  final double pixelsPerSecond;

  @override
  State<JmPhotoGallery> createState() => _JmPhotoGalleryState();
}

class _JmPhotoGalleryState extends State<JmPhotoGallery>
    with SingleTickerProviderStateMixin {
  final _controller = ScrollController();
  Ticker? _ticker;
  Duration _lastTick = Duration.zero;
  bool _paused = false;

  /// Width of one full pass of the slide list, including gaps.
  double get _setExtent =>
      widget.slides.length * (widget.itemWidth + Insets.md);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ticker?.start();
    });
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final delta = elapsed - _lastTick;
    _lastTick = elapsed;

    if (_paused || !_controller.hasClients) return;
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return;

    final seconds = delta.inMicroseconds / Duration.microsecondsPerSecond;
    if (seconds <= 0 || seconds > 0.5) return; // skip stalls and first frame

    var next = _controller.offset + widget.pixelsPerSecond * seconds;

    // Wrap within the first set so the tail never runs out. The list renders
    // three sets, so the visible content is identical either side of the seam.
    if (next >= _setExtent * 2) next -= _setExtent;
    _controller.jumpTo(next);
  }

  void _setPaused(bool value) {
    if (_paused == value) return;
    setState(() => _paused = value);
  }

  @override
  Widget build(BuildContext context) {
    // Three copies: one to scroll off the left, one on screen, one incoming.
    final looped = <GallerySlide>[
      ...widget.slides,
      ...widget.slides,
      ...widget.slides,
    ];

    return MouseRegion(
      onEnter: (_) => _setPaused(true),
      onExit: (_) => _setPaused(false),
      child: Listener(
        onPointerDown: (_) => _setPaused(true),
        onPointerUp: (_) => _setPaused(false),
        onPointerCancel: (_) => _setPaused(false),
        child: SizedBox(
          height: widget.height,
          child: ShaderMask(
            // Feathered edges so slides enter and leave rather than pop.
            shaderCallback: (rect) => const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[
                Colors.transparent,
                Colors.black,
                Colors.black,
                Colors.transparent,
              ],
              stops: <double>[0, 0.04, 0.96, 1],
            ).createShader(rect),
            blendMode: BlendMode.dstIn,
            child: ListView.separated(
              controller: _controller,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: Insets.marginMobile),
              itemCount: looped.length,
              separatorBuilder: (_, _) => const SizedBox(width: Insets.md),
              itemBuilder: (context, index) => _Slide(
                slide: looped[index],
                width: widget.itemWidth,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Slide extends StatefulWidget {
  const _Slide({required this.slide, required this.width});

  final GallerySlide slide;
  final double width;

  @override
  State<_Slide> createState() => _SlideState();
}

class _SlideState extends State<_Slide> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.02 : 1,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: SizedBox(
          width: widget.width,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Corners.lg),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: scheme.outlineVariant),
                borderRadius: BorderRadius.circular(Corners.lg),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.asset(
                    widget.slide.asset,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                    errorBuilder: (context, error, stack) =>
                        _Fallback(slide: widget.slide),
                  ),
                  // Scrim so the caption stays legible over any photograph.
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Colors.transparent,
                          Color(0x00000000),
                          Color(0xB3000000),
                        ],
                        stops: <double>[0, 0.45, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    left: Insets.md,
                    right: Insets.md,
                    bottom: Insets.md,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          widget.slide.title,
                          style: JanMaangTypography.withWeight(
                            JanMaangTypography.bodyMd,
                            FontWeight.w700,
                          ).copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.slide.caption,
                          style: JanMaangTypography.bodySm
                              .copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shown until the photographs are dropped into `assets/gallery/`. Designed
/// rather than broken: the slide keeps its shape, colour and caption.
class _Fallback extends StatelessWidget {
  const _Fallback({required this.slide});

  final GallerySlide slide;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
    );
  }
}
