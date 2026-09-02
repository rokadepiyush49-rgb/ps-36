import '../../../core/errors/failure.dart';
import '../../../shared/models/demand_enums.dart';
import '../../demands/data/demand_fixtures.dart';
import '../../demands/data/demands_repository_mock.dart';
import '../../demands/domain/demand.dart';
import '../domain/report_draft.dart';
import '../domain/report_repository.dart';

/// Stands in for the `analyzeReport` Cloud Function. The keyword pass here is a
/// deliberate stub: in production the same call goes to Gemini server-side and
/// returns the identical shape, so nothing above this layer changes.
class MockReportRepository implements ReportRepository {
  MockReportRepository(this._demands);

  final MockDemandsRepository _demands;

  static const _analysisLatency = Duration(milliseconds: 1400);

  /// Keyword hints per category. Matching is whole-word, so "streetlight"
  /// does not fall into Roads on the strength of "street".
  static const _keywords = <DemandCategory, List<String>>{
    DemandCategory.water: [
      'water', 'pump', 'handpump', 'borewell', 'tap', 'tank', 'pipeline',
      'पानी', 'नल',
    ],
    DemandCategory.lighting: [
      'light', 'lights', 'lighting', 'streetlight', 'streetlights', 'lamp',
      'lamps', 'dark', 'बत्ती',
    ],
    DemandCategory.roads: [
      'road', 'roads', 'pothole', 'potholes', 'bridge', 'culvert', 'footpath',
      'सड़क',
    ],
    DemandCategory.sanitation: [
      'toilet', 'toilets', 'drain', 'drains', 'garbage', 'sewage', 'waste',
      'desilting', 'शौचालय',
    ],
    DemandCategory.health: [
      'clinic', 'hospital', 'doctor', 'medicine', 'phc', 'ambulance', 'nurse',
    ],
    DemandCategory.education: [
      'school', 'teacher', 'teachers', 'classroom', 'anganwadi', 'स्कूल',
    ],
    DemandCategory.electricity: [
      'power', 'electricity', 'transformer', 'outage', 'wiring', 'बिजली',
    ],
    DemandCategory.transport: ['bus', 'buses', 'transport', 'auto', 'connectivity'],
  };

  /// Counts whole-word keyword hits for a category. Non-ASCII keywords fall
  /// back to a substring test, since word boundaries are unreliable there.
  static int _score(String text, List<String> keywords) {
    var hits = 0;
    for (final keyword in keywords) {
      final isAscii = keyword.codeUnits.every((c) => c < 128);
      final matched = isAscii
          ? RegExp('\\b${RegExp.escape(keyword)}\\b').hasMatch(text)
          : text.contains(keyword);
      if (matched) hits++;
    }
    return hits;
  }

  @override
  Future<ReportAnalysis> analyze({
    required String transcript,
    List<String> photoPaths = const <String>[],
  }) async {
    await Future<void>.delayed(_analysisLatency);
    final text = transcript.toLowerCase();
    if (text.trim().isEmpty) {
      throw const ValidationFailure('Tell us what the problem is first.');
    }

    // The category with the most whole-word hits wins, so a transcript that
    // mentions both "streetlight" and "dark" lands on Lighting rather than on
    // whichever category happened to be checked first.
    var category = DemandCategory.other;
    var best = 0;
    for (final entry in _keywords.entries) {
      final hits = _score(text, entry.value);
      if (hits > best) {
        best = hits;
        category = entry.key;
      }
    }

    // Long-standing or total failures read as high severity.
    final severity = RegExp(r'\b(month|months|no |not |never|completely|failed)\b')
            .hasMatch(text)
        ? Severity.high
        : Severity.medium;

    return ReportAnalysis(
      category: category,
      severity: severity,
      title: _titleFor(category),
      mentionedLocation: _extractPlace(transcript),
      summary: transcript.trim(),
    );
  }

  static String _titleFor(DemandCategory category) => switch (category) {
        DemandCategory.water => 'Drinking Water',
        DemandCategory.roads => 'Road Repair',
        DemandCategory.lighting => 'Street Lighting',
        DemandCategory.sanitation => 'Sanitation',
        DemandCategory.health => 'Health Services',
        DemandCategory.education => 'Education',
        DemandCategory.electricity => 'Electricity Supply',
        DemandCategory.transport => 'Public Transport',
        DemandCategory.other => 'Civic Issue',
      };

  static String _extractPlace(String transcript) {
    const known = <String>['Yadgir', 'Shahapur', 'Surpur', 'Gurmitkal'];
    for (final place in known) {
      if (transcript.toLowerCase().contains(place.toLowerCase())) return place;
    }
    return 'Yadgir';
  }

  @override
  Future<Demand> submit(ReportDraft draft, String uid) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final analysis = draft.analysis;
    if (analysis == null) {
      throw const ValidationFailure('The report has not been analysed yet.');
    }

    final id = 'demand-${DateTime.now().millisecondsSinceEpoch}';
    final serial = DateTime.now().millisecondsSinceEpoch % 10000;
    final demand = Demand(
      id: id,
      code: 'YDG-${analysis.category.code}-${serial.toString().padLeft(4, '0')}',
      title: analysis.title,
      description: analysis.summary,
      transcript: draft.transcript,
      reporterId: uid,
      category: analysis.category,
      severity: analysis.severity,
      status: DemandStatus.reported,
      ward: draft.locationLabel,
      district: 'Yadgir',
      latitude: draft.latitude,
      longitude: draft.longitude,
      photoUrls: draft.photoPaths,
      channel: draft.channel,
      createdAt: DateTime.now(),
      timeline: const <TimelineEvent>[
        TimelineEvent(status: DemandStatus.reported, state: TimelineState.active),
        TimelineEvent(status: DemandStatus.verified, state: TimelineState.upcoming),
        TimelineEvent(status: DemandStatus.clustered, state: TimelineState.upcoming),
        TimelineEvent(
            status: DemandStatus.prioritised, state: TimelineState.upcoming),
        TimelineEvent(status: DemandStatus.funded, state: TimelineState.upcoming),
        TimelineEvent(
            status: DemandStatus.inProgress, state: TimelineState.upcoming),
        TimelineEvent(
            status: DemandStatus.citizenVerified, state: TimelineState.upcoming),
      ],
    );
    _demands.addDemand(demand);
    return demand;
  }

  @override
  Future<List<String>> uploadPhotos(List<String> localPaths, String uid) async {
    await Future<void>.delayed(Duration(milliseconds: 300 * localPaths.length));
    return localPaths;
  }

  /// Exposed so the report flow can reuse the canonical fixture transcript when
  /// speech recognition is unavailable on the device.
  static String get sampleTranscript => DemandFixtures.waterDemand.transcript;
}
