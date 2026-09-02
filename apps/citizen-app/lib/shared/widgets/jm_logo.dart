import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/janmaang_typography.dart';

/// The JanMaang brand lockup.
///
/// Two forms, matching how the mark is actually used:
/// * [JmLogo.mark] — the petal symbol alone, for the app bar and tight spots.
/// * [JmLogo.full] — symbol over the bilingual wordmark, for the onboarding
///   hero, the login header and the splash screen.
///
/// The artwork is loaded from `assets/brand/`. While those files are absent the
/// widget falls back to a typographic lockup in the design-system colours, so a
/// fresh clone still builds and renders sensibly.
class JmLogo extends StatelessWidget {
  /// The petal symbol alone. [size] is both its width and height.
  const JmLogo.mark({super.key, this.size = 28})
      : _variant = _LogoVariant.mark,
        showTagline = false;

  /// The stacked lockup. [width] sets the overall width; height follows the
  /// artwork's aspect ratio.
  const JmLogo.full({super.key, double width = 120, this.showTagline = true})
      : size = width,
        _variant = _LogoVariant.full;

  /// Symbol height for [JmLogo.mark]; lockup width for [JmLogo.full].
  final double size;
  final bool showTagline;
  final _LogoVariant _variant;

  static const markAsset = 'assets/brand/janmaang_mark.png';
  static const fullAsset = 'assets/brand/janmaang_logo.png';

  static const tagline = 'Together we listen. Together we build.';

  @override
  Widget build(BuildContext context) {
    return switch (_variant) {
      _LogoVariant.mark => _Mark(size: size),
      _LogoVariant.full => _Full(width: size, showTagline: showTagline),
    };
  }
}

enum _LogoVariant { mark, full }

class _Mark extends StatelessWidget {
  const _Mark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      label: 'JanMaang',
      image: true,
      child: Image.asset(
        JmLogo.markAsset,
        height: size,
        width: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.account_balance,
          size: size * 0.85,
          color: scheme.primary,
        ),
      ),
    );
  }
}

class _Full extends StatelessWidget {
  const _Full({required this.width, required this.showTagline});

  final double width;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      label: 'JanMaang — ${JmLogo.tagline}',
      image: true,
      child: Image.asset(
        JmLogo.fullAsset,
        width: width,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stackTrace) => Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _Mark(size: width * 0.42),
            const SizedBox(height: Insets.sm),
            Text(
              'JanMaang',
              textAlign: TextAlign.center,
              style: JanMaangTypography.displayLgMobile.copyWith(
                color: scheme.primary,
                fontSize: width * 0.2,
              ),
            ),
            if (showTagline) ...<Widget>[
              const SizedBox(height: Insets.xs),
              Text(
                JmLogo.tagline,
                textAlign: TextAlign.center,
                style: JanMaangTypography.labelMd
                    .copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The brand lockup as it appears in the app bar: the mark beside the
/// wordmark, sized for a 56px bar.
class JmBrandRow extends StatelessWidget {
  const JmBrandRow({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        JmLogo.mark(size: compact ? 24 : 30),
        const SizedBox(width: Insets.sm),
        Text(
          'JanMaang',
          style: (compact
                  ? JanMaangTypography.titleLg
                  : JanMaangTypography.headlineSm)
              .copyWith(color: scheme.primary),
        ),
      ],
    );
  }
}
