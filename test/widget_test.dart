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
}
