import 'package:flutter_test/flutter_test.dart';
import 'package:janmaang/features/demands/data/demands_repository_mock.dart';
import 'package:janmaang/features/demands/domain/demand.dart';
import 'package:janmaang/features/report/data/report_repository_mock.dart';
import 'package:janmaang/features/report/domain/report_draft.dart';
import 'package:janmaang/shared/models/demand_enums.dart';

void main() {
  late MockDemandsRepository demands;
  late MockReportRepository reports;

  setUp(() {
    demands = MockDemandsRepository();
    reports = MockReportRepository(demands);
  });

  tearDown(() => demands.dispose());

  group('analyze', () {
    test('classifies the water transcript from the designs as high severity',
        () async {
      final analysis = await reports.analyze(
        transcript: 'Our village has not had a functioning drinking water '
            'source for the last two months.',
      );

      expect(analysis.category, DemandCategory.water);
      expect(analysis.severity, Severity.high);
      expect(analysis.title, 'Drinking Water');
      expect(analysis.mentionedLocation, 'Yadgir');
    });

    test('classifies a road report', () async {
      final analysis = await reports.analyze(
        transcript: 'There are large potholes on the road near the school.',
      );
      expect(analysis.category, DemandCategory.roads);
    });

    test('rejects an empty transcript', () {
      expect(
        () => reports.analyze(transcript: '   '),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('submit', () {
    test('mints a code from the category and puts it in My Demands', () async {
      final analysis = await reports.analyze(
        transcript: 'The streetlight near the market is broken and it is dark.',
      );
      final demand = await reports.submit(
        ReportDraft(
          transcript: 'The streetlight near the market is broken.',
          analysis: analysis,
          latitude: 16.77,
          longitude: 77.13,
          locationLabel: 'Ward 4',
        ),
        'uid-1',
      );

      expect(demand.code, startsWith('YDG-LGT-'));
      expect(demand.status, DemandStatus.reported);
      expect(demand.timeline.first.state, TimelineState.active);

      final mine = await demands.watchMyDemands('uid-1').first;
      expect(mine.first.id, demand.id);
    });

    test('refuses to submit a draft that was never analysed', () {
      expect(
        () => reports.submit(const ReportDraft(transcript: 'x'), 'uid-1'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
