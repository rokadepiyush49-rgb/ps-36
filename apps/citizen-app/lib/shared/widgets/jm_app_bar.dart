import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/janmaang_typography.dart';
import 'jm_logo.dart';

/// The top app bar.
///
/// Two forms: the JanMaang lockup with trailing actions on tab screens, or a
/// back arrow with a screen title on transactional screens. Flat, no shadow —
/// a single hairline is the only thing separating it from the page, and the
/// trailing actions sit in soft circular wells so they read as controls rather
/// than as loose glyphs floating beside the brand.
class JmAppBar extends StatelessWidget implements PreferredSizeWidget {
  const JmAppBar({
    super.key,
    this.title,
    this.showBrand = false,
    this.showBack = false,
    this.onBack,
    this.actions,
    this.hasUnreadNotifications = true,
    this.onNotifications,
    this.onProfile,
  });

  /// A transactional bar: back arrow, title, no trailing icons.
  const JmAppBar.task({
    super.key,
    required this.title,
    this.onBack,
    this.actions,
  })  : showBrand = false,
        showBack = true,
        hasUnreadNotifications = false,
        onNotifications = null,
        onProfile = null;

  final String? title;
  final bool showBrand;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final bool hasUnreadNotifications;
  final VoidCallback? onNotifications;
  final VoidCallback? onProfile;

  static const _height = 60.0;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          bottom: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.7)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: _height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Insets.sm),
            child: Row(
              children: <Widget>[
                if (showBack)
                  _BarButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Back',
                    onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                  )
                else
                  const SizedBox(width: Insets.sm),
                if (showBrand)
                  const JmBrandRow()
                else if (title != null)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: Insets.xs),
                      child: Text(
                        title!,
                        overflow: TextOverflow.ellipsis,
                        style: JanMaangTypography.titleLg
                            .copyWith(color: scheme.onSurface),
                      ),
                    ),
                  ),
                const Spacer(),
                if (actions != null)
                  ...actions!
                else if (!showBack) ...<Widget>[
                  _BarButton(
                    icon: Icons.notifications_none_rounded,
                    tooltip: 'Notifications',
                    badge: hasUnreadNotifications,
                    onPressed: onNotifications,
                  ),
                  const SizedBox(width: Insets.xs),
                  _BarButton(
                    icon: Icons.person_outline_rounded,
                    tooltip: 'Profile',
                    onPressed: onProfile,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A 40px circular well with a 48px tap target around it, so the control meets
/// the accessibility minimum without looking oversized next to the wordmark.
class _BarButton extends StatelessWidget {
  const _BarButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.badge = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  /// Draws the unread pip, ringed in the surface colour so it stays visible
  /// wherever it lands on the glyph.
  final bool badge;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: badge ? '$tooltip, unread' : tooltip,
        excludeSemantics: true,
        child: SizedBox(
          width: Hit.min,
          height: Hit.min,
          child: Center(
            child: Material(
              color: scheme.surfaceContainerLow,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onPressed,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Icon(icon, size: 21, color: scheme.onSurfaceVariant),
                      if (badge)
                        Positioned(
                          top: 9,
                          right: 10,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: scheme.error,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: scheme.surfaceContainerLow,
                                width: 1.5,
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
      ),
    );
  }
}
