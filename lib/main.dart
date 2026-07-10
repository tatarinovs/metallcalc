import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/calculator_screen.dart';

import 'services/prefs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initPrefs();
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
