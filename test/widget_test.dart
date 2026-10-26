import 'package:flutter_test/flutter_test.dart';
import 'package:konnecter_customer/main.dart';

void main() {
  testWidgets('Konnecter Real app starts', (tester) async {
    await tester.pumpWidget(const KonnecterApp());

    // App should render without crashing.
    expect(find.byType(KonnecterApp), findsOneWidget);
  });
}
