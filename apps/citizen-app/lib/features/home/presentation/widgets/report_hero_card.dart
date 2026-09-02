import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/janmaang_colors.dart';
import '../../../../core/theme/janmaang_typography.dart';
import '../../../../core/theme/motion.dart';
import '../../../../shared/models/demand_enums.dart';
import '../../../../shared/widgets/jm_card.dart';
import '../../../../shared/widgets/jm_surfaces.dart';

/// The reporting card on Home.
///
/// Voice is still the dominant route — it is the only one that does not
/// require literacy in a script — but it no longer needs a 170px slab to say
/// so. As a dark pill row against three light tiles it is unmistakably the
/// primary action while giving the rest of the dashboard its space back.
class ReportHeroCard extends StatelessWidget {
  const ReportHeroCard({super.key, required this.onStartReport});

  final void Function(ReportChannel channel) onStartReport;

  static const _secondary = <(IconData, String, String, ReportChannel)>[
    (Icons.keyboard_outlined, 'Type', 'in any language', ReportChannel.text),
    (Icons.photo_camera_outlined, 'Photo', 'show the issue', ReportChannel.photo),
    (Icons.my_location_outlined, 'Locate', 'pin the spot', ReportChannel.location),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return JmCard(
      padding: const EdgeInsets.all(Insets.md + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'What does your community need?',
            style: JanMaangTypography.withWeight(
              JanMaangTypography.titleLg,
              FontWeight.w700,
            ).copyWith(color: scheme.onSurface),
          ),
          const SizedBox(height: 2),
          Text(
            'Speak in your own language. We will do the rest.',
            style: JanMaangTypography.bodySm
                .copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: Insets.md),
          JmPillRow(
            title: 'Report by voice',
            subtitle: 'Tap and speak',
            icon: Icons.mic_rounded,
            dark: true,
            trailingIcon: Icons.arrow_forward_rounded,
            onTap: () => onStartReport(ReportChannel.voice),
          ),
          const SizedBox(height: Insets.sm + Insets.xs),
          Row(
            children: <Widget>[
              for (var i = 0; i < _secondary.length; i++) ...<Widget>[
                if (i != 0) const SizedBox(width: Insets.sm),
                Expanded(
                  child: _SecondaryAction(
                    icon: _secondary[i].$1,
                    label: _secondary[i].$2,
                    hint: _secondary[i].$3,
                    onTap: () => onStartReport(_secondary[i].$4),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SecondaryAction extends StatefulWidget {
  const _SecondaryAction({
    required this.icon,
    required this.label,
    required this.hint,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String hint;
  final VoidCallback onTap;

  @override
  State<_SecondaryAction> createState() => _SecondaryActionState();
}

class _SecondaryActionState extends State<_SecondaryAction> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final active = _hovered;

    return Semantics(
      button: true,
      label: '${widget.label} — ${widget.hint}',
      excludeSemantics: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Material(
          color: active
              ? JmTint.navy.background(brightness)
              : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(Corners.base + 2),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: Motion.fast,
              curve: Motion.curve,
              padding: const EdgeInsets.symmetric(
                vertical: Insets.sm + Insets.xs,
                horizontal: Insets.sm,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    widget.icon,
                    size: 20,
                    color: active ? scheme.primary : scheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: Insets.sm - 2),
                  Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: JanMaangTypography.withWeight(
                      JanMaangTypography.bodySm,
                      FontWeight.w700,
                    ).copyWith(color: scheme.onSurface),
                  ),
                  Text(
                    widget.hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: JanMaangTypography.caption
                        .copyWith(color: scheme.onSurfaceVariant),
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
