import 'package:intl/intl.dart';

/// Formatting helpers. Currency and counts use the Indian numbering system,
/// which is what a district budget is actually read in.
abstract final class Formatters {
  static final _count = NumberFormat.decimalPattern('en_IN');
  static final _currency =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
  static final _dayMonthYear = DateFormat('d MMM yyyy');
  static final _dayMonth = DateFormat('d MMM');

  static String count(int value) => _count.format(value);

  static String rupees(int value) => _currency.format(value);

  /// 12,50,000 → "₹12.5L", 2,87,00,000 → "₹2.87Cr". Budgets are quoted this way.
  static String rupeesCompact(int value) {
    if (value >= 10000000) {
      final cr = value / 10000000;
      return '₹${cr.toStringAsFixed(cr >= 10 ? 1 : 2)}Cr';
    }
    if (value >= 100000) {
      final lakh = value / 100000;
      return '₹${lakh.toStringAsFixed(lakh >= 10 ? 1 : 2)}L';
    }
    if (value >= 1000) return '₹${(value / 1000).toStringAsFixed(1)}K';
    return '₹$value';
  }

  static String date(DateTime value) => _dayMonthYear.format(value);

  static String shortDate(DateTime value) => _dayMonth.format(value);

  /// "2d ago", "1w ago", "1mo ago" — the timestamps on the demand cards.
  static String relative(DateTime value, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final diff = reference.difference(value);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }

  /// "2km away" / "500m away" for the Near You list.
  static String distance(double km) =>
      km < 1 ? '${(km * 1000).round()}m away' : '${_trim(km)}km away';

  static String _trim(double value) =>
      value == value.roundToDouble() ? value.round().toString() : value.toStringAsFixed(1);
}
