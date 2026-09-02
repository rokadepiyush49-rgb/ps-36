import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/motion.dart';

/// The standard surface: pure white, 28px radius, no hairline, and one wide
/// very faint navy shadow.
///
/// The card does not draw a border because it does not need one — the page
/// underneath is a navy wash, and the value difference is what separates them.
/// Adding an outline on top of that reads as a panel rather than an object.
/// A border only appears when something is [emphasised] or when a caller
/// passes one explicitly.
///
/// Tappable cards lift to level 2 on hover and compress slightly on press.
/// That is the whole of their interaction vocabulary.
class JmCard extends StatefulWidget {
  const JmCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Insets.lg),
    this.onTap,
    this.borderColor,
    this.backgroundColor,
    this.radius = Corners.lg,
    this.emphasised = false,
    this.leadingAccent = false,
    this.accentColor,
    this.flat = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  /// An explicit outline. Null means none — which is the default.
  final Color? borderColor;

  final Color? backgroundColor;
  final double radius;

  /// Draws the card with a primary border and a level-2 shadow — the treatment
  /// the top-ranked demand card gets.
  final bool emphasised;

  /// A 4px accent bar down the left edge.
  final bool leadingAccent;

  /// Colour of that bar. Defaults to the brand navy; a status colour here lets
  /// a list of cards carry its category without tinting the whole surface.
  final Color? accentColor;

  /// Drops the shadow entirely. For a card nested inside another card, where a
  /// second shadow would read as a rendering mistake.
  final bool flat;

  @override
  State<JmCard> createState() => _JmCardState();
}

class _JmCardState extends State<JmCard> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final interactive = widget.onTap != null;
    final reduced = Motion.reduced(context);
    final dark = Theme.of(context).brightness == Brightness.dark;

    final border = widget.borderColor ??
        (widget.emphasised
            ? scheme.primary
            // In dark mode the value gap between page and card is narrower, so
            // a whisper of an outline earns its place there and only there.
            : dark
                ? scheme.outlineVariant
                : null);

    final shadow = widget.flat
        ? const <BoxShadow>[]
        : widget.emphasised || (_hovered && interactive)
            ? Shadows.level2
            : Shadows.level1;

    final accent = widget.accentColor ?? scheme.primary;

    final content = Padding(padding: widget.padding, child: widget.child);

    final surface = AnimatedContainer(
      duration: reduced ? Duration.zero : Motion.fast,
      curve: Motion.curve,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(widget.radius),
        border: border == null
            ? null
            : Border.all(
                color: border,
                width: widget.emphasised ? 1.5 : 1,
              ),
        boxShadow: shadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onHighlightChanged: interactive
                ? (value) => setState(() => _pressed = value)
                : null,
            child: widget.leadingAccent
                ? Stack(
                    children: <Widget>[
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(width: 4, color: accent),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: content,
                      ),
                    ],
                  )
                : content,
          ),
        ),
      ),
    );

    if (!interactive) return surface;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: reduced || !_pressed ? 1.0 : 0.985,
        duration: Motion.fast,
        curve: Motion.curve,
        child: surface,
      ),
    );
  }
}
