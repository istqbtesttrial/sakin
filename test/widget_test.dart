import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_test/hive_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sakin_app/data/hive_database.dart';
import 'package:sakin_app/services/location_service.dart';
import 'package:sakin_app/data/repositories/misbaha_repository.dart';
import 'package:sakin_app/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Mock SharedPreferences (évite LateInitializationError / prefs non init)
    SharedPreferences.setMockInitialValues({});

    // Init Hive dans un dossier temporaire (évite HiveError "provide a path")
    await setUpTestHive();
  });

  tearDownAll(() async {
    await tearDownTestHive();
  });

  testWidgets('SakinApp smoke test', (WidgetTester tester) async {
    // Create mock services for testing
    final hiveDb = HiveDatabase();
    final locationService = LocationService();

    // Build our app and trigger a frame
    await tester.pumpWidget(SakinApp(
      hiveDb: hiveDb,
      locationService: locationService,
      misbahaRepository: MisbahaRepository(),
    ));

    // Let async initState / providers settle if any
    await tester.pumpAndSettle();

    // Verify the app builds without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
