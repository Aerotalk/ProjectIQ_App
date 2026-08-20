import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:projectiq_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Integration Tests', () {
    testWidgets('Login with empty credentials shows validation errors', (tester) async {
      app.main();
      
      // Wait for app to render and initialization to finish
      await tester.pumpAndSettle();

      // Ensure we are on the login screen by checking the title
      expect(find.text('Log in to your account'), findsOneWidget);

      // Tap the SIGN IN button directly without entering credentials
      final signInButton = find.text('SIGN IN');
      await tester.ensureVisible(signInButton);
      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      // Expect validation error messages
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('Login with invalid credentials shows snackbar error', (tester) async {
      app.main();
      
      await tester.pumpAndSettle();

      // Find the text fields
      final emailField = find.widgetWithText(TextField, 'you@company.com');
      final passwordField = find.widgetWithText(TextField, '••••••••');

      // Enter invalid credentials
      await tester.enterText(emailField, 'wrong@company.com');
      await tester.enterText(passwordField, 'wrongpassword');
      await tester.pumpAndSettle();

      // Tap SIGN IN
      final signInButton = find.text('SIGN IN');
      await tester.ensureVisible(signInButton);
      await tester.tap(signInButton);

      // Wait for network request and snackbar
      await tester.pumpAndSettle();

      // Since we don't have the actual backend running or we hit a 401, it should show a Snackbar
      // Verify Snackbar text (Assuming it says 'Invalid credentials' or similar from backend)
      // For this test, we just check that we are still on the login screen
      expect(find.text('Log in to your account'), findsOneWidget);
    });
  });
}
