import 'package:flutter_test/flutter_test.dart';

import 'package:serenity_hub/main.dart';

void main() {
  testWidgets('shows Serenity Hub welcome actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SerenityHubApp());

    expect(find.text('WELCOME TO SERENITY HUB'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('SIGNUP'), findsOneWidget);
  });
}
