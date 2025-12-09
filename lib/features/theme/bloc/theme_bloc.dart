import 'dart:async';
import 'package:bar_bros_user/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_event.dart';
part 'theme_state.dart';

@lazySingleton
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState(AppTheme.dark, true)) {
    on<LoadTheme>(_onLoadTheme);
    on<ToggleTheme>(_onToggleTheme);

    add(LoadTheme());
  }

  Future<void> _onLoadTheme(LoadTheme event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('is_dark_theme') ?? true;
    emit(ThemeState(isDark ? AppTheme.dark : AppTheme.light, isDark));
  }

  Future<void> _onToggleTheme(ToggleTheme event, Emitter<ThemeState> emit) async {
    final newIsDark = !state.isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_theme', newIsDark);
    emit(ThemeState(newIsDark ? AppTheme.dark : AppTheme.light, newIsDark));
  }
}