import 'package:flutter_test/flutter_test.dart';

import 'package:baibanhang/main.dart';

void main() {
  testWidgets('Home screen renders product list', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Danh sach san pham'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Tai nghe Bluetooth'), findsOneWidget);
    expect(find.text('Man hinh 27 inch'), findsOneWidget);
  });
}
