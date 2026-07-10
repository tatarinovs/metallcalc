import 'package:shared_preferences/shared_preferences.dart';

/// Глобальный инстанс настроек для синхронного доступа во всем приложении
late final SharedPreferences prefs;

/// Инициализация (вызывать один раз в main перед runApp)
Future<void> initPrefs() async {
  prefs = await SharedPreferences.getInstance();
}
