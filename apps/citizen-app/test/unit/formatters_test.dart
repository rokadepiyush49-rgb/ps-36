import 'package:flutter_test/flutter_test.dart';
import 'package:janmaang/core/utils/formatters.dart';

void main() {
  group('Formatters.count', () {
    test('groups with the Indian numbering system', () {
      expect(Formatters.count(4281), '4,281');
      expect(Formatters.count(100000), '1,00,000');
      expect(Formatters.count(41), '41');
    });
  });

  group('Formatters.rupeesCompact', () {
    test('renders lakhs and crores the way a budget line is read', () {
      expect(Formatters.rupeesCompact(340000), '₹3.40L');
      expect(Formatters.rupeesCompact(1250000), '₹12.5L');
      expect(Formatters.rupeesCompact(28700000), '₹2.87Cr');
      expect(Formatters.rupeesCompact(940), '₹940');
    });
  });

  group('Formatters.relative', () {
    final now = DateTime(2026, 8, 22, 12);

    test('matches the ages shown on the demand cards', () {
      expect(Formatters.relative(now.subtract(const Duration(days: 2)), now: now),
          '2d ago');
      expect(Formatters.relative(now.subtract(const Duration(days: 8)), now: now),
          '1w ago');
      expect(Formatters.relative(now.subtract(const Duration(days: 31)), now: now),
          '1mo ago');
      expect(Formatters.relative(now.subtract(const Duration(hours: 5)), now: now),
          '5h ago');
    });
  });

  group('Formatters.distance', () {
    test('switches to metres below a kilometre', () {
      expect(Formatters.distance(2), '2km away');
      expect(Formatters.distance(1.2), '1.2km away');
      expect(Formatters.distance(0.5), '500m away');
    });
  });
}
