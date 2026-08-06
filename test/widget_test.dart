import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:metallcalc/main.dart';
import 'package:metallcalc/services/prefs.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await initPrefs();
  });

  testWidgets('App renders calculator screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MetallCalcApp());
    await tester.pumpAndSettle();

    // Verify the main section headers are present
    expect(find.text('ФОРМА ПРОКАТА'), findsOneWidget);
    expect(find.text('РАЗМЕРЫ'), findsAny);
    expect(find.text('МАТЕРИАЛ И МАРКА'), findsAny);
  });

  testWidgets('Short landscape viewport does not overflow',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MetallCalcApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('ФОРМА ПРОКАТА'), findsOneWidget);
  });
}
