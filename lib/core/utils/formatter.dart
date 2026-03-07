import 'package:intl/intl.dart';

abstract final class Formatter {
  // ─── Currency ────────────────────────────────────────────────────────────
  static String currency(double amount, {String symbol = 'R'}) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: 2,
      locale: 'en_ZA',
    );
    return formatter.format(amount);
  }

  static String currencyCompact(double amount, {String symbol = 'R'}) {
    if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}k';
    }
    return currency(amount, symbol: symbol);
  }

  // ─── Date & Time ─────────────────────────────────────────────────────────
  static String date(DateTime date) => DateFormat('dd MMM yyyy').format(date);

  static String dateShort(DateTime date) =>
      DateFormat('dd/MM/yyyy').format(date);

  static String time(DateTime date) => DateFormat('HH:mm').format(date);

  static String dateTime(DateTime date) =>
      DateFormat('dd MMM yyyy • HH:mm').format(date);

  static String dayMonth(DateTime date) => DateFormat('d MMM').format(date);

  static String weekday(DateTime date) => DateFormat('EEEE').format(date);

  static String monthYear(DateTime date) =>
      DateFormat('MMMM yyyy').format(date);

  static String relativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return Formatter.date(date);
  }

  static String duration(Duration d) {
    if (d.inSeconds < 60) return '${d.inSeconds}s';
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  // ─── Numbers ─────────────────────────────────────────────────────────────
  static String number(num value) =>
      NumberFormat.decimalPattern('en').format(value);

  static String percentage(double value, {int decimals = 1}) =>
      '${value.toStringAsFixed(decimals)}%';

  // ─── Names ───────────────────────────────────────────────────────────────
  static String initials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  static String capitalize(String text) =>
      text.isEmpty ? '' : '${text[0].toUpperCase()}${text.substring(1)}';

  static String titleCase(String text) => text
      .split(' ')
      .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  // ─── Phone ───────────────────────────────────────────────────────────────
  static String phone(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) {
      return '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6)}';
    }
    return raw;
  }

  // ─── File size ───────────────────────────────────────────────────────────
  static String fileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  // ─── Age ─────────────────────────────────────────────────────────────────
  static String age(DateTime dob) {
    final now = DateTime.now();
    int years = now.year - dob.year;
    int months = now.month - dob.month;
    if (now.day < dob.day) months--;
    if (months < 0) {
      years--;
      months += 12;
    }
    if (years == 0) return '$months month${months == 1 ? '' : 's'}';
    if (months == 0) return '$years year${years == 1 ? '' : 's'}';
    return '$years yr $months mo';
  }
}
