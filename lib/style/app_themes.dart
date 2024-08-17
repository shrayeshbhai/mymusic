/*
 *     Copyright (C) 2024 Valeri Gokadze
 *
 *     Shreeya is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     Shreeya is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 *
 *     For more information about Shreeya, including how to contribute,
 *     please visit: https://github.com/gokadzev/Shreeya
 */

import 'package:Shreeya/services/settings_manager.dart';
import 'package:Shreeya/style/dynamic_color_temp_fix.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

ThemeMode themeMode = getThemeMode(themeModeSetting);
Brightness brightness = getBrightnessFromThemeMode(themeMode);

Brightness getBrightnessFromThemeMode(
  ThemeMode themeMode,
) {
  final themeBrightnessMapping = {
    ThemeMode.light: Brightness.light,
    ThemeMode.dark: Brightness.dark,
    ThemeMode.system:
        SchedulerBinding.instance.platformDispatcher.platformBrightness,
  };

  return themeBrightnessMapping[themeMode] ?? Brightness.dark;
}

ThemeMode getThemeMode(String themeModeString) {
  switch (themeModeString) {
    case 'system':
      return ThemeMode.system;
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}

ColorScheme getAppColorScheme(
  ColorScheme? lightColorScheme,
  ColorScheme? darkColorScheme,
) {
  if (useSystemColor.value &&
      lightColorScheme != null &&
      darkColorScheme != null) {
    // Temporary fix until this will be fixed: https://github.com/material-foundation/flutter-packages/issues/582

    (lightColorScheme, darkColorScheme) =
        tempGenerateDynamicColourSchemes(lightColorScheme, darkColorScheme);
  }

  final selectedScheme =
      (brightness == Brightness.light) ? lightColorScheme : darkColorScheme;

  if (useSystemColor.value && selectedScheme != null) {
    return selectedScheme;
  } else {
    return ColorScheme.fromSeed(
      seedColor: primaryColorSetting,
      brightness: brightness,
    ).harmonized();
  }
}

ThemeData getAppTheme(ColorScheme colorScheme) {
  final base = colorScheme.brightness == Brightness.light
      ? ThemeData.light()
      : ThemeData.dark();

  final isPureBlackUsable =
      colorScheme.brightness == Brightness.dark && usePureBlackColor.value;

  final bgColor = colorScheme.brightness == Brightness.light
      ? colorScheme.surfaceContainer
      : (isPureBlackUsable ? const Color(0xFF000000) : null);

  return ThemeData(
    scaffoldBackgroundColor: bgColor,
    colorScheme: colorScheme,
    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: bgColor,
      iconTheme: IconThemeData(color: colorScheme.primary),
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: colorScheme.primary,
      ),
      elevation: 0,
    ),
    listTileTheme: base.listTileTheme.copyWith(
      textColor: colorScheme.primary,
      iconColor: colorScheme.primary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.fromLTRB(18, 14, 20, 14),
    ),
    navigationBarTheme: isPureBlackUsable && bgColor != null
        ? base.navigationBarTheme.copyWith(backgroundColor: bgColor)
        : null,
    sliderTheme: const SliderThemeData(trackHeight: 1.8),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    useMaterial3: true,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
