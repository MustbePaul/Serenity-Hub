import 'package:flutter_test/flutter_test.dart';

import 'package:serenity_hub/main.dart';

void main() {
  testWidgets('shows Serenity Hub welcome actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SerenityHubApp());

    expect(find.text('Serenity Hub'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });
}
