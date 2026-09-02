import 'package:flutter/foundation.dart';

import '../../../shared/models/demand_enums.dart';

/// A citizen confirming whether a funded fix actually worked, or a field
/// officer capturing evidence against a checklist.
@immutable
class VerificationSubmission {
  const VerificationSubmission({
    required this.demandId,
    required this.kind,
    required this.isFixed,
    this.checklist = const <ChecklistItem>[],
    this.photoPaths = const <String>[],
    this.note = '',
    this.latitude,
    this.longitude,
  });

  final String demandId;
  final VerificationKind kind;
  final bool isFixed;
  final List<ChecklistItem> checklist;
  final List<String> photoPaths;
  final String note;
  final double? latitude;
  final double? longitude;
}

@immutable
class ChecklistItem {
  const ChecklistItem({
    required this.id,
    required this.question,
    required this.hint,
    this.checked = false,
  });

  final String id;
  final String question;
  final String hint;
  final bool checked;

  ChecklistItem copyWith({bool? checked}) => ChecklistItem(
        id: id,
        question: question,
        hint: hint,
        checked: checked ?? this.checked,
      );
}

/// The work a field officer has been assigned — the header of the field tool.
@immutable
class FieldAssignment {
  const FieldAssignment({
    required this.id,
    required this.demandId,
    required this.projectName,
    required this.locationLabel,
    required this.objective,
    required this.checklist,
    this.beforePhotoUrl,
  });

  final String id;
  final String demandId;
  final String projectName;
  final String locationLabel;
  final String objective;
  final List<ChecklistItem> checklist;
  final String? beforePhotoUrl;
}

/// What the citizen verification screen shows: the original report and its
/// "before" photograph, against which they judge the current state.
@immutable
class VerificationRequest {
  const VerificationRequest({
    required this.demandId,
    required this.demandTitle,
    required this.question,
    this.beforePhotoUrl,
    this.reportedAgo = '',
  });

  final String demandId;
  final String demandTitle;

  /// "Is the water source working now?"
  final String question;
  final String? beforePhotoUrl;
  final String reportedAgo;
}
