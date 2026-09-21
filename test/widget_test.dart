import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartq_estates/app/app.dart';
import 'package:smartq_estates/core/constants/app_strings.dart';
import 'package:smartq_estates/core/models/estate.dart';
import 'package:smartq_estates/core/models/pass_type.dart';
import 'package:smartq_estates/core/services/estate_service.dart';
import 'package:smartq_estates/core/services/qr_code_service.dart';
import 'package:smartq_estates/screens/estate_selection/estate_selection_screen.dart';
import 'package:smartq_estates/screens/home/home_screen.dart';
import 'package:smartq_estates/screens/main_shell/main_shell_screen.dart';
import 'package:smartq_estates/screens/maintenance/maintenance_placeholder_screen.dart';
import 'package:smartq_estates/screens/payments/payments_placeholder_screen.dart';
import 'package:smartq_estates/screens/services/services_placeholder_screen.dart';
import 'package:smartq_estates/screens/splash/splash_screen.dart';
import 'package:smartq_estates/core/models/estate_event.dart';
import 'package:smartq_estates/core/models/event_pass.dart';
import 'package:smartq_estates/core/models/visitor_invitation.dart';
import 'package:smartq_estates/core/models/visitor_pass.dart';
import 'package:smartq_estates/screens/visitors/create_event_screen.dart';
import 'package:smartq_estates/screens/visitors/event_pass_screen.dart';
import 'package:smartq_estates/screens/visitors/invite_someone_screen.dart';
import 'package:smartq_estates/screens/visitors/visitor_pass_screen.dart';
import 'package:smartq_estates/screens/security/security_account_screen.dart';
import 'package:smartq_estates/screens/security/security_home_screen.dart';
import 'package:smartq_estates/screens/security/security_shell_screen.dart';
import 'package:smartq_estates/screens/security/verify_access_scanner_screen.dart';
import 'package:smartq_estates/screens/security/decoded_result_screen.dart';
import 'package:smartq_estates/core/models/decoded_qr_payload.dart';
import 'package:smartq_estates/screens/visitors/visitors_home_screen.dart';
import 'package:smartq_estates/screens/welcome/welcome_screen.dart';
import 'package:smartq_estates/navigation/app_router.dart';
import 'package:smartq_estates/widgets/app_button.dart';
import 'package:smartq_estates/widgets/app_header.dart';
import 'package:smartq_estates/widgets/app_text_field.dart';
// Phase 5C imports
import 'package:smartq_estates/core/models/pass_verification_result.dart';
import 'package:smartq_estates/core/repositories/pass_registry.dart';
import 'package:smartq_estates/core/services/pass_verification_service.dart';
import 'package:smartq_estates/screens/security/access_result_screen.dart';
// Phase 5D imports
import 'package:smartq_estates/core/models/access_record.dart';
import 'package:smartq_estates/core/repositories/access_log_repository.dart';

