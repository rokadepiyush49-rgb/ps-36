import '../../demands/domain/demand.dart';
import 'report_draft.dart';

abstract interface class ReportRepository {
  /// Sends the transcript to the `analyzeReport` callable, which runs Gemini
  /// server-side. No model key is ever present on the device.
  Future<ReportAnalysis> analyze({
    required String transcript,
    List<String> photoPaths = const <String>[],
  });

  /// Persists the report and returns the created demand.
  Future<Demand> submit(ReportDraft draft, String uid);

  /// Uploads evidence to Cloud Storage and returns download URLs.
  Future<List<String>> uploadPhotos(List<String> localPaths, String uid);
}
