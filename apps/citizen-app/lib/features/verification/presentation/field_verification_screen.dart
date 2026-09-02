import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failure.dart';
import '../../../core/providers.dart';
import '../../../core/services/media_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/janmaang_typography.dart';
import '../../../shared/models/demand_enums.dart';
import '../../../shared/widgets/jm_app_bar.dart';
import '../../../shared/widgets/jm_card.dart';
import '../../../shared/widgets/jm_photo_dropzone.dart';
import '../../../shared/widgets/jm_states.dart';
import '../../../shared/widgets/jm_status_chip.dart';
import '../domain/verification.dart';

final fieldAssignmentProvider =
    FutureProvider.autoDispose.family<FieldAssignment, String>((ref, id) {
  return ref.watch(verificationRepositoryProvider).getAssignment(id);
});

/// Field Evidence Capture — the Stitch field verification tool.
///
/// Assignment header with the objective, the checklist, geotagged photo
/// capture, and a docked Submit action.
class FieldVerificationScreen extends ConsumerStatefulWidget {
  const FieldVerificationScreen({super.key, required this.assignmentId});

  final String assignmentId;

  @override
  ConsumerState<FieldVerificationScreen> createState() =>
      _FieldVerificationScreenState();
}

class _FieldVerificationScreenState
    extends ConsumerState<FieldVerificationScreen> {
  List<ChecklistItem> _checklist = const <ChecklistItem>[];
  final List<String> _photos = <String>[];
  bool _submitting = false;
  bool _seeded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final assignmentAsync = ref.watch(fieldAssignmentProvider(widget.assignmentId));

    return Scaffold(
      appBar: JmAppBar.task(title: 'Field Evidence Capture'),
      body: assignmentAsync.when(
        loading: () => const JmLoader(),
        error: (error, _) => JmErrorView(
          error: error,
          onRetry: () =>
              ref.invalidate(fieldAssignmentProvider(widget.assignmentId)),
        ),
        data: (assignment) {
          if (!_seeded) {
            _checklist = assignment.checklist;
            _seeded = true;
          }
          return _body(context, assignment);
        },
      ),
      bottomNavigationBar: assignmentAsync.maybeWhen(
        data: (assignment) => Container(
          padding: EdgeInsets.fromLTRB(
            Insets.marginMobile,
            Insets.md,
            Insets.marginMobile,
            Insets.md + MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: scheme.surface,
            border: Border(top: BorderSide(color: scheme.outlineVariant)),
          ),
          child: FilledButton.icon(
            onPressed: _submitting ? null : () => _submit(assignment),
            icon: _submitting
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: scheme.onPrimary,
                    ),
                  )
                : const Icon(Icons.upload, size: 20),
            label: const Text('Submit Verification'),
          ),
        ),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }

  Widget _body(BuildContext context, FieldAssignment assignment) {
    final scheme = Theme.of(context).colorScheme;
    final completed = _checklist.where((c) => c.checked).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Insets.marginMobile,
        Insets.lg,
        Insets.marginMobile,
        Insets.xl,
      ),
      children: <Widget>[
        JmCard(
          padding: const EdgeInsets.all(Insets.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const JmStatusChip(
                label: 'ASSIGNED',
                tone: JmTone.info,
                icon: Icons.assignment_outlined,
                dense: true,
              ),
              const SizedBox(height: Insets.sm),
              Text(
                assignment.projectName,
                style: JanMaangTypography.headlineSm
                    .copyWith(color: scheme.onSurface),
              ),
              const SizedBox(height: Insets.xs),
              Row(
                children: <Widget>[
                  Icon(Icons.location_on_outlined,
                      size: 16, color: scheme.onSurfaceVariant),
                  const SizedBox(width: Insets.xs),
                  Text(
                    assignment.locationLabel,
                    style: JanMaangTypography.bodySm
                        .copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: Insets.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Insets.md),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(Corners.base),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'VERIFICATION OBJECTIVE',
                      style: JanMaangTypography.labelMd
                          .copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: Insets.xs),
                    Text(
                      assignment.objective,
                      style: JanMaangTypography.bodyMd
                          .copyWith(color: scheme.onSurface),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Insets.lg),

        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Verification Checklist',
                style: JanMaangTypography.titleLg
                    .copyWith(color: scheme.onSurface),
              ),
            ),
            Text(
              '$completed of ${_checklist.length}',
              style: JanMaangTypography.tabularNums
                  .copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: Insets.md),
        for (var i = 0; i < _checklist.length; i++) ...<Widget>[
          _ChecklistTile(
            item: _checklist[i],
            onChanged: (checked) => setState(() {
              _checklist = <ChecklistItem>[
                for (var j = 0; j < _checklist.length; j++)
                  j == i ? _checklist[j].copyWith(checked: checked) : _checklist[j],
              ];
            }),
          ),
          const SizedBox(height: Insets.sm),
        ],

        const SizedBox(height: Insets.lg),
        Text(
          'Photographic Evidence',
          style: JanMaangTypography.titleLg.copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: Insets.md),
        JmPhotoDropzone(
          onTap: _capture,
          paths: _photos,
          onRemove: (i) => setState(() => _photos.removeAt(i)),
        ),
      ],
    );
  }

  Future<void> _capture() async {
    final path = await ref.read(mediaServiceProvider).capturePhoto();
    if (path != null && mounted) setState(() => _photos.add(path));
  }

  Future<void> _submit(FieldAssignment assignment) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _submitting = true);
    try {
      await ref.read(verificationRepositoryProvider).submit(
            VerificationSubmission(
              demandId: assignment.demandId,
              kind: VerificationKind.field,
              isFixed: _checklist.every((c) => c.checked),
              checklist: _checklist,
              photoPaths: _photos,
            ),
            user.uid,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification submitted.')),
      );
      Navigator.of(context).maybePop();
    } on Failure catch (failure) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({required this.item, required this.onChanged});

  final ChecklistItem item;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return JmCard(
      onTap: () => onChanged(!item.checked),
      radius: Corners.base,
      padding: const EdgeInsets.all(Insets.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Checkbox(
            value: item.checked,
            onChanged: (value) => onChanged(value ?? false),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Corners.sm),
            ),
          ),
          const SizedBox(width: Insets.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.question,
                  style: JanMaangTypography.withWeight(
                    JanMaangTypography.bodyMd,
                    FontWeight.w600,
                  ).copyWith(color: scheme.onSurface),
                ),
                const SizedBox(height: 2),
                Text(
                  item.hint,
                  style: JanMaangTypography.bodySm
                      .copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
