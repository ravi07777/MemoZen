import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Color cardColor(BuildContext context) {
  final cardTheme = Theme.of(context).cardTheme;
  return cardTheme.color ?? Theme.of(context).colorScheme.surface;
}

String formatDate(DateTime date) {
  return DateFormat('MMM dd, yyyy').format(date);
}

String formatTime(DateTime date) {
  return DateFormat('hh:mm a').format(date);
}

String formatDuration(int minutes) {
  if (minutes < 60) {
    return '$minutes min';
  }
  final hours = minutes ~/ 60;
  final mins = minutes % 60;
  if (mins == 0) return '${hours}h';
  return '${hours}h ${mins}m';
}

String timeAgo(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);
  if (diff.inDays > 365) return '${diff.inDays ~/ 365}y ago';
  if (diff.inDays > 30) return '${diff.inDays ~/ 30}mo ago';
  if (diff.inDays > 7) return '${diff.inDays ~/ 7}w ago';
  if (diff.inDays > 0) return '${diff.inDays}d ago';
  if (diff.inHours > 0) return '${diff.inHours}h ago';
  if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
  return 'Just now';
}

String greeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

String ordinal(int number) {
  final suffixes = ['th', 'st', 'nd', 'rd'];
  final v = number % 100;
  if (v >= 11 && v <= 13) return '${number}th';
  final suffix = suffixes[(v % 10) < 4 ? v % 10 : 0];
  return '$number$suffix';
}

DateTime dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

DateTime startOfWeek(DateTime date) {
  final weekday = date.weekday;
  return dateOnly(date.subtract(Duration(days: weekday - 1)));
}

DateTime endOfWeek(DateTime date) {
  final weekday = date.weekday;
  return dateOnly(date.add(Duration(days: 7 - weekday)));
}

DateTime startOfMonth(DateTime date) {
  return DateTime(date.year, date.month, 1);
}

DateTime endOfMonth(DateTime date) {
  return DateTime(date.year, date.month + 1, 0);
}

List<DateTime> getDaysInMonth(DateTime date) {
  final first = startOfMonth(date);
  final last = endOfMonth(date);
  final days = <DateTime>[];
  for (var i = 0; i < last.day; i++) {
    days.add(DateTime(first.year, first.month, i + 1));
  }
  return days;
}
