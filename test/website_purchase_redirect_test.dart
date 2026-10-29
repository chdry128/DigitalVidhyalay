// ignore_for_file: depend_on_referenced_packages
import 'package:digital_vidyalaya/utils/launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class MockUrlLauncherPlatform extends UrlLauncherPlatform {
  String? lastLaunchedUrl;
  PreferredLaunchMode? lastLaunchMode;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    lastLaunchedUrl = url;
    lastLaunchMode = options.mode;
    return true;
  }

  @override
  Future<bool> canLaunch(String url) async => true;
}

void main() {
  late MockUrlLauncherPlatform mockLauncher;

  setUp(() {
    mockLauncher = MockUrlLauncherPlatform();
    UrlLauncherPlatform.instance = mockLauncher;
  });

  group('Website Purchase Redirect Dialog', () {
    testWidgets('shows message and buttons, Cancel leaves user in app', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showWebsitePurchaseDialog(context),
                  child: const Text('Enroll'),
                ),
              ),
            ),
          ),
        ),
      );

      // Verify initial state
      expect(find.text('Enroll'), findsOneWidget);
      expect(find.text('Please purchase this course on our website, then return to the app.'), findsNothing);

      // Tap Enroll to open dialog
      await tester.tap(find.text('Enroll'));
      await tester.pumpAndSettle();

      // Verify dialog message and buttons
      expect(find.text('Please purchase this course on our website, then return to the app.'), findsOneWidget);
      expect(find.text('Open Website'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify dialog closed and user is still on screen
      expect(find.text('Please purchase this course on our website, then return to the app.'), findsNothing);
      expect(find.text('Enroll'), findsOneWidget);
      expect(mockLauncher.lastLaunchedUrl, isNull);
    });

    testWidgets('Open Website launches https://www.digitalvidyalaya.co.in/ in external application', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showWebsitePurchaseDialog(context),
                  child: const Text('Enroll'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Enroll'));
      await tester.pumpAndSettle();

      // Tap Open Website
      await tester.tap(find.text('Open Website'));
      await tester.pumpAndSettle();

      // Verify dialog closed
      expect(find.text('Please purchase this course on our website, then return to the app.'), findsNothing);

      // Verify URL launched
      expect(mockLauncher.lastLaunchedUrl, 'https://www.digitalvidyalaya.co.in/');
      expect(mockLauncher.lastLaunchMode, PreferredLaunchMode.externalApplication);
    });
  });
}
