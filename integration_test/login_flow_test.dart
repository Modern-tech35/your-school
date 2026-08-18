import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:yourschool/main.dart' as app;

/// Polls until [finder] matches, pumping the tree along the way.
/// Avoids pumpAndSettle because the app has endless spinners
/// (CircularProgressIndicator) during splash/loading states.
Future<void> waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 45),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await tester.pump();
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  fail('Timed out waiting for $finder');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('full login flow: splash -> sign up -> student home',
      (WidgetTester tester) async {
    final email = 'itest.${DateTime.now().millisecondsSinceEpoch}@example.com';
    const password = 'Test1234!';

    // Boot the real app (initializes Firebase, starts at /splash).
    app.main();
    await tester.pump();

    // 1. Splash screen appears, then auto-navigates to /auth after ~3s.
    await waitFor(tester, find.text('Sign In'));

    // 2. Switch to the Sign Up tab.
    await tester.tap(find.text('Sign Up'));
    await waitFor(
      tester,
      find.byType(TextField).at(2),
      timeout: const Duration(seconds: 10),
    );

    // 3. Fill the sign-up form (email, password, confirm password).
    await tester.enterText(find.byType(TextField).at(0), email);
    await tester.enterText(find.byType(TextField).at(1), password);
    await tester.enterText(find.byType(TextField).at(2), password);

    // 4. Submit sign-up. This creates a Firebase Auth user, writes a
    //    student profile to Firestore, then role-check redirects to
    //    the student home screen.
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));

    // 5. The student home AppBar is titled "Lessons".
    await waitFor(tester, find.text('Lessons'));

    // 6. Sanity check: we are on the student home screen.
    expect(find.byType(Scaffold), findsWidgets);
  });
}