void main() {
  group('SmartQ Estates - Phase 1 Foundation Tests', () {
    testWidgets('SplashScreen renders and navigates to WelcomeScreen after delay',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SplashScreen(delay: Duration(milliseconds: 50)),
          routes: {
            '/welcome': (_) => const WelcomeScreen(),
          },
        ),
      );

      expect(find.text(AppStrings.appName), findsOneWidget);
      expect(find.text(AppStrings.tagline), findsOneWidget);

      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(find.text(AppStrings.welcomeTitle), findsOneWidget);
      expect(find.text(AppStrings.getStarted), findsOneWidget);
    });

    testWidgets('WelcomeScreen renders key copy and GET STARTED button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );

      expect(find.text(AppStrings.welcomeTitle), findsOneWidget);
      expect(find.text(AppStrings.tagline), findsOneWidget);
      expect(find.text(AppStrings.welcomeDescription), findsOneWidget);
      expect(find.widgetWithText(AppButton, AppStrings.getStarted), findsOneWidget);
    });

    testWidgets('EstateSelectionScreen filters estates and toggles selection',
        (WidgetTester tester) async {
      final estateService = EstateService();
      await tester.pumpWidget(
        MaterialApp(
          home: EstateSelectionScreen(estateService: estateService),
        ),
      );

      // Verify header and initial list
      expect(find.text(AppStrings.selectYourEstate), findsOneWidget);
      expect(find.text('Pinecrest Royal Estate'), findsOneWidget);
      expect(find.text('Victoria Garden Sanctuary'), findsOneWidget);

      // Search filtering
      await tester.enterText(find.byType(TextField), 'Victoria');
      await tester.pumpAndSettle();

      expect(find.text('Victoria Garden Sanctuary'), findsOneWidget);
      expect(find.text('Pinecrest Royal Estate'), findsNothing);

      // Select estate
      await tester.tap(find.text('Victoria Garden Sanctuary'));
      await tester.pumpAndSettle();

      // Verify continue button is enabled
      final continueButton = tester.widget<AppButton>(
        find.widgetWithText(AppButton, AppStrings.continueText),
      );
      expect(continueButton.onPressed, isNotNull);
    });

    testWidgets('MainShellScreen bottom navigation switches between Home, Activity, and Account',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainShellScreen(),
        ),
      );

      // Initial tab: Home
      expect(find.text('GOOD MORNING, JOSHUA'), findsOneWidget);
      expect(find.text(AppStrings.primaryQuestion), findsOneWidget);

      // Switch to Activity tab
      await tester.tap(find.text(AppStrings.tabActivity));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.noActivityYet), findsOneWidget);
      expect(find.text(AppStrings.activityEmptySubtitle), findsOneWidget);

      // Switch to Account tab
      await tester.tap(find.text(AppStrings.tabAccount));
      await tester.pumpAndSettle();

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Unit 4B • Primary Resident'), findsOneWidget);
      expect(find.text('ASSIGNED COMMUNITY'), findsOneWidget);
    });

    test('QrCodeService architectural contract generates and decodes tokens', () {
      final qrService = MockQrCodeService();
      final validFrom = DateTime.now();
      final validUntil = validFrom.add(const Duration(hours: 4));

      final token = qrService.generatePassToken(
        estateId: 'est_001',
        residentId: 'res_99',
        passType: PassType.visitor,
        validFrom: validFrom,
        validUntil: validUntil,
      );

      expect(token, startsWith('SMARTQ:est_001:visitor:res_99:'));
      expect(qrService.verifyPassToken(token), isTrue);

      final payload = qrService.decodePassToken(token);
      expect(payload, isNotNull);
      expect(payload!['estateId'], equals('est_001'));
      expect(payload['passType'], equals('visitor'));
      expect(payload['residentId'], equals('res_99'));
    });

    testWidgets('Complete app root builds without error', (WidgetTester tester) async {
      await tester.pumpWidget(const SmartQApp());
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('SmartQ Estates - Phase 2 Resident Home Screen Tests', () {
    const testEstate = Estate(
      id: 'est_001',
      name: 'Pinecrest Royal Estate',
      location: 'Maitama District',
      code: 'PRE-01',
      unitsCount: 140,
    );

    testWidgets('HomeScreen renders greeting, estate name, and primary question',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(
            selectedEstate: testEstate,
            residentName: 'JOSHUA',
          ),
        ),
      );

      expect(find.text('GOOD MORNING, JOSHUA'), findsOneWidget);
      expect(find.text('Pinecrest Royal Estate'), findsOneWidget);
      expect(find.text('PRE-01'), findsOneWidget);
      expect(find.text(AppStrings.primaryQuestion), findsOneWidget);

      // Verify 4 actions are present
      expect(find.text(AppStrings.actionVisitors), findsOneWidget);
      expect(find.text(AppStrings.actionServices), findsOneWidget);
      expect(find.text(AppStrings.actionMaintenance), findsOneWidget);
      expect(find.text(AppStrings.actionPayments), findsOneWidget);

      // Verify UPCOMING & RECENT ACTIVITY empty states
      expect(find.text(AppStrings.sectionUpcoming), findsOneWidget);
      expect(find.text(AppStrings.noUpcomingItems), findsOneWidget);
      expect(find.text(AppStrings.sectionRecentActivity), findsOneWidget);
      expect(find.text(AppStrings.noRecentActivity), findsOneWidget);
    });

    testWidgets('Tapping VISITORS from Home opens VisitorsHomeScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/': (_) => const HomeScreen(selectedEstate: testEstate),
            '/visitors': (_) => const VisitorsHomeScreen(),
          },
        ),
      );

      await tester.tap(find.text(AppStrings.actionVisitors));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.visitorsTitle), findsOneWidget);
      expect(find.text(AppStrings.visitorsSubtitle), findsOneWidget);
      expect(find.byType(VisitorsHomeScreen), findsOneWidget);
    });

    testWidgets('Tapping SERVICES navigates to ServicesPlaceholderScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/': (_) => const HomeScreen(selectedEstate: testEstate),
            '/services': (_) => const ServicesPlaceholderScreen(),
          },
        ),
      );

      await tester.tap(find.text(AppStrings.actionServices));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.servicesComingSoon), findsOneWidget);
      expect(find.byType(ServicesPlaceholderScreen), findsOneWidget);
    });

    testWidgets('Tapping MAINTENANCE navigates to MaintenancePlaceholderScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/': (_) => const HomeScreen(selectedEstate: testEstate),
            '/maintenance': (_) => const MaintenancePlaceholderScreen(),
          },
        ),
      );

      await tester.tap(find.text(AppStrings.actionMaintenance));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.maintenanceComingSoon), findsOneWidget);
      expect(find.byType(MaintenancePlaceholderScreen), findsOneWidget);
    });

    testWidgets('Tapping PAYMENTS navigates to PaymentsPlaceholderScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/': (_) => const HomeScreen(selectedEstate: testEstate),
            '/payments': (_) => const PaymentsPlaceholderScreen(),
          },
        ),
      );

      await tester.tap(find.text(AppStrings.actionPayments));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.paymentsComingSoon), findsOneWidget);
      expect(find.byType(PaymentsPlaceholderScreen), findsOneWidget);
    });
  });

  group('SmartQ Estates - Phase 3A Visitors Home Screen Tests', () {
    testWidgets('VisitorsHomeScreen renders header, actions, and empty states',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: VisitorsHomeScreen(),
        ),
      );

      // Header
      expect(find.text(AppStrings.visitorsTitle), findsOneWidget);
      expect(find.text(AppStrings.visitorsSubtitle), findsOneWidget);

      // Primary Actions
      expect(find.text(AppStrings.actionInviteSomeone), findsOneWidget);
      expect(find.text(AppStrings.inviteSomeoneSubtitle), findsOneWidget);
      expect(find.text(AppStrings.actionCreateEvent), findsOneWidget);
      expect(find.text(AppStrings.createEventSubtitle), findsOneWidget);

      // Empty States
      expect(find.text(AppStrings.sectionUpcoming), findsOneWidget);
      expect(find.text(AppStrings.noUpcomingVisitors), findsOneWidget);
      expect(find.text(AppStrings.upcomingVisitorsSubtitle), findsOneWidget);

      expect(find.text(AppStrings.sectionRecent), findsOneWidget);
      expect(find.text(AppStrings.noRecentVisits), findsOneWidget);
      expect(find.text(AppStrings.recentVisitsSubtitle), findsOneWidget);
    });

    testWidgets('Tapping CREATE EVENT navigates to CreateEventScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/': (_) => const VisitorsHomeScreen(),
            '/visitors/create-event': (_) => const CreateEventScreen(),
          },
        ),
      );

      await tester.tap(find.text(AppStrings.actionCreateEvent));
      await tester.pumpAndSettle();

      expect(find.byType(CreateEventScreen), findsOneWidget);
    });

    testWidgets('VisitorsHomeScreen back button returns to caller',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const VisitorsHomeScreen()),
                ),
                child: const Text('OPEN VISITORS'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('OPEN VISITORS'));
      await tester.pumpAndSettle();
      expect(find.byType(VisitorsHomeScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byType(VisitorsHomeScreen), findsNothing);
      expect(find.text('OPEN VISITORS'), findsOneWidget);
    });
  });

  group('SmartQ Estates - Phase 3B Invite Someone Tests', () {
    testWidgets('InviteSomeoneScreen renders all sections and fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: InviteSomeoneScreen(),
        ),
      );

      // Header
      expect(find.text(AppStrings.inviteSomeoneHeader), findsOneWidget);
      expect(find.text(AppStrings.inviteSomeoneHeaderSubtitle), findsOneWidget);

      // Section 1: Who is coming?
      expect(find.text(AppStrings.sectionWhoIsComing), findsOneWidget);
      expect(find.text(AppStrings.labelFullName), findsOneWidget);
      expect(find.text(AppStrings.labelPhoneNumber), findsOneWidget);

      // Section 2: When are they coming?
      expect(find.text(AppStrings.sectionWhenComing), findsOneWidget);
      expect(find.text(AppStrings.labelDate), findsOneWidget);
      expect(find.text(AppStrings.labelArrivalTime), findsOneWidget);

      // Section 3: Vehicle (Optional)
      expect(find.text(AppStrings.sectionVehicle), findsOneWidget);
      expect(find.text(AppStrings.optionalBadge), findsOneWidget);
      expect(find.text(AppStrings.labelPlateNumber), findsOneWidget);
      expect(find.text(AppStrings.labelVehicleDescription), findsOneWidget);

      // Bottom Action
      expect(find.text(AppStrings.createPassAction), findsOneWidget);
    });

    testWidgets('Validates required fields when submitted empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: InviteSomeoneScreen(),
        ),
      );

      // Tap Create Pass with empty fields
      await tester.tap(find.text(AppStrings.createPassAction));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.errorFullNameRequired), findsOneWidget);
      expect(find.text(AppStrings.errorPhoneRequired), findsOneWidget);
    });

    testWidgets('Validates invalid phone number', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: InviteSomeoneScreen(),
        ),
      );

      final textFields = find.byType(AppTextField);
      await tester.enterText(textFields.at(0), 'Michael Scott');
      await tester.enterText(textFields.at(1), '123'); // Too short

      await tester.tap(find.text(AppStrings.createPassAction));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.errorFullNameRequired), findsNothing);
      expect(find.text(AppStrings.errorPhoneInvalid), findsOneWidget);
    });

    testWidgets('Successful form submission creates invitation and opens VisitorPassScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/visitors/invite',
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      final textFields = find.byType(AppTextField);
      await tester.enterText(textFields.at(0), 'Amaka Obi');
      await tester.enterText(textFields.at(1), '08031234567');
      await tester.enterText(textFields.at(2), 'ABJ-882-XY'); // Vehicle plate
      await tester.enterText(textFields.at(3), 'Silver Honda Accord'); // Vehicle desc

      await tester.tap(find.text(AppStrings.createPassAction));
      await tester.pumpAndSettle();

      // Should have navigated to VisitorPassScreen
      expect(find.byType(VisitorPassScreen), findsOneWidget);
      expect(find.text(AppStrings.visitorPassHeader), findsOneWidget);
      expect(find.text(AppStrings.visitorPassExpected), findsOneWidget);
      expect(find.text('Amaka Obi'), findsOneWidget);
      expect(find.text('ABJ-882-XY • Silver Honda Accord'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.text(AppStrings.showCodeAtEntrance), findsOneWidget);
      expect(find.text(AppStrings.sharePassAction), findsOneWidget);
      expect(find.text(AppStrings.cancelPassAction), findsOneWidget);
    });

    testWidgets('Tapping INVITE SOMEONE from VisitorsHomeScreen opens InviteSomeoneScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/visitors',
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      await tester.tap(find.text(AppStrings.actionInviteSomeone));
      await tester.pumpAndSettle();

      expect(find.byType(InviteSomeoneScreen), findsOneWidget);
    });
  });

  group('SmartQ Estates - Phase 3C Visitor Pass + QR Code Tests', () {
    final invitationWithVehicle = VisitorInvitation(
      id: 'inv_101',
      visitorName: 'David Adeleke',
      phoneNumber: '08022223344',
      visitDate: DateTime(2026, 9, 25),
      arrivalTime: const TimeOfDay(hour: 14, minute: 30),
      vehiclePlate: 'KJA-123-AA',
      vehicleDescription: 'Black Mercedes G63',
      createdAt: DateTime(2026, 9, 20),
    );

    final invitationWithoutVehicle = VisitorInvitation(
      id: 'inv_102',
      visitorName: 'Grace Hopper',
      phoneNumber: '08133334455',
      visitDate: DateTime(2026, 9, 26),
      arrivalTime: const TimeOfDay(hour: 10, minute: 0),
      createdAt: DateTime(2026, 9, 20),
    );

    test('VisitorPass model & token generation verification', () {
      final qrService = MockQrCodeService();
      final pass = qrService.createVisitorPass(invitation: invitationWithVehicle);

      // Short pass ID format: BT-XXXXX
      expect(pass.passId, startsWith('BT-'));
      expect(pass.passId.length, equals(8));

      // Verification token is unpredictable and distinct from pass ID
      expect(pass.verificationToken, startsWith('VT-'));
      expect(pass.verificationToken, isNot(equals(pass.passId)));

      // Expiration: scheduled arrival + 6 hours
      final expectedExpiry = DateTime(2026, 9, 25, 20, 30);
      expect(pass.expiresAt, equals(expectedExpiry));
      expect(pass.status, equals(PassStatus.active));
      expect(pass.isActive, isTrue);

      // QR payload contains structured metadata without personal phone or sensitive resident info
      final qrPayload = pass.toQrPayload();
      expect(qrPayload, contains(pass.passId));
      expect(qrPayload, contains('visitor'));
      expect(qrPayload, contains(pass.verificationToken));
      expect(qrPayload, isNot(contains('08022223344'))); // Phone not in QR payload
      expect(qrPayload, isNot(contains('password')));

      // Share text contains visitor details and pass ID
      final shareText = pass.toShareText(estateName: 'Pinecrest Royal Estate');
      expect(shareText, contains('David Adeleke'));
      expect(shareText, contains('KJA-123-AA'));
      expect(shareText, contains(pass.passId));
    });

    testWidgets('VisitorPassScreen renders details, scannable QR, and hides empty vehicle section',
        (WidgetTester tester) async {
      final qrService = MockQrCodeService();
      final passNoVehicle = qrService.createVisitorPass(invitation: invitationWithoutVehicle);

      await tester.pumpWidget(
        MaterialApp(
          home: VisitorPassScreen(pass: passNoVehicle),
        ),
      );

      // Verify header and visitor details
      expect(find.text(AppStrings.visitorPassHeader), findsOneWidget);
      expect(find.text(AppStrings.visitorPassExpected), findsOneWidget);
      expect(find.text('Grace Hopper'), findsOneWidget);
      expect(find.text(passNoVehicle.passId), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);

      // Vehicle section must NOT be rendered when no vehicle exists
      expect(find.text(AppStrings.sectionVehicle), findsNothing);

      // QR code guidance
      expect(find.text(AppStrings.showCodeAtEntrance), findsOneWidget);
      expect(find.textContaining('EXPIRES:'), findsOneWidget);

      // Actions
      expect(find.text(AppStrings.sharePassAction), findsOneWidget);
      expect(find.text(AppStrings.cancelPassAction), findsOneWidget);
    });

    testWidgets('Cancel pass shows dialog, updates badge to CANCELLED and invalidates pass',
        (WidgetTester tester) async {
      final qrService = MockQrCodeService();
      final pass = qrService.createVisitorPass(invitation: invitationWithVehicle);

      await tester.pumpWidget(
        MaterialApp(
          home: VisitorPassScreen(pass: pass),
        ),
      );

      expect(find.text('ACTIVE'), findsOneWidget);

      // Scroll and tap Cancel Pass
      final cancelFinder = find.text(AppStrings.cancelPassAction);
      await tester.ensureVisible(cancelFinder);
      await tester.tap(cancelFinder);
      await tester.pumpAndSettle();

      // Verify dialog
      expect(find.text(AppStrings.cancelPassDialogTitle), findsOneWidget);
      expect(find.text(AppStrings.cancelPassDialogContent), findsOneWidget);
      expect(find.text(AppStrings.keepPassAction), findsOneWidget);

      final confirmButtonFinder = find.widgetWithText(TextButton, AppStrings.confirmCancelAction);
      expect(confirmButtonFinder, findsOneWidget);

      // Confirm cancellation
      await tester.tap(confirmButtonFinder);
      await tester.pumpAndSettle();

      // Pass should now show CANCELLED
      expect(find.text('CANCELLED'), findsOneWidget);
      expect(find.text('PASS CANCELLED'), findsOneWidget);
      expect(find.text(AppStrings.cancelPassAction), findsNothing);
    });
  });

  group('SmartQ Estates - Phase 4A Create Event Tests', () {
    test('EstateEvent model creation and default status', () {
      final event = EstateEvent(
        id: 'evt_01',
        name: 'Housewarming Party',
        eventDate: DateTime(2026, 10, 15),
        startTime: const TimeOfDay(hour: 16, minute: 0),
        endTime: const TimeOfDay(hour: 21, minute: 0),
        expectedGuests: 45,
        createdAt: DateTime(2026, 9, 20),
      );

      expect(event.id, equals('evt_01'));
      expect(event.name, equals('Housewarming Party'));
      expect(event.expectedGuests, equals(45));
      expect(event.status, equals(EventStatus.upcoming));
      expect(event.status.displayName, equals('UPCOMING'));
    });

    testWidgets('CreateEventScreen renders all sections and fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreateEventScreen(),
        ),
      );

      // Header & Button (both use CREATE EVENT text)
      expect(find.widgetWithText(AppHeader, AppStrings.createEventHeader), findsOneWidget);
      expect(find.text(AppStrings.createEventHeaderSubtitle), findsOneWidget);

      // Section 1: What are you hosting?
      expect(find.text(AppStrings.sectionWhatHosting), findsOneWidget);
      expect(find.text(AppStrings.labelEventName), findsOneWidget);
      expect(find.text(AppStrings.placeholderEventName), findsOneWidget);

      // Section 2: When is it?
      expect(find.text(AppStrings.sectionWhenIsIt), findsOneWidget);
      expect(find.text(AppStrings.labelDate), findsOneWidget);
      expect(find.text(AppStrings.labelStartTime), findsOneWidget);
      expect(find.text(AppStrings.labelEndTime), findsOneWidget);

      // Section 3: How many guests?
      expect(find.text(AppStrings.sectionHowManyGuests), findsOneWidget);
      expect(find.text(AppStrings.labelExpectedGuests), findsOneWidget);
      expect(find.text(AppStrings.placeholderExpectedGuests), findsOneWidget);

      // Bottom action
      expect(find.widgetWithText(AppButton, AppStrings.createEventAction), findsOneWidget);
    });

    testWidgets('Validates required event name and guests', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreateEventScreen(),
        ),
      );

      // Tap Create Event with empty fields
      await tester.tap(find.widgetWithText(AppButton, AppStrings.createEventAction));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.errorEventNameRequired), findsOneWidget);
      expect(find.text(AppStrings.errorGuestsInvalid), findsOneWidget);
    });

    testWidgets('Validates invalid guest limits (0, negative, or > 500)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreateEventScreen(),
        ),
      );

      final textFields = find.byType(AppTextField);
      await tester.enterText(textFields.at(0), "Kemi's Graduation Dinner");
      await tester.enterText(textFields.at(1), '0'); // Invalid (less than 1)

      await tester.tap(find.widgetWithText(AppButton, AppStrings.createEventAction));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.errorGuestsInvalid), findsOneWidget);

      // Test > 500
      await tester.enterText(textFields.at(1), '600');
      await tester.tap(find.widgetWithText(AppButton, AppStrings.createEventAction));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.errorGuestsInvalid), findsOneWidget);
    });

    testWidgets('Successful form submission creates event and opens EventPassScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/visitors/create-event',
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      final textFields = find.byType(AppTextField);
      await tester.enterText(textFields.at(0), "Kunle's 40th Birthday");
      await tester.enterText(textFields.at(1), '85');

      await tester.tap(find.widgetWithText(AppButton, AppStrings.createEventAction));
      await tester.pumpAndSettle();

      // Verified navigation to EventPassScreen
      expect(find.byType(EventPassScreen), findsOneWidget);
      expect(find.text(AppStrings.eventPassTitle), findsOneWidget);
      expect(find.text("Kunle's 40th Birthday"), findsOneWidget);
      expect(find.text('85 EXPECTED GUESTS'), findsOneWidget);
      expect(find.text(AppStrings.labelEventCode), findsOneWidget);
      expect(find.text(AppStrings.eventCodeExplanation), findsOneWidget);
      expect(find.text(AppStrings.qrInstructionEvent), findsOneWidget);
      expect(find.widgetWithText(AppButton, AppStrings.shareEventAction), findsOneWidget);
      expect(find.text(AppStrings.cancelEventAction), findsOneWidget);
    });

    testWidgets('Tapping CREATE EVENT from VisitorsHomeScreen opens CreateEventScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/visitors',
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      await tester.tap(find.text(AppStrings.actionCreateEvent));
      await tester.pumpAndSettle();

      expect(find.byType(CreateEventScreen), findsOneWidget);
    });
  });

  group('SmartQ Estates - Phase 4B Event Pass Tests', () {
    final testEvent = EstateEvent(
      id: 'evt_test_001',
      name: "Chinedu's Housewarming",
      eventDate: DateTime(2026, 10, 15),
      startTime: const TimeOfDay(hour: 16, minute: 0),
      endTime: const TimeOfDay(hour: 22, minute: 0),
      expectedGuests: 45,
      createdAt: DateTime(2026, 10, 1),
      status: EventStatus.upcoming,
    );

    test('EventPass model creation, event code generation, and expiration rules', () {
      final service = MockQrCodeService();
      final EventPass pass = service.createEventPass(event: testEvent);

      // Verify human-readable event code format EV-XXXXX
      expect(pass.eventCode.startsWith('EV-'), isTrue);
      expect(pass.eventCode.length, 8); // EV- + 5 chars

      // Verify pass ID
      expect(pass.passId.startsWith('EP-'), isTrue);

      // Verify expiration matches event end time exactly
      final expectedExpiration = DateTime(2026, 10, 15, 22, 0);
      expect(pass.expiresAt, expectedExpiration);

      // Verify status
      expect(pass.status, PassStatus.active);
      expect(pass.status.displayName, 'ACTIVE');

      // Verify verificationToken
      expect(pass.verificationToken.startsWith('VT-'), isTrue);
    });

    test('EventPass QR payload contains token data and no private personal info', () {
      final service = MockQrCodeService();
      final pass = service.createEventPass(event: testEvent);

      final qrPayload = pass.toQrPayload();

      // Must have structured JSON attributes
      expect(qrPayload.contains('"type":"event"'), isTrue);
      expect(qrPayload.contains('"passId":"${pass.passId}"'), isTrue);
      expect(qrPayload.contains('"verificationToken":"${pass.verificationToken}"'), isTrue);
      expect(qrPayload.contains('"status":"active"'), isTrue);

      // Must NOT contain personal/private data
      expect(qrPayload.contains('phoneNumber'), isFalse);
      expect(qrPayload.contains('phone'), isFalse);
      expect(qrPayload.contains('resident'), isFalse);
    });

    test('EventPass toShareText contains clean concise guest invitation', () {
      final service = MockQrCodeService();
      final pass = service.createEventPass(event: testEvent);

      final shareText = pass.toShareText(estateName: 'Pinecrest Royal Estate');

      expect(shareText.contains("You're invited to Chinedu's Housewarming."), isTrue);
      expect(shareText.contains('4:00 PM – 10:00 PM'), isTrue);
      expect(shareText.contains('Event code: ${pass.eventCode}'), isTrue);
      expect(shareText.contains('Location: Pinecrest Royal Estate'), isTrue);
      expect(shareText.contains('Please show the event QR/code at the estate entrance.'), isTrue);
    });

    testWidgets('EventPassScreen renders details, QR, and actions', (WidgetTester tester) async {
      final service = MockQrCodeService();
      final pass = service.createEventPass(event: testEvent);

      await tester.pumpWidget(
        MaterialApp(
          home: EventPassScreen(pass: pass),
        ),
      );

      // Header
      expect(find.text(AppStrings.eventPassTitle), findsOneWidget);

      // Details
      expect(find.text("Chinedu's Housewarming"), findsOneWidget);
      expect(find.text('45 EXPECTED GUESTS'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.text('4:00 PM – 10:00 PM'), findsOneWidget);
      expect(find.text('45'), findsOneWidget);

      // Event Code
      expect(find.text(AppStrings.labelEventCode), findsOneWidget);
      expect(find.text(pass.eventCode), findsOneWidget);
      expect(find.text(AppStrings.eventCodeExplanation), findsOneWidget);

      // QR section
      expect(find.text(AppStrings.qrInstructionEvent), findsOneWidget);

      // Actions
      expect(find.widgetWithText(AppButton, AppStrings.shareEventAction), findsOneWidget);
      expect(find.text(AppStrings.cancelEventAction), findsOneWidget);
    });

    testWidgets('Cancel event dialog allows dismissing or confirming cancellation',
        (WidgetTester tester) async {
      final service = MockQrCodeService();
      final pass = service.createEventPass(event: testEvent);

      await tester.pumpWidget(
        MaterialApp(
          home: EventPassScreen(pass: pass),
        ),
      );

      // Scroll and open cancel dialog
      final cancelActionFinder = find.text(AppStrings.cancelEventAction);
      await tester.ensureVisible(cancelActionFinder);
      await tester.tap(cancelActionFinder);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.cancelEventDialogTitle), findsOneWidget);
      expect(find.text(AppStrings.cancelEventDialogContent), findsOneWidget);
      expect(find.text(AppStrings.keepEventAction), findsOneWidget);

      // Tap KEEP EVENT -> cancels dialog without modifying pass
      await tester.tap(find.text(AppStrings.keepEventAction));
      await tester.pumpAndSettle();

      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.text(AppStrings.cancelEventDialogTitle), findsNothing);

      // Re-open and confirm cancellation
      await tester.ensureVisible(cancelActionFinder);
      await tester.tap(cancelActionFinder);
      await tester.pumpAndSettle();

      // Tap CANCEL EVENT inside the dialog
      final dialogCancelButton = find.widgetWithText(TextButton, AppStrings.cancelEventAction);
      await tester.tap(dialogCancelButton);
      await tester.pumpAndSettle();

      // Verify pass status updated to CANCELLED and active action replaced with DONE
      expect(find.text('CANCELLED'), findsNWidgets(2)); // badge + overlay
      expect(find.widgetWithText(AppButton, 'DONE'), findsOneWidget);
      expect(find.text(AppStrings.shareEventAction), findsNothing);
    });
  });

  group('SmartQ Estates - Phase 5A Security Home Tests', () {
    final testEstate = const Estate(
      id: 'est_001',
      name: 'Pinecrest Royal Estate',
      location: 'Maitama District, Phase 2',
      code: 'PRE-01',
      unitsCount: 140,
    );

    testWidgets('SecurityHomeScreen renders header, dominant VERIFY ACCESS action, and empty sections',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SecurityHomeScreen(selectedEstate: testEstate),
        ),
      );

      // Header
      expect(find.text(AppStrings.securityTitle), findsOneWidget);
      expect(find.text('Pinecrest Royal Estate'), findsOneWidget);
      expect(find.text('GATE 1'), findsOneWidget);

      // Dominant primary action: VERIFY ACCESS
      expect(find.text(AppStrings.verifyAccessAction), findsOneWidget);
      expect(find.text(AppStrings.verifyAccessSubtitle), findsOneWidget);

      // Section: TODAY
      expect(find.text(AppStrings.sectionToday), findsOneWidget);
      expect(find.text(AppStrings.labelSecurityVisitors), findsOneWidget);
      expect(find.text(AppStrings.labelSecurityEvents), findsOneWidget);
      expect(find.text(AppStrings.noActivityStatus), findsNWidgets(2));

      // Verify NO fake numbers appear
      expect(find.text('0 visitors'), findsNothing);
      expect(find.text('0 events'), findsNothing);

      // Section: RECENT ACTIVITY
      expect(find.text(AppStrings.sectionRecentActivity), findsOneWidget);
      expect(find.text(AppStrings.noRecentActivity), findsOneWidget);
      expect(find.text(AppStrings.recentActivitySubtitle), findsOneWidget);
    });

    testWidgets('Tapping VERIFY ACCESS navigates to VerifyAccessScannerScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SecurityHomeScreen(
            selectedEstate: testEstate,
          ),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      // Tap VERIFY ACCESS
      await tester.tap(find.text(AppStrings.verifyAccessAction));
      await tester.pumpAndSettle();

      // Verify navigation to VerifyAccessScannerScreen
      expect(find.byType(VerifyAccessScannerScreen), findsOneWidget);
      expect(find.text(AppStrings.verifyAccessAction), findsOneWidget);
      expect(find.text(AppStrings.verifyAccessSubtitleScanner), findsOneWidget);
      expect(find.text(AppStrings.scanQrCodeGuide), findsOneWidget);

      // Tap back button in AppHeader
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byType(VerifyAccessScannerScreen), findsNothing);
      expect(find.byType(SecurityHomeScreen), findsOneWidget);
    });

    testWidgets('SecurityShellScreen bottom navigation switches between Security and Account tabs',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SecurityShellScreen(initialEstate: testEstate),
        ),
      );

      // Security Home is active by default
      expect(find.byType(SecurityHomeScreen), findsOneWidget);
      expect(find.descendant(
        of: find.byType(SecurityHomeScreen),
        matching: find.text(AppStrings.securityTitle),
      ), findsOneWidget);

      // Security bottom nav items (tab label has text 'SECURITY')
      final securityTabFinder = find.widgetWithText(InkWell, AppStrings.tabSecurity);
      final accountTabFinder = find.widgetWithText(InkWell, AppStrings.tabSecurityAccount);
      expect(securityTabFinder, findsOneWidget);
      expect(accountTabFinder, findsOneWidget);

      // Switch to Security Account tab
      await tester.tap(accountTabFinder);
      await tester.pumpAndSettle();

      expect(find.byType(SecurityAccountScreen), findsOneWidget);
      expect(find.text(AppStrings.securityAccountTitle), findsOneWidget);
      expect(find.text('Gate Security Officer'), findsOneWidget);
      expect(find.text('Pinecrest Royal Estate'), findsOneWidget);
    });

    testWidgets('Resident flow regression: Visitors, Invite Someone, and Create Event remain intact',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/visitors': (_) => const VisitorsHomeScreen(),
            '/visitors/invite': (_) => const InviteSomeoneScreen(),
            '/visitors/create-event': (_) => const CreateEventScreen(),
          },
          initialRoute: '/visitors',
        ),
      );

      // Verify visitors home
      expect(find.byType(VisitorsHomeScreen), findsOneWidget);

      // Tapping INVITE SOMEONE works
      await tester.tap(find.text(AppStrings.actionInviteSomeone));
      await tester.pumpAndSettle();
      expect(find.byType(InviteSomeoneScreen), findsOneWidget);

      // Go back to visitors home
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byType(VisitorsHomeScreen), findsOneWidget);

      // Tapping CREATE EVENT works
      await tester.tap(find.text(AppStrings.actionCreateEvent));
      await tester.pumpAndSettle();
      expect(find.byType(CreateEventScreen), findsOneWidget);
    });
  });

  group('SmartQ Estates - Phase 5B Security QR Scanner & Payload Parsing Tests', () {
    test('Visitor payload parsing extracts required fields without private data', () {
      final invitation = VisitorInvitation(
        id: 'inv_301',
        visitorName: 'Ngozi Chimamanda',
        phoneNumber: '08099887766',
        visitDate: DateTime(2026, 10, 5),
        arrivalTime: const TimeOfDay(hour: 11, minute: 0),
        createdAt: DateTime(2026, 9, 20),
      );
      final pass = MockQrCodeService().createVisitorPass(invitation: invitation);
      final rawQr = pass.toQrPayload();

      final parsed = DecodedQrPayload.parse(rawQr);

      expect(parsed.isValidFormat, isTrue);
      expect(parsed.type, equals(QrPayloadType.visitor));
      expect(parsed.passId, equals(pass.passId));
      expect(parsed.verificationToken, equals(pass.verificationToken));
      expect(parsed.rawStatus, equals('active'));
      expect(parsed.expiresAt, equals(pass.expiresAt));

      // Security/Privacy rule: raw QR does not extract phone number
      expect(parsed.rawData, isNot(contains('08099887766')));
    });

    test('Event payload parsing extracts required event access fields', () {
      final event = EstateEvent(
        id: 'evt_201',
        name: 'Annual General Meeting',
        eventDate: DateTime(2026, 11, 10),
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 15, minute: 0),
        expectedGuests: 120,
        createdAt: DateTime(2026, 9, 20),
      );
      final pass = MockQrCodeService().createEventPass(event: event);
      final rawQr = pass.toQrPayload();

      final parsed = DecodedQrPayload.parse(rawQr);

      expect(parsed.isValidFormat, isTrue);
      expect(parsed.type, equals(QrPayloadType.event));
      expect(parsed.passId, equals(pass.passId));
      expect(parsed.verificationToken, equals(pass.verificationToken));
      expect(parsed.rawStatus, equals('active'));
    });

    test('Parser handles missing fields, empty strings, and invalid JSON gracefully', () {
      // Empty input
      final emptyResult = DecodedQrPayload.parse('');
      expect(emptyResult.isValidFormat, isFalse);
      expect(emptyResult.type, equals(QrPayloadType.unrecognized));

      // Arbitrary URL / text
      final urlResult = DecodedQrPayload.parse('https://example.com/gate-pass');
      expect(urlResult.isValidFormat, isFalse);
      expect(urlResult.type, equals(QrPayloadType.unrecognized));

      // Valid JSON but missing required fields (e.g. no passId or verificationToken)
      final missingFields = DecodedQrPayload.parse('{"type":"visitor"}');
      expect(missingFields.isValidFormat, isFalse);
      expect(missingFields.type, equals(QrPayloadType.unrecognized));

      // Unknown type
      final unknownType = DecodedQrPayload.parse(
          '{"passId":"BT-123","type":"delivery","verificationToken":"VT-ABC"}');
      expect(unknownType.isValidFormat, isFalse);
      expect(unknownType.type, equals(QrPayloadType.unrecognized));

      // Malformed JSON
      final malformed = DecodedQrPayload.parse('{invalid json string');
      expect(malformed.isValidFormat, isFalse);
      expect(malformed.type, equals(QrPayloadType.unrecognized));
    });

    testWidgets('DecodedResultScreen renders SCAN RECEIVED and pass metadata for recognized visitor pass',
        (WidgetTester tester) async {
      const payload = DecodedQrPayload(
        rawData: '{"passId":"BT-V98A2","type":"visitor","verificationToken":"VT-881920","status":"active"}',
        type: QrPayloadType.visitor,
        passId: 'BT-V98A2',
        verificationToken: 'VT-881920',
        rawStatus: 'active',
        isValidFormat: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: DecodedResultScreen(payload: payload),
        ),
      );

      // Header & Status
      expect(find.text(AppStrings.qrCodeScannedTitle), findsNWidgets(2)); // header + card
      expect(find.text(AppStrings.scanReceivedNotice), findsNWidgets(2));

      // Metadata
      expect(find.text(AppStrings.labelPassType), findsOneWidget);
      expect(find.text('VISITOR PASS'), findsOneWidget);
      expect(find.text(AppStrings.labelPassId), findsOneWidget);
      expect(find.text('BT-V98A2'), findsOneWidget);
      expect(find.text(AppStrings.labelVerificationToken), findsOneWidget);
      expect(find.text('VT-881920'), findsOneWidget);

      // Verify no verification decision is made
      expect(find.text('VALID PASS'), findsNothing);
      expect(find.text('ALLOW ENTRY'), findsNothing);
      expect(find.text('DENY ENTRY'), findsNothing);

      // Scan again action
      expect(find.text(AppStrings.scanAgainAction), findsOneWidget);
    });

    testWidgets('DecodedResultScreen renders UNRECOGNIZED QR for non-SmartQ codes',
        (WidgetTester tester) async {
      final payload = DecodedQrPayload.unrecognized('https://unknown-website.com');

      await tester.pumpWidget(
        MaterialApp(
          home: DecodedResultScreen(payload: payload),
        ),
      );

      // Header & Warning
      expect(find.text(AppStrings.unrecognizedQrTitle), findsNWidgets(2)); // header + card
      expect(find.text(AppStrings.unrecognizedQrSubtitle), findsNWidgets(2));
      expect(find.text(AppStrings.scanAgainAction), findsOneWidget);

      // Verify no trust or entry decision
      expect(find.text('VALID PASS'), findsNothing);
      expect(find.text('ALLOW ENTRY'), findsNothing);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Phase 5C — Pass Verification + Access Decision
  // ─────────────────────────────────────────────────────────────────────────

  group('SmartQ Estates - Phase 5C PassRegistry Tests', () {
    final testInvitation = VisitorInvitation(
      id: 'inv_reg_01',
      visitorName: 'Emeka Okafor',
      phoneNumber: '08011112222',
      visitDate: DateTime.now().add(const Duration(hours: 2)),
      arrivalTime: TimeOfDay.now(),
      createdAt: DateTime.now(),
    );

    test('Register and find visitor pass', () {
      final registry = LocalPassRegistry.testInstance();
      final pass = MockQrCodeService().createVisitorPass(invitation: testInvitation);
      registry.registerVisitorPass(pass);

      final found = registry.findVisitorPass(pass.passId);
      expect(found, isNotNull);
      expect(found!.passId, equals(pass.passId));
    });

    test('Find unknown passId returns null for visitor', () {
      final registry = LocalPassRegistry.testInstance();
      final found = registry.findVisitorPass('BT-NONEXISTENT');
      expect(found, isNull);
    });

    test('Register and find event pass', () {
      final registry = LocalPassRegistry.testInstance();
      final event = EstateEvent(
        id: 'evt_reg_01',
        name: 'Test Event',
        eventDate: DateTime.now().add(const Duration(hours: 3)),
        startTime: const TimeOfDay(hour: 18, minute: 0),
        endTime: const TimeOfDay(hour: 22, minute: 0),
        expectedGuests: 20,
        createdAt: DateTime.now(),
      );
      final pass = MockQrCodeService().createEventPass(event: event);
      registry.registerEventPass(pass);

      final found = registry.findEventPass(pass.passId);
      expect(found, isNotNull);
      expect(found!.passId, equals(pass.passId));
    });

    test('Find unknown passId returns null for event', () {
      final registry = LocalPassRegistry.testInstance();
      final found = registry.findEventPass('EP-NONEXISTENT');
      expect(found, isNull);
    });

    test('updateVisitorPass reflects new status on lookup', () {
      final registry = LocalPassRegistry.testInstance();
      final pass = MockQrCodeService().createVisitorPass(invitation: testInvitation);
      registry.registerVisitorPass(pass);

      final cancelled = pass.copyWith(status: PassStatus.cancelled);
      registry.updateVisitorPass(cancelled);

      final found = registry.findVisitorPass(pass.passId);
      expect(found!.status, equals(PassStatus.cancelled));
    });
  });

  group('SmartQ Estates - Phase 5C PassVerificationService Tests', () {
    PassVerificationService makeService(LocalPassRegistry registry) {
      return LocalPassVerificationService(registry: registry);
    }

    final baseInvitation = VisitorInvitation(
      id: 'inv_v_01',
      visitorName: 'Ada Lovelace',
      phoneNumber: '08099001122',
      visitDate: DateTime.now(),
      arrivalTime: TimeOfDay(
        hour: DateTime.now().hour,
        minute: DateTime.now().minute,
      ),
      createdAt: DateTime.now(),
    );

    final futureEvent = EstateEvent(
      id: 'evt_v_01',
      name: 'Verification Test Event',
      eventDate: DateTime.now(),
      startTime: TimeOfDay(
        hour: DateTime.now().hour,
        minute: DateTime.now().minute,
      ),
      endTime: TimeOfDay(
        hour: (DateTime.now().hour + 6) % 24,
        minute: 0,
      ),
      expectedGuests: 30,
      createdAt: DateTime.now(),
    );

    test('Valid visitor pass in registry → VerificationOutcome.valid', () {
      final registry = LocalPassRegistry.testInstance();
      final service = makeService(registry);
      final pass = MockQrCodeService().createVisitorPass(invitation: baseInvitation);
      registry.registerVisitorPass(pass);

      final payload = DecodedQrPayload.parse(pass.toQrPayload());
      final result = service.verify(payload);

      expect(result.outcome, equals(VerificationOutcome.valid));
      expect(result.isAllowed, isTrue);
      expect(result.visitorPass, isNotNull);
      expect(result.visitorPass!.passId, equals(pass.passId));
    });

    test('Visitor pass not in registry → VerificationOutcome.invalid', () {
      final registry = LocalPassRegistry.testInstance();
      final service = makeService(registry);
      final pass = MockQrCodeService().createVisitorPass(invitation: baseInvitation);
      // Deliberately NOT registering

      final payload = DecodedQrPayload.parse(pass.toQrPayload());
      final result = service.verify(payload);

      expect(result.outcome, equals(VerificationOutcome.invalid));
      expect(result.isAllowed, isFalse);
    });

    test('Visitor pass with wrong token → VerificationOutcome.invalid', () {
      final registry = LocalPassRegistry.testInstance();
      final service = makeService(registry);
      final pass = MockQrCodeService().createVisitorPass(invitation: baseInvitation);
      registry.registerVisitorPass(pass);

      final tamperedPayload = DecodedQrPayload(
        rawData: pass.toQrPayload(),
        type: QrPayloadType.visitor,
        passId: pass.passId,
        verificationToken: 'VT-TAMPERED',
        rawStatus: 'active',
        isValidFormat: true,
        expiresAt: pass.expiresAt,
      );
      final result = service.verify(tamperedPayload);

      expect(result.outcome, equals(VerificationOutcome.invalid));
    });

    test('Cancelled visitor pass in registry → VerificationOutcome.cancelled', () {
      final registry = LocalPassRegistry.testInstance();
      final service = makeService(registry);
      final pass = MockQrCodeService().createVisitorPass(invitation: baseInvitation);
      registry.registerVisitorPass(pass.copyWith(status: PassStatus.cancelled));

      final payload = DecodedQrPayload(
        rawData: pass.toQrPayload(),
        type: QrPayloadType.visitor,
        passId: pass.passId,
        verificationToken: pass.verificationToken,
        rawStatus: 'active', // QR says active — registry overrides
        isValidFormat: true,
        expiresAt: pass.expiresAt,
      );
      final result = service.verify(payload);

      expect(result.outcome, equals(VerificationOutcome.cancelled));
    });

    test('Expired visitor pass (expiresAt in past) → VerificationOutcome.expired', () {
      final registry = LocalPassRegistry.testInstance();
      final service = makeService(registry);
      final expiredInvitation = VisitorInvitation(
        id: 'inv_expired_01',
        visitorName: 'Old Visitor',
        phoneNumber: '08000000001',
        visitDate: DateTime.now().subtract(const Duration(days: 2)),
        arrivalTime: const TimeOfDay(hour: 10, minute: 0),
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      );
      final pass = MockQrCodeService().createVisitorPass(invitation: expiredInvitation);
      registry.registerVisitorPass(pass);

      expect(pass.expiresAt.isBefore(DateTime.now()), isTrue);

      final payload = DecodedQrPayload(
        rawData: pass.toQrPayload(),
        type: QrPayloadType.visitor,
        passId: pass.passId,
        verificationToken: pass.verificationToken,
        rawStatus: 'active',
        isValidFormat: true,
        expiresAt: pass.expiresAt,
      );
      final result = service.verify(payload);

      expect(result.outcome, equals(VerificationOutcome.expired));
    });

    test('Valid event pass in registry → VerificationOutcome.valid', () {
      final registry = LocalPassRegistry.testInstance();
      final service = makeService(registry);
      final pass = MockQrCodeService().createEventPass(event: futureEvent);
      registry.registerEventPass(pass);

      final payload = DecodedQrPayload.parse(pass.toQrPayload());
      final result = service.verify(payload);

      expect(result.outcome, equals(VerificationOutcome.valid));
      expect(result.isAllowed, isTrue);
      expect(result.eventPass, isNotNull);
    });

    test('Event pass not in registry → VerificationOutcome.invalid', () {
      final registry = LocalPassRegistry.testInstance();
      final service = makeService(registry);
      final pass = MockQrCodeService().createEventPass(event: futureEvent);

      final payload = DecodedQrPayload.parse(pass.toQrPayload());
      final result = service.verify(payload);

      expect(result.outcome, equals(VerificationOutcome.invalid));
    });

    test('Cancelled event pass → VerificationOutcome.cancelled', () {
      final registry = LocalPassRegistry.testInstance();
      final service = makeService(registry);
      final pass = MockQrCodeService().createEventPass(event: futureEvent);
      registry.registerEventPass(pass.copyWith(status: PassStatus.cancelled));

      final payload = DecodedQrPayload(
        rawData: pass.toQrPayload(),
        type: QrPayloadType.event,
        passId: pass.passId,
        verificationToken: pass.verificationToken,
        rawStatus: 'active',
        isValidFormat: true,
        expiresAt: pass.expiresAt,
      );
      final result = service.verify(payload);

      expect(result.outcome, equals(VerificationOutcome.cancelled));
    });

    test('Expired event pass → VerificationOutcome.expired', () {
      final registry = LocalPassRegistry.testInstance();
      final service = makeService(registry);
      final pastEvent = EstateEvent(
        id: 'evt_past_01',
        name: 'Old Event',
        eventDate: DateTime.now().subtract(const Duration(days: 2)),
        startTime: const TimeOfDay(hour: 16, minute: 0),
        endTime: const TimeOfDay(hour: 20, minute: 0),
        expectedGuests: 10,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      );
      final pass = MockQrCodeService().createEventPass(event: pastEvent);
      registry.registerEventPass(pass);

      expect(pass.expiresAt.isBefore(DateTime.now()), isTrue);

      final payload = DecodedQrPayload(
        rawData: pass.toQrPayload(),
        type: QrPayloadType.event,
        passId: pass.passId,
        verificationToken: pass.verificationToken,
        rawStatus: 'active',
        isValidFormat: true,
        expiresAt: pass.expiresAt,
      );
      final result = service.verify(payload);

      expect(result.outcome, equals(VerificationOutcome.expired));
    });

    test('Unrecognized QR payload → VerificationOutcome.unrecognized', () {
      final registry = LocalPassRegistry.testInstance();
      final service = makeService(registry);
      final payload = DecodedQrPayload.unrecognized('https://unknown.site/code');
      final result = service.verify(payload);

      expect(result.outcome, equals(VerificationOutcome.unrecognized));
      expect(result.isAllowed, isFalse);
    });

    test('Empty raw QR → VerificationOutcome.unrecognized', () {
      final registry = LocalPassRegistry.testInstance();
      final service = makeService(registry);
      final payload = DecodedQrPayload.parse('');
      final result = service.verify(payload);

      expect(result.outcome, equals(VerificationOutcome.unrecognized));
    });

    test('VerificationOutcome helpers are correct', () {
      expect(VerificationOutcome.valid.isAllowed, isTrue);
      expect(VerificationOutcome.expired.isAllowed, isFalse);
      expect(VerificationOutcome.expired.denialLabel, equals('PASS EXPIRED'));
      expect(VerificationOutcome.cancelled.denialLabel, equals('PASS CANCELLED'));
      expect(VerificationOutcome.invalid.denialLabel, equals('PASS COULD NOT BE VERIFIED'));
      expect(VerificationOutcome.unrecognized.denialLabel, equals('UNRECOGNIZED QR CODE'));
    });
  });

  group('SmartQ Estates - Phase 5C AccessResultScreen Widget Tests', () {
    // Helper: builds AccessResultScreen with a pre-built result (bypasses live service).
    Widget buildResultScreen(PassVerificationResult result) {
      const payload = DecodedQrPayload(
        rawData: '{}',
        type: QrPayloadType.unrecognized,
        isValidFormat: false,
      );
      return MaterialApp(
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: AccessResultScreen(
          payload: payload,
          verificationService: _FixedResultService(result),
        ),
      );
    }

    final testInvitation = VisitorInvitation(
      id: 'inv_ar_01',
      visitorName: 'Chidinma Obi',
      phoneNumber: '08055556666',
      visitDate: DateTime.now().add(const Duration(hours: 1)),
      arrivalTime: TimeOfDay.now(),
      createdAt: DateTime.now(),
    );

    final testEvent = EstateEvent(
      id: 'evt_ar_01',
      name: 'Graduation Dinner',
      eventDate: DateTime.now(),
      startTime: TimeOfDay(
        hour: DateTime.now().hour,
        minute: 0,
      ),
      endTime: TimeOfDay(
        hour: (DateTime.now().hour + 5) % 24,
        minute: 0,
      ),
      expectedGuests: 40,
      createdAt: DateTime.now(),
    );

    testWidgets('ACCESS ALLOWED visitor pass renders name, pass ID, DONE, SCAN AGAIN',
        (WidgetTester tester) async {
      final pass = MockQrCodeService().createVisitorPass(invitation: testInvitation);
      final result = PassVerificationResult(
        outcome: VerificationOutcome.valid,
        passType: QrPayloadType.visitor,
        passId: pass.passId,
        verifiedAt: DateTime.now(),
        visitorPass: pass,
      );

      await tester.pumpWidget(buildResultScreen(result));

      expect(find.text(AppStrings.accessAllowed), findsWidgets);
      expect(find.text('Chidinma Obi'), findsOneWidget);
      expect(find.text(pass.passId), findsOneWidget);
      expect(find.text(AppStrings.doneAction), findsOneWidget);
      expect(find.text(AppStrings.scanAgainAction), findsOneWidget);
    });

    testWidgets('ACCESS ALLOWED event pass renders event name, event code, DONE, SCAN AGAIN',
        (WidgetTester tester) async {
      final pass = MockQrCodeService().createEventPass(event: testEvent);
      final result = PassVerificationResult(
        outcome: VerificationOutcome.valid,
        passType: QrPayloadType.event,
        passId: pass.passId,
        verifiedAt: DateTime.now(),
        eventPass: pass,
      );

      await tester.pumpWidget(buildResultScreen(result));

      expect(find.text(AppStrings.accessAllowed), findsWidgets);
      expect(find.text('Graduation Dinner'), findsOneWidget);
      expect(find.text(pass.eventCode), findsOneWidget);
      expect(find.text(AppStrings.doneAction), findsOneWidget);
      expect(find.text(AppStrings.scanAgainAction), findsOneWidget);
    });

    testWidgets('ACCESS DENIED expired: shows PASS EXPIRED, no DONE',
        (WidgetTester tester) async {
      final result = PassVerificationResult(
        outcome: VerificationOutcome.expired,
        passType: QrPayloadType.visitor,
        passId: 'BT-EXP01',
        verifiedAt: DateTime.now(),
      );

      await tester.pumpWidget(buildResultScreen(result));

      expect(find.text(AppStrings.accessDenied), findsWidgets);
      expect(find.text('PASS EXPIRED'), findsWidgets);
      expect(find.text(AppStrings.scanAgainAction), findsOneWidget);
      expect(find.text(AppStrings.doneAction), findsNothing);
    });

    testWidgets('ACCESS DENIED cancelled: shows PASS CANCELLED, no DONE',
        (WidgetTester tester) async {
      final result = PassVerificationResult(
        outcome: VerificationOutcome.cancelled,
        passType: QrPayloadType.visitor,
        passId: 'BT-CAN01',
        verifiedAt: DateTime.now(),
      );

      await tester.pumpWidget(buildResultScreen(result));

      expect(find.text(AppStrings.accessDenied), findsWidgets);
      expect(find.text('PASS CANCELLED'), findsWidgets);
      expect(find.text(AppStrings.scanAgainAction), findsOneWidget);
      expect(find.text(AppStrings.doneAction), findsNothing);
    });

    testWidgets('ACCESS DENIED invalid: shows PASS COULD NOT BE VERIFIED',
        (WidgetTester tester) async {
      final result = PassVerificationResult(
        outcome: VerificationOutcome.invalid,
        passType: QrPayloadType.visitor,
        passId: 'BT-INV01',
        verifiedAt: DateTime.now(),
      );

      await tester.pumpWidget(buildResultScreen(result));

      expect(find.text(AppStrings.accessDenied), findsWidgets);
      expect(find.text('PASS COULD NOT BE VERIFIED'), findsWidgets);
      expect(find.text(AppStrings.scanAgainAction), findsOneWidget);
    });

    testWidgets('ACCESS DENIED unrecognized: shows UNRECOGNIZED QR CODE',
        (WidgetTester tester) async {
      final result = PassVerificationResult(
        outcome: VerificationOutcome.unrecognized,
        passType: QrPayloadType.unrecognized,
        verifiedAt: DateTime.now(),
      );

      await tester.pumpWidget(buildResultScreen(result));

      expect(find.text(AppStrings.accessDenied), findsWidgets);
      expect(find.text('UNRECOGNIZED QR CODE'), findsWidgets);
      expect(find.text(AppStrings.scanAgainAction), findsOneWidget);
      expect(find.text(AppStrings.doneAction), findsNothing);
    });

    testWidgets('SCAN AGAIN pops back to previous screen', (WidgetTester tester) async {
      const payload = DecodedQrPayload(
        rawData: '{}',
        type: QrPayloadType.unrecognized,
        isValidFormat: false,
      );
      final result = PassVerificationResult(
        outcome: VerificationOutcome.unrecognized,
        passType: QrPayloadType.unrecognized,
        verifiedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AccessResultScreen(
                      payload: payload,
                      verificationService: _FixedResultService(result),
                    ),
                  ),
                ),
                child: const Text('OPEN RESULT'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('OPEN RESULT'));
      await tester.pumpAndSettle();
      expect(find.byType(AccessResultScreen), findsOneWidget);

      await tester.tap(find.text(AppStrings.scanAgainAction));
      await tester.pumpAndSettle();

      expect(find.byType(AccessResultScreen), findsNothing);
      expect(find.text('OPEN RESULT'), findsOneWidget);
    });
  });

  group('SmartQ Estates - Phase 5D AccessRecord Tests', () {
    test('AccessRecord.create sets defaults, generates ID, and sets entry type', () {
      final now = DateTime.now();
      final record = AccessRecord.create(
        passId: 'VP-TEST-1',
        passType: QrPayloadType.visitor,
        subjectName: 'Alice Green',
        gateId: 'GATE 1',
        enteredAt: now,
      );

      expect(record.id.startsWith('AR-'), isTrue);
      expect(record.passId, 'VP-TEST-1');
      expect(record.passType, QrPayloadType.visitor);
      expect(record.accessType, AccessType.entry);
      expect(record.subjectName, 'Alice Green');
      expect(record.gateId, 'GATE 1');
      expect(record.enteredAt, now);
      expect(record.createdAt, now);
      expect(record.recordedBy, isNull);
    });
  });

  group('SmartQ Estates - Phase 5D AccessLogRepository Tests', () {
    late LocalAccessLogRepository repo;
    final qrService = MockQrCodeService();

    setUp(() {
      repo = LocalAccessLogRepository.testInstance();
    });

    test('recordEntry records visitor entry with subjectName from invitation', () {
      final inv = VisitorInvitation(
        id: 'inv_5d_01',
        visitorName: 'David Clark',
        phoneNumber: '08011112222',
        visitDate: DateTime.now(),
        arrivalTime: const TimeOfDay(hour: 14, minute: 0),
        createdAt: DateTime.now(),
      );
      final pass = qrService.createVisitorPass(invitation: inv);
      final result = PassVerificationResult(
        outcome: VerificationOutcome.valid,
        passType: QrPayloadType.visitor,
        passId: pass.passId,
        verifiedAt: DateTime.now(),
        visitorPass: pass,
      );

      final record = repo.recordEntry(result: result, gateId: 'GATE 1');

      expect(record.passId, pass.passId);
      expect(record.subjectName, 'David Clark');
      expect(record.passType, QrPayloadType.visitor);
      expect(record.gateId, 'GATE 1');
      expect(repo.getTodayEntries().length, 1);
      expect(repo.getRecentEntries().first.id, record.id);
    });

    test('recordEntry records event entry with subjectName from event', () {
      final event = EstateEvent(
        id: 'evt_5d_01',
        name: 'Community BBQ',
        eventDate: DateTime.now(),
        startTime: const TimeOfDay(hour: 16, minute: 0),
        endTime: const TimeOfDay(hour: 20, minute: 0),
        expectedGuests: 50,
        createdAt: DateTime.now(),
      );
      final pass = qrService.createEventPass(event: event);
      final result = PassVerificationResult(
        outcome: VerificationOutcome.valid,
        passType: QrPayloadType.event,
        passId: pass.passId,
        verifiedAt: DateTime.now(),
        eventPass: pass,
      );

      final record = repo.recordEntry(result: result, gateId: 'GATE 2');

      expect(record.passId, pass.passId);
      expect(record.subjectName, 'Community BBQ');
      expect(record.passType, QrPayloadType.event);
      expect(record.gateId, 'GATE 2');
      expect(repo.getTodayEntries().length, 1);
    });

    test('recordEntry throws ArgumentError when outcome is not valid', () {
      final result = PassVerificationResult(
        outcome: VerificationOutcome.expired,
        passType: QrPayloadType.visitor,
        passId: 'VP-EXPIRED',
        verifiedAt: DateTime.now(),
      );

      expect(
        () => repo.recordEntry(result: result, gateId: 'GATE 1'),
        throwsArgumentError,
      );
      expect(repo.getTodayEntries(), isEmpty);
    });

    test('getTodayEntries filters by current date and getRecentEntries respects limit', () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      final inv = VisitorInvitation(
        id: 'inv_5d_02',
        visitorName: 'Yesterday Visitor',
        phoneNumber: '08033334444',
        visitDate: yesterday,
        arrivalTime: const TimeOfDay(hour: 10, minute: 0),
        createdAt: yesterday,
      );
      final pass = qrService.createVisitorPass(invitation: inv);
      final validResult = PassVerificationResult(
        outcome: VerificationOutcome.valid,
        passType: QrPayloadType.visitor,
        passId: pass.passId,
        verifiedAt: now,
        visitorPass: pass,
      );

      repo.recordEntry(result: validResult, gateId: 'GATE 1', timestamp: yesterday);
      expect(repo.getTodayEntries(), isEmpty);
      expect(repo.getRecentEntries().length, 1);

      repo.recordEntry(result: validResult, gateId: 'GATE 1', timestamp: now);
      expect(repo.getTodayEntries().length, 1);
      expect(repo.getRecentEntries(limit: 1).length, 1);
      expect(repo.getRecentEntries().length, 2);

      repo.clear();
      expect(repo.getTodayEntries(), isEmpty);
      expect(repo.getRecentEntries(), isEmpty);
    });
  });

  group('SmartQ Estates - Phase 5D AccessResultScreen Check-In Widget Tests', () {
    late LocalAccessLogRepository testRepo;
    final qrService = MockQrCodeService();

    setUp(() {
      testRepo = LocalAccessLogRepository.testInstance();
    });

    testWidgets('ACCESS ALLOWED renders ALLOW ENTRY button and subtitle', (tester) async {
      final inv = VisitorInvitation(
        id: 'inv_5d_03',
        visitorName: 'Michael Brown',
        phoneNumber: '08099998888',
        visitDate: DateTime.now(),
        arrivalTime: const TimeOfDay(hour: 10, minute: 0),
        createdAt: DateTime.now(),
      );
      final pass = qrService.createVisitorPass(invitation: inv);
      final payload = DecodedQrPayload.parse(pass.toQrPayload());
      final result = PassVerificationResult(
        outcome: VerificationOutcome.valid,
        passType: QrPayloadType.visitor,
        passId: pass.passId,
        verifiedAt: DateTime.now(),
        visitorPass: pass,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: AccessResultScreen(
            payload: payload,
            verificationService: _FixedResultService(result),
            accessLogRepository: testRepo,
          ),
        ),
      );

      expect(find.text(AppStrings.accessAllowed), findsWidgets);
      expect(find.text(AppStrings.allowEntryAction), findsOneWidget);
      expect(find.text(AppStrings.allowEntrySubtitle), findsOneWidget);
      expect(find.text(AppStrings.doneAction), findsOneWidget);
    });

    testWidgets('ACCESS DENIED does NOT render ALLOW ENTRY button or subtitle', (tester) async {
      final payload = DecodedQrPayload.unrecognized('GARBAGE');
      final result = PassVerificationResult(
        outcome: VerificationOutcome.unrecognized,
        passType: QrPayloadType.unrecognized,
        verifiedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: AccessResultScreen(
            payload: payload,
            verificationService: _FixedResultService(result),
            accessLogRepository: testRepo,
          ),
        ),
      );

      expect(find.text(AppStrings.accessDenied), findsWidgets);
      expect(find.text(AppStrings.allowEntryAction), findsNothing);
      expect(find.text(AppStrings.allowEntrySubtitle), findsNothing);
      expect(find.text(AppStrings.doneAction), findsNothing);
    });

    testWidgets('ALLOW ENTRY flow: dialog cancel does NOT record entry', (tester) async {
      final inv = VisitorInvitation(
        id: 'inv_5d_04',
        visitorName: 'Elena Rostova',
        phoneNumber: '08022223333',
        visitDate: DateTime.now(),
        arrivalTime: const TimeOfDay(hour: 11, minute: 0),
        createdAt: DateTime.now(),
      );
      final pass = qrService.createVisitorPass(invitation: inv);
      final payload = DecodedQrPayload.parse(pass.toQrPayload());
      final result = PassVerificationResult(
        outcome: VerificationOutcome.valid,
        passType: QrPayloadType.visitor,
        passId: pass.passId,
        verifiedAt: DateTime.now(),
        visitorPass: pass,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: AccessResultScreen(
            payload: payload,
            verificationService: _FixedResultService(result),
            accessLogRepository: testRepo,
          ),
        ),
      );

      // Tap ALLOW ENTRY
      await tester.tap(find.text(AppStrings.allowEntryAction));
      await tester.pumpAndSettle();

      // Dialog is displayed with visitor name
      expect(find.text(AppStrings.allowEntryConfirmTitle), findsOneWidget);
      expect(find.text('Elena Rostova'), findsWidgets);

      // Tap CANCEL
      await tester.tap(find.text(AppStrings.allowEntryConfirmCancel));
      await tester.pumpAndSettle();

      // Dialog dismissed, no entry recorded, button still visible
      expect(find.text(AppStrings.allowEntryConfirmTitle), findsNothing);
      expect(find.text(AppStrings.allowEntryAction), findsOneWidget);
      expect(testRepo.getTodayEntries(), isEmpty);
    });

    testWidgets('ALLOW ENTRY flow: confirm records entry, shows ENTRY RECORDED card, prevents duplicate entry', (tester) async {
      final inv = VisitorInvitation(
        id: 'inv_5d_05',
        visitorName: 'Elena Rostova',
        phoneNumber: '08022223333',
        visitDate: DateTime.now(),
        arrivalTime: const TimeOfDay(hour: 11, minute: 0),
        createdAt: DateTime.now(),
      );
      final pass = qrService.createVisitorPass(invitation: inv);
      final payload = DecodedQrPayload.parse(pass.toQrPayload());
      final result = PassVerificationResult(
        outcome: VerificationOutcome.valid,
        passType: QrPayloadType.visitor,
        passId: pass.passId,
        verifiedAt: DateTime.now(),
        visitorPass: pass,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: AccessResultScreen(
            payload: payload,
            verificationService: _FixedResultService(result),
            accessLogRepository: testRepo,
          ),
        ),
      );

      // Tap ALLOW ENTRY
      await tester.tap(find.text(AppStrings.allowEntryAction));
      await tester.pumpAndSettle();

      // Tap ALLOW ENTRY in dialog (finds instance inside dialog)
      final dialogAllowButton = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text(AppStrings.allowEntryAction),
      );
      await tester.tap(dialogAllowButton);
      await tester.pumpAndSettle();

      // Entry is recorded in repo
      expect(testRepo.getTodayEntries().length, 1);
      expect(testRepo.getTodayEntries().first.subjectName, 'Elena Rostova');

      // UI updates to ENTRY RECORDED
      expect(find.text(AppStrings.entryRecordedTitle), findsOneWidget);
      expect(find.text(AppStrings.labelEntry), findsOneWidget);
      expect(find.text(AppStrings.labelGate), findsOneWidget);
      expect(find.text('GATE 1'), findsOneWidget);

      // ALLOW ENTRY button is completely removed (preventing duplicate entry)
      expect(find.text(AppStrings.allowEntryAction), findsNothing);
      expect(find.text(AppStrings.allowEntrySubtitle), findsNothing);

      // DONE button is still present
      expect(find.text(AppStrings.doneAction), findsOneWidget);
    });
  });

  group('SmartQ Estates - Phase 5D SecurityHomeScreen Activity Tests', () {
    late LocalAccessLogRepository testRepo;
    final qrService = MockQrCodeService();

    setUp(() {
      testRepo = LocalAccessLogRepository.testInstance();
    });

    testWidgets('Renders NO ACTIVITY when no check-ins exist', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SecurityHomeScreen(accessLogRepository: testRepo),
        ),
      );

      expect(find.text(AppStrings.securityTitle), findsOneWidget);
      expect(find.text(AppStrings.noActivityStatus), findsNWidgets(2)); // visitors and events
      expect(find.text(AppStrings.noRecentActivity), findsOneWidget);
      expect(find.text(AppStrings.recentActivitySubtitle), findsOneWidget);
    });

    testWidgets('Renders dynamic check-in count and recent activity list after records added', (tester) async {
      // Add a visitor record and an event record to testRepo
      final inv = VisitorInvitation(
        id: 'inv_5d_06',
        visitorName: 'Marcus Vance',
        phoneNumber: '08077778888',
        visitDate: DateTime.now(),
        arrivalTime: const TimeOfDay(hour: 9, minute: 30),
        createdAt: DateTime.now(),
      );
      final visitorPass = qrService.createVisitorPass(invitation: inv);
      final visitorResult = PassVerificationResult(
        outcome: VerificationOutcome.valid,
        passType: QrPayloadType.visitor,
        passId: visitorPass.passId,
        verifiedAt: DateTime.now(),
        visitorPass: visitorPass,
      );
      testRepo.recordEntry(result: visitorResult, gateId: 'GATE 1');

      final event = EstateEvent(
        id: 'evt_5d_02',
        name: 'Summer Gala',
        eventDate: DateTime.now(),
        startTime: const TimeOfDay(hour: 18, minute: 0),
        endTime: const TimeOfDay(hour: 22, minute: 0),
        expectedGuests: 100,
        createdAt: DateTime.now(),
      );
      final eventPass = qrService.createEventPass(event: event);
      final eventResult = PassVerificationResult(
        outcome: VerificationOutcome.valid,
        passType: QrPayloadType.event,
        passId: eventPass.passId,
        verifiedAt: DateTime.now(),
        eventPass: eventPass,
      );
      testRepo.recordEntry(result: eventResult, gateId: 'GATE 1');

      await tester.pumpWidget(
        MaterialApp(
          home: SecurityHomeScreen(accessLogRepository: testRepo),
        ),
      );

      // Verify TODAY counts
      expect(find.text('1 ${AppStrings.checkedInSuffix}'), findsOneWidget);
      expect(find.text('1 ${AppStrings.accessEventsSuffix}'), findsOneWidget);

      // Verify RECENT ACTIVITY items
      expect(find.text(AppStrings.noRecentActivity), findsNothing);
      expect(find.text('Marcus Vance'), findsOneWidget);
      expect(find.text('Summer Gala'), findsOneWidget);
      expect(find.text('VISITOR · GATE 1'), findsOneWidget);
      expect(find.text('EVENT · GATE 1'), findsOneWidget);
      expect(find.text(AppStrings.labelEntry), findsNWidgets(2));
    });
  });

}


// ─── Test helpers ─────────────────────────────────────────────────────────────

/// A [PassVerificationService] that always returns a pre-built result.
/// Used in widget tests to decouple UI from registry state.
class _FixedResultService implements PassVerificationService {
  final PassVerificationResult _result;
  _FixedResultService(this._result);

  @override
  PassVerificationResult verify(DecodedQrPayload payload) => _result;
}
