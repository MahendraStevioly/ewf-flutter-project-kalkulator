import 'package:flutter_test/flutter_test.dart';

import 'package:kalkulator_pivot/app.dart';

void main() {
  testWidgets('app builds with the EWF utility shell', (tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('EWF Staff Utility'), findsAtLeastNWidgets(1));
  });
}
