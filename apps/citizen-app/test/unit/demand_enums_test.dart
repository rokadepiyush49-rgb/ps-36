import 'package:flutter_test/flutter_test.dart';
import 'package:janmaang/shared/models/demand_enums.dart';

void main() {
  group('DemandStatus', () {
    test('orders the seven lifecycle stages as the timeline does', () {
      expect(
        DemandStatus.values.map((s) => s.label).toList(),
        <String>[
          'Reported',
          'Verified',
          'Clustered',
          'Prioritised',
          'Funded',
          'In Progress',
          'Citizen Verified',
        ],
      );
    });

    test('isBefore follows the lifecycle order', () {
      expect(DemandStatus.reported.isBefore(DemandStatus.funded), isTrue);
      expect(DemandStatus.funded.isBefore(DemandStatus.reported), isFalse);
    });

    test('falls back to reported for an unknown name', () {
      expect(DemandStatus.fromName('nonsense'), DemandStatus.reported);
      expect(DemandStatus.fromName('funded'), DemandStatus.funded);
    });
  });

  group('DemandCategory', () {
    test('exposes the three-letter code used in demand identifiers', () {
      expect(DemandCategory.water.code, 'WTR');
      expect(DemandCategory.roads.code, 'ROD');
      expect(DemandCategory.lighting.code, 'LGT');
    });
  });
}
