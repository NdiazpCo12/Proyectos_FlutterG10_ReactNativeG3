import 'package:flutter_test/flutter_test.dart';

import 'package:login/app/app.dart';

void main() {
  testWidgets('renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const PeerAssessmentApp());

    expect(find.text('Peer Assessment'), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
