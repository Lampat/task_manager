import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const _themeKey = 'theme_mode';

  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  // Load the theme manager
  Future<void> _loadTheme() async {
    // Get from prefs the value
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey);

    if (themeIndex != null) {
      // If value from prefs not null add it to state
      state = ThemeMode.values[themeIndex];
    }
  }

  // Set the app theme depending on the mode given
  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_themeKey, mode.index);
  }
}

// Provider for the ThemeNotifier
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (ref) => ThemeNotifier(),
);
