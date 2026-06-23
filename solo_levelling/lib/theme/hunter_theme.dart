import 'package:flutter/material.dart';

const shadowBlack = Color(0xFF060812);
const voidBlue = Color(0xFF050714);
const panelBlue = Color(0xFF0B1022);
const manaBlue = Color(0xFF32E5FF);
const runePurple = Color(0xFF9B5CFF);
const successGreen = Color(0xFF6DFFB3);
const warningGold = Color(0xFFFFC857);

ThemeData buildHunterTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: shadowBlack,
    colorScheme: ColorScheme.fromSeed(
      seedColor: manaBlue,
      brightness: Brightness.dark,
      primary: manaBlue,
      secondary: runePurple,
      surface: const Color(0xFF101529),
    ),
    fontFamily: 'Roboto',
    useMaterial3: true,
  );
}
