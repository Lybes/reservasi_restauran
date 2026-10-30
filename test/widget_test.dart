import 'package:flutter_test/flutter_test.dart';
import 'package:reservasi_restaurant/main.dart';

void main() {
  testWidgets('Layar login tampil', (tester) async {
    await tester.pumpWidget(const ReservasiApp());
    await tester.pumpAndSettle();
    expect(find.text('tabebuya'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });
}
