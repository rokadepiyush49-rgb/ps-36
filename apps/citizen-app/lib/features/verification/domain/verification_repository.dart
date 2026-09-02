import 'verification.dart';

abstract interface class VerificationRepository {
  Future<VerificationRequest> getRequest(String demandId);

  Future<FieldAssignment> getAssignment(String assignmentId);

  /// Field assignments waiting on the signed-in officer.
  Stream<List<FieldAssignment>> watchAssignments(String uid);

  Future<void> submit(VerificationSubmission submission, String uid);
}
