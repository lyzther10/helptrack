import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:helptrack/main.dart';
import 'package:helptrack/providers/ticket_provider.dart';
import 'package:helptrack/screens/login_screen.dart';

void main() {
  testWidgets('HelpTrack app launches and shows Login screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const HelpTrackApp());
    await tester.pumpAndSettle();

    expect(find.text('HelpTrack'), findsOneWidget);
    expect(find.text('IT Support Ticketing System'), findsOneWidget);
    expect(find.text('Login as Admin'), findsOneWidget);
  });

  testWidgets('Login with wrong credentials shows error SnackBar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => TicketProvider(),
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), 'wrong@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'wrongpass');

    await tester.tap(find.text('Login as Admin'));

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('Invalid email or password'), findsOneWidget);
  });
}
