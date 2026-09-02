import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/janmaang_colors.dart';
import '../../core/theme/janmaang_typography.dart';
import '../models/demand_enums.dart';

/// The six tones every status in the product resolves to.
///
/// A status never picks a colour directly. It picks a tone, and the tone
/// resolves against the current brightness — a light tint behind dark text in
/// light mode, a low-alpha wash behind lifted text in dark mode — so the same
/// badge stays legible on both themes without a second set of constants.
enum JmTone {
  neutral(JanMaangColors.onSurfaceVariant),
  info(JmSemantic.info),
  success(JmSemantic.success),
  warning(JmSemantic.warning),
  critical(JmSemantic.critical),
  gold(JmSemantic.gold);

  const JmTone(this.hue);

  /// The saturated hue this tone is built from.
  final Color hue;

  Color background(Brightness brightness) => switch (brightness) {
        Brightness.light => switch (this) {
            JmTone.neutral => JmSemantic.neutralTint,
            JmTone.info => JmSemantic.infoTint,
            JmTone.success => JmSemantic.successTint,
            JmTone.warning => JmSemantic.warningTint,
            JmTone.critical => JmSemantic.criticalTint,
            JmTone.gold => JmSemantic.goldTint,
          },
        Brightness.dark => hue.withValues(alpha: 0.20),
      };

  Color foreground(Brightness brightness) => switch (brightness) {
        Brightness.light => switch (this) {
            JmTone.neutral => JmSemantic.onNeutralTint,
            JmTone.info => JmSemantic.onInfoTint,
            JmTone.success => JmSemantic.onSuccessTint,
            JmTone.warning => JmSemantic.onWarningTint,
            JmTone.critical => JmSemantic.onCriticalTint,
            JmTone.gold => JmSemantic.onGoldTint,
          },
        Brightness.dark => Color.lerp(hue, const Color(0xFFFFFFFF), 0.62)!,
      };

  /// Hairline for the badge. Keeps it visible where a tint alone would vanish
  /// against a container of a similar value.
  Color border(Brightness brightness) => hue.withValues(
        alpha: brightness == Brightness.light ? 0.22 : 0.42,
      );
}

/// A pill status badge: tinted background, dark legible label, and — wherever
/// the status carries consequence — an icon, so the meaning never rests on
/// colour alone.
class JmStatusChip extends StatelessWidget {
  const JmStatusChip({
    super.key,
    required this.label,
    this.tone = JmTone.neutral,
    this.background,
    this.foreground,
    this.icon,
    this.dense = false,
  });

  factory JmStatusChip.forStatus(DemandStatus status, {bool dense = false}) {
    return switch (status) {
      DemandStatus.reported => JmStatusChip(
          label: 'Reported',
          tone: JmTone.neutral,
          icon: Icons.flag_outlined,
          dense: dense,
        ),
      DemandStatus.verified => JmStatusChip(
          label: 'Under Review',
          tone: JmTone.warning,
          icon: Icons.hourglass_top,
          dense: dense,
        ),
      DemandStatus.clustered => JmStatusChip(
          label: 'Clustered',
          tone: JmTone.info,
          icon: Icons.merge,
          dense: dense,
        ),
      DemandStatus.prioritised => JmStatusChip(
          label: 'Prioritised',
          tone: JmTone.gold,
          icon: Icons.trending_up,
          dense: dense,
        ),
      DemandStatus.funded => JmStatusChip(
          label: 'Funded',
          tone: JmTone.success,
          icon: Icons.payments,
          dense: dense,
        ),
      DemandStatus.inProgress => JmStatusChip(
          label: 'In Progress',
          tone: JmTone.info,
          icon: Icons.construction,
          dense: dense,
        ),
      DemandStatus.citizenVerified => JmStatusChip(
          label: 'Funded & Fixed',
          tone: JmTone.success,
          icon: Icons.verified,
          dense: dense,
        ),
    };
  }

  factory JmStatusChip.forSeverity(Severity severity, {bool dense = false}) {
    return switch (severity) {
      Severity.low => JmStatusChip(
          label: 'LOW PRIORITY',
          tone: JmTone.neutral,
          icon: Icons.remove_rounded,
          dense: dense,
        ),
      Severity.medium => JmStatusChip(
          label: 'MEDIUM PRIORITY',
          tone: JmTone.warning,
          icon: Icons.priority_high_rounded,
          dense: dense,
        ),
      Severity.high => JmStatusChip(
          label: 'HIGH PRIORITY',
          tone: JmTone.critical,
          icon: Icons.warning_amber_rounded,
          dense: dense,
        ),
      Severity.critical => JmStatusChip(
          label: 'CRITICAL',
          tone: JmTone.critical,
          icon: Icons.warning_rounded,
          dense: dense,
        ),
    };
  }

  /// A neutral tag, used for categories.
  factory JmStatusChip.category(DemandCategory category,
          {bool dense = false}) =>
      JmStatusChip(
        label: category.label,
        tone: JmTone.neutral,
        dense: dense,
      );

  final String label;
  final JmTone tone;

  /// Explicit overrides, for the handful of places that need a colour the tone
  /// system does not cover. Prefer [tone].
  final Color? background;
  final Color? foreground;

  final IconData? icon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bg = background ?? tone.background(brightness);
    final fg = foreground ?? tone.foreground(brightness);

    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: dense ? Insets.sm : Insets.sm + Insets.xs,
          vertical: dense ? 3 : Insets.xs + 1,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(Corners.pill),
          border: background == null
              ? Border.all(color: tone.border(brightness))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, size: dense ? 11 : 13, color: fg),
              const SizedBox(width: Insets.xs),
            ],
            Text(
              label,
              style: JanMaangTypography.labelMd.copyWith(color: fg),
            ),
          ],
        ),
      ),
    );
  }
}
