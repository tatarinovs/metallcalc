import 'package:flutter_test/flutter_test.dart';

import 'package:metallcalc/main.dart';

void main() {
  testWidgets('App renders calculator screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MetallCalcApp());
    await tester.pumpAndSettle();

    // Verify the main section headers are present
    expect(find.text('ФОРМА ПРОКАТА'), findsOneWidget);
    expect(find.text('РАЗМЕРЫ'), findsAny);
    expect(find.text('МАТЕРИАЛ И МАРКА'), findsAny);
  });
}
