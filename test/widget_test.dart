import 'package:NoteNest/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App starts and shows Login Page or Dashboard', (WidgetTester tester) async {
    // Build the app with rememberMe: false
    await tester.pumpWidget(const NoteNestApp(rememberMe: false));

    // Check if LoginPage content is shown
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('NoteNest'), findsOneWidget);
  });
}
