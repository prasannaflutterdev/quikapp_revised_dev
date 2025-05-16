import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';



import 'package:quikapp/module/home/home_screen.dart'; // Add this import

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Dummy test data
    const testWebUrl = "https://example.com";
    const testIsBottomMenu = true;
    const testIsSplashEnabled = false;
    const testSplashUrl = "";
    const testSplashBgUrl = "";
    const testSplashDuration = 3;
    const testSplashAnimation = "zoom";
    const testSplashTaglineColor = Colors.black;
    const testSplashBgColor = Colors.white;
    const testBottomMenuBgColor = Colors.white;
    const testBottomMenuActiveTabColor = Colors.blue;
    const testBottomMenuTextColor = Colors.black;
    const testBottomMenuIconColor = Colors.black;
    const testBottomMenuIconPosition = "above";
    const testIsDeepLink = true;
    const testIsLoadIndicator = true;


    // Build the widget
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    // Assuming your app has a '+' icon and counter logic for testing
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
