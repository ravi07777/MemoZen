import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

final selectedThemeProvider = StateNotifierProvider<SelectedThemeNotifier, int>((ref) {
  return SelectedThemeNotifier();
});

final appThemeProvider = Provider<AppColorTheme>((ref) {
  final index = ref.watch(selectedThemeProvider);
  return allThemes[index];
});

final themeDataProvider = Provider<ThemeData>((ref) {
  final themeIndex = ref.watch(selectedThemeProvider);
  final mode = ref.watch(themeModeProvider);
  final isDark = mode == ThemeMode.dark;
  final selected = allThemes[isDark ? allThemes.length - 1 : themeIndex];
  return selected.toThemeData();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString('themeMode') ?? 'light';
    state = mode == 'dark'
        ? ThemeMode.dark
        : mode == 'system'
            ? ThemeMode.system
            : ThemeMode.light;
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    final modeStr = mode == ThemeMode.dark
        ? 'dark'
        : mode == ThemeMode.system
            ? 'system'
            : 'light';
    await prefs.setString('themeMode', modeStr);
  }
}

class SelectedThemeNotifier extends StateNotifier<int> {
  SelectedThemeNotifier() : super(0) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt('selectedTheme') ?? 0;
  }

  Future<void> select(int index) async {
    state = index;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedTheme', index);
  }
}
