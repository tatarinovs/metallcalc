import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/calculator_screen.dart';

void main() {
  runApp(const MetallCalcApp());
}

class MetallCalcApp extends StatelessWidget {
  const MetallCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Металлокалькулятор',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const CalculatorScreen(),
    );
  }
}
