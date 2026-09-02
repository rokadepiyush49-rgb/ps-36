import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/janmaang_colors.dart';
import '../../core/theme/janmaang_typography.dart';
import '../../core/theme/motion.dart';
import '../../core/utils/formatters.dart';

// ---------------------------------------------------------------------------
// Circular icon button
// ---------------------------------------------------------------------------

/// A 44px circle with a glyph in it.
///
/// The header control of the whole product: back, notifications, profile,
/// overflow, map controls. One shape, one size, everywhere — which is what
/// stops a screen's chrome from looking assembled out of spare parts.
class JmCircleButton extends StatefulWidget {
  const JmCircleButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.badge = false,
    this.filled = false,
    this.size = Hit.circleButton,
    this.background,
    this.foreground,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  /// Draws the unread pip, ringed in the button's own colour so it stays
  /// visible wherever it lands on the glyph.
  final bool badge;

  /// Navy fill with a white glyph, for the one control on a screen that is a
  /// primary action rather than chrome.
  final bool filled;

  final double size;
  final Color? background;
  final Color? foreground;

  @override
  State<JmCircleButton> createState() => _JmCircleButtonState();
}

class _JmCircleButtonState extends State<JmCircleButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final reduced = Motion.reduced(context);

    final bg = widget.background ??
        (widget.filled ? scheme.primary : scheme.surfaceContainerLowest);
    final fg = widget.foreground ??
        (widget.filled ? scheme.onPrimary : scheme.onSurface);

    return Tooltip(
      message: widget.tooltip,
      child: Semantics(
        button: true,
        enabled: widget.onPressed != null,
        label: widget.badge ? '${widget.tooltip}, unread' : widget.tooltip,
        excludeSemantics: true,
        child: AnimatedScale(
          scale: reduced || !_pressed ? 1.0 : 0.92,
          duration: Motion.fast,
          curve: Motion.curve,
          child: Material(
            color: bg,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onPressed,
              onHighlightChanged: (v) => setState(() => _pressed = v),
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Icon(widget.icon, size: widget.size * 0.45, color: fg),
                    if (widget.badge)
                      Positioned(
                        top: widget.size * 0.24,
                        right: widget.size * 0.26,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: scheme.error,
                            shape: BoxShape.circle,
                            border: Border.all(color: bg, width: 1.5),
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

// ---------------------------------------------------------------------------
// Greeting header
// ---------------------------------------------------------------------------

/// "Namaste, Sumeet" over a subtitle, with an avatar on the left and a
/// notification bell on the right.
///
/// The reference puts this at the top of every screen that belongs to a person
/// rather than to a dataset. Here it heads Home and Profile.
class JmGreetingHeader extends StatelessWidget {
  const JmGreetingHeader({
    super.key,
    required this.greeting,
    required this.subtitle,
    this.initials,
    this.hasUnread = false,
    this.onNotifications,
    this.onAvatarTap,
  });

  final String greeting;
  final String subtitle;

  /// One or two letters in the avatar. Falls back to the brand mark.
  final String? initials;

  final bool hasUnread;
  final VoidCallback? onNotifications;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: <Widget>[
        Semantics(
          button: onAvatarTap != null,
          label: 'Profile',
          excludeSemantics: true,
          child: Material(
            color: scheme.primaryFixed,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onAvatarTap,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: initials == null || initials!.isEmpty
                      ? Icon(
                          Icons.person_rounded,
                          size: 24,
                          color: scheme.onPrimaryFixedVariant,
                        )
                      : Text(
                          initials!,
                          style: JanMaangTypography.withWeight(
                            JanMaangTypography.bodyMd,
                            FontWeight.w700,
                          ).copyWith(color: scheme.onPrimaryFixedVariant),
                        ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: Insets.sm + Insets.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                greeting,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: JanMaangTypography.withWeight(
                  JanMaangTypography.titleLg,
                  FontWeight.w700,
                ).copyWith(color: scheme.onSurface),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: JanMaangTypography.bodySm
                    .copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(width: Insets.sm),
        JmCircleButton(
          icon: Icons.notifications_none_rounded,
          tooltip: 'Notifications',
          badge: hasUnread,
          onPressed: onNotifications,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tint tile
// ---------------------------------------------------------------------------

/// One cell of the coloured stat grid.
///
/// A glyph in a round well, the figure large on the right, the label beneath.
/// Colour sorts the grid at a glance, but every tile also carries its own icon
/// and its own words, so the sorting survives greyscale.
///
/// The figure counts up on first paint; screen readers are handed the final
/// value rather than the count.
class JmTintTile extends StatelessWidget {
  const JmTintTile({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.tint,
    this.compactValue = true,
    this.onTap,
  });

  final int value;
  final String label;
  final IconData icon;
  final JmTint tint;

  /// Formats 4281 as "4,281" using Indian digit grouping.
  final bool compactValue;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bg = tint.background(brightness);
    final fg = tint.foreground(brightness);

    // Compact by construction: a header row carrying the glyph and the figure,
    // then the label directly underneath. The previous spaceBetween layout
    // stranded the caption at the bottom of the cell and overflowed whenever
    // the grid gave it less height than the content wanted.
    final body = Padding(
      padding: const EdgeInsets.all(Insets.md - 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: tint.well(brightness),
                  borderRadius: BorderRadius.circular(Corners.sm),
                ),
                child: Icon(icon, size: 17, color: fg),
              ),
              const SizedBox(width: Insets.sm),
              Expanded(
                child: JmAnimatedCount(
                  value: value,
                  builder: (context, animated) => FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      compactValue ? Formatters.count(animated) : '$animated',
                      maxLines: 1,
                      style: JanMaangTypography.statNumber.copyWith(color: fg),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Insets.sm),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: JanMaangTypography.withWeight(
              JanMaangTypography.bodySm,
              FontWeight.w600,
            ).copyWith(color: fg.withValues(alpha: 0.86)),
          ),
        ],
      ),
    );

    return Semantics(
      label: '$label: ${Formatters.count(value)}',
      button: onTap != null,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(Corners.lg),
        ),
        child: onTap == null
            ? body
            : ClipRRect(
                borderRadius: BorderRadius.circular(Corners.lg),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(onTap: onTap, child: body),
                ),
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pill row
// ---------------------------------------------------------------------------

/// A fully rounded list row: a circular badge, a title over a subtitle, and a
/// chevron in its own circle at the right.
///
/// The reference's most distinctive component, and the one that does the most
/// work here — it is the shape of every navigable item in the product. The
/// [dark] variant fills with navy and is reserved for the row a screen most
/// wants you to press; everything else stays white.
class JmPillRow extends StatefulWidget {
  const JmPillRow({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
    this.onTap,
    this.dark = false,
    this.tint,
    this.trailing,
    this.trailingIcon = Icons.chevron_right_rounded,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  /// Navy fill, white content. One per screen at most.
  final bool dark;

  /// Colours the badge on a light row. Ignored when [dark].
  final JmTint? tint;

  /// Replaces the trailing chevron circle — a status chip, a figure, a count.
  final Widget? trailing;

  final IconData trailingIcon;

  @override
  State<JmPillRow> createState() => _JmPillRowState();
}

class _JmPillRowState extends State<JmPillRow> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final reduced = Motion.reduced(context);
    final tint = widget.tint ?? JmTint.navy;

    final background =
        widget.dark ? scheme.primary : scheme.surfaceContainerLowest;
    final title = widget.dark ? scheme.onPrimary : scheme.onSurface;
    final subtitle = widget.dark
        ? scheme.onPrimary.withValues(alpha: 0.72)
        : scheme.onSurfaceVariant;

    final badgeBackground =
        widget.dark ? scheme.onPrimary : tint.background(brightness);
    final badgeForeground =
        widget.dark ? scheme.primary : tint.foreground(brightness);

    return Semantics(
      button: widget.onTap != null,
      label: widget.subtitle == null
          ? widget.title
          : '${widget.title}. ${widget.subtitle}',
      excludeSemantics: true,
      child: MouseRegion(
        cursor: widget.onTap == null
            ? MouseCursor.defer
            : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedScale(
          scale: reduced || !_pressed ? 1.0 : 0.98,
          duration: Motion.fast,
          curve: Motion.curve,
          child: AnimatedContainer(
            duration: reduced ? Duration.zero : Motion.fast,
            curve: Motion.curve,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(Corners.pill),
              boxShadow: widget.dark
                  ? Shadows.level2
                  : _hovered
                      ? Shadows.level2
                      : Shadows.level1,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Corners.pill),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  onHighlightChanged: (v) => setState(() => _pressed = v),
                  child: Padding(
                    padding: const EdgeInsets.all(Insets.sm + Insets.xs),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: badgeBackground,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.icon,
                            size: 22,
                            color: badgeForeground,
                          ),
                        ),
                        const SizedBox(width: Insets.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                widget.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: JanMaangTypography.withWeight(
                                  JanMaangTypography.bodyMd,
                                  FontWeight.w700,
                                ).copyWith(color: title),
                              ),
                              if (widget.subtitle != null)
                                Text(
                                  widget.subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: JanMaangTypography.bodySm
                                      .copyWith(color: subtitle),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: Insets.sm),
                        if (widget.trailing != null)
                          widget.trailing!
                        else
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: widget.dark
                                  ? scheme.onPrimary.withValues(alpha: 0.16)
                                  : scheme.surfaceContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.trailingIcon,
                              size: 19,
                              color: widget.dark
                                  ? scheme.onPrimary
                                  : scheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Progress card
// ---------------------------------------------------------------------------

/// A single headline figure with a label, a supporting line and a track.
///
/// The reference's "Progress 67%" card. Here it fronts whatever a screen's one
/// most important proportion is.
class JmProgressCard extends StatelessWidget {
  const JmProgressCard({
    super.key,
    required this.label,
    required this.detail,
    required this.percent,
    required this.icon,
    this.footnote,
    this.tint = JmTint.navy,
  });

  final String label;
  final String detail;

  /// 0–100.
  final int percent;

  final IconData icon;

  /// A small line under the track — a source, a caveat, a count.
  final String? footnote;

  final JmTint tint;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final clamped = percent < 0 ? 0 : (percent > 100 ? 100 : percent);

    return Semantics(
      label: '$label, $clamped percent. $detail',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(Insets.md),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(Corners.lg),
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: tint.background(brightness),
                    borderRadius: BorderRadius.circular(Corners.sm + 2),
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: tint.foreground(brightness),
                  ),
                ),
                const SizedBox(width: Insets.sm + Insets.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: JanMaangTypography.withWeight(
                          JanMaangTypography.bodyMd,
                          FontWeight.w700,
                        ).copyWith(color: scheme.onSurface),
                      ),
                      Text(
                        detail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: JanMaangTypography.bodySm
                            .copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Insets.sm),
                JmAnimatedCount(
                  value: clamped,
                  builder: (context, animated) => Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: '$animated',
                          style: JanMaangTypography.statNumber
                              .copyWith(color: scheme.onSurface),
                        ),
                        TextSpan(
                          text: '%',
                          style: JanMaangTypography.withWeight(
                            JanMaangTypography.bodyMd,
                            FontWeight.w700,
                          ).copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Insets.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(Corners.pill),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: clamped / 100),
                duration: Motion.reduced(context)
                    ? Duration.zero
                    : Motion.counter,
                curve: Motion.curve,
                builder: (context, v, _) => LinearProgressIndicator(
                  value: v,
                  minHeight: 8,
                  backgroundColor: scheme.surfaceContainerHigh,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(tint.hue),
                ),
              ),
            ),
            if (footnote != null) ...<Widget>[
              const SizedBox(height: Insets.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  footnote!,
                  style: JanMaangTypography.caption
                      .copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Segmented control
// ---------------------------------------------------------------------------

/// The "Day · Week · Month · Year" toggle.
///
/// A sliding navy pill under plain text labels. Used for every period or view
/// switch in the product, so a filter never has to invent its own shape.
class JmSegmented extends StatelessWidget {
  const JmSegmented({
    super.key,
    required this.segments,
    required this.selectedIndex,
    required this.onSelected,
    this.label,
  });

  final List<String> segments;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// Announced before the segment names, so a screen reader user knows what is
  /// being switched.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final reduced = Motion.reduced(context);
    if (segments.isEmpty) return const SizedBox.shrink();

    final index = selectedIndex < 0
        ? 0
        : selectedIndex > segments.length - 1
            ? segments.length - 1
            : selectedIndex;

    return Semantics(
      label: label,
      container: true,
      child: Container(
        height: Hit.controlDense,
        padding: const EdgeInsets.all(Insets.xs),
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(Corners.pill),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final slot = constraints.maxWidth / segments.length;
            return Stack(
              children: <Widget>[
                AnimatedPositioned(
                  duration: reduced ? Duration.zero : Motion.medium,
                  curve: Motion.curve,
                  left: slot * index,
                  top: 0,
                  bottom: 0,
                  width: slot,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(Corners.pill),
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    for (var i = 0; i < segments.length; i++)
                      Expanded(
                        child: Semantics(
                          button: true,
                          selected: i == index,
                          label: segments[i],
                          excludeSemantics: true,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onSelected(i),
                            child: Center(
                              child: AnimatedDefaultTextStyle(
                                duration:
                                    reduced ? Duration.zero : Motion.fast,
                                curve: Motion.curve,
                                style: JanMaangTypography.withWeight(
                                  JanMaangTypography.bodySm,
                                  i == index
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                ).copyWith(
                                  color: i == index
                                      ? scheme.onPrimary
                                      : scheme.onSurfaceVariant,
                                ),
                                child: Text(
                                  segments[i],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Display heading
// ---------------------------------------------------------------------------

/// The two-tone display headline the reference uses to open a screen: the
/// first phrase in regular weight, the emphasis in bold.
///
/// Kept to one per screen. It is the loudest type in the product and it stops
/// being loud the moment there are two of them.
class JmDisplayHeading extends StatelessWidget {
  const JmDisplayHeading({
    super.key,
    required this.lead,
    this.emphasis,
    this.align = TextAlign.start,
  });

  final String lead;
  final String? emphasis;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base =
        JanMaangTypography.displayLgMobile.copyWith(color: scheme.onSurface);

    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          TextSpan(
            text: emphasis == null ? lead : '$lead ',
            style: JanMaangTypography.withWeight(base, FontWeight.w500),
          ),
          if (emphasis != null)
            TextSpan(
              text: emphasis,
              style: JanMaangTypography.withWeight(base, FontWeight.w700),
            ),
        ],
      ),
      textAlign: align,
    );
  }
}
