import 'package:flutter_test/flutter_test.dart';

import 'package:kalkulator_pivot/app.dart';

void main() {
  testWidgets('app shows the gold calculator entry from the home shell', (tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('Kalkulator Emas\nFisik'), findsOneWidget);
  });
}
