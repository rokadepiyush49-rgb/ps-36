import 'dart:async';

import '../../../core/errors/failure.dart';
import '../../../shared/models/demand_enums.dart';
import '../../demands/data/demand_fixtures.dart';
import '../domain/verification.dart';
import '../domain/verification_repository.dart';

class MockVerificationRepository implements VerificationRepository {
  static const _latency = Duration(milliseconds: 500);

  /// The three checks from the Stitch field verification tool.
  static const fieldChecklist = <ChecklistItem>[
    ChecklistItem(
      id: 'complete',
      question: 'Is work complete?',
      hint: 'Verify physical presence of laid pipes in designated trenches.',
    ),
    ChecklistItem(
      id: 'specs',
      question: 'Matches specifications?',
      hint: 'Check pipe diameter and material against tender documents.',
    ),
    ChecklistItem(
      id: 'feedback',
      question: 'Community feedback collected?',
      hint: 'Record brief statements from local residents regarding disruption.',
    ),
  ];

  @override
  Future<VerificationRequest> getRequest(String demandId) async {
    await Future<void>.delayed(_latency);
    final demand = demandId == DemandFixtures.streetlightFixed.id
        ? DemandFixtures.streetlightFixed
        : DemandFixtures.waterDemand;
    return VerificationRequest(
      demandId: demand.id,
      demandTitle: demand.title,
      question: switch (demand.category) {
        DemandCategory.water => 'Is the water source working now?',
        DemandCategory.lighting => 'Are the lights working now?',
        _ => 'Has the problem been fixed?',
      },
      reportedAgo: '2 weeks ago',
    );
  }

  @override
  Future<FieldAssignment> getAssignment(String assignmentId) async {
    await Future<void>.delayed(_latency);
    return const FieldAssignment(
      id: 'assignment-1',
      demandId: 'demand-water-0417',
      projectName: 'Rural Water Pipeline Exp.',
      locationLabel: 'Sector 4, Phase 2',
      objective: 'Confirm completion of phase 2 trenching and pipe laying as '
          'per standard specifications.',
      checklist: fieldChecklist,
    );
  }

  @override
  Stream<List<FieldAssignment>> watchAssignments(String uid) async* {
    await Future<void>.delayed(_latency);
    yield <FieldAssignment>[await getAssignment('assignment-1')];
  }

  @override
  Future<void> submit(VerificationSubmission submission, String uid) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (submission.kind == VerificationKind.field &&
        submission.checklist.any((c) => !c.checked)) {
      throw const ValidationFailure(
        'Complete every checklist item before submitting.',
      );
    }
  }
}
