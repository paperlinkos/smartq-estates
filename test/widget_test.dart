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
// Phase 6A imports
import 'package:smartq_estates/screens/services/services_home_screen.dart';

// Phase 6B imports
import 'package:smartq_estates/core/models/market_run_request.dart';
import 'package:smartq_estates/core/repositories/market_run_repository.dart';
import 'package:smartq_estates/screens/services/market_run_screen.dart';
import 'package:smartq_estates/screens/services/market_run_requested_screen.dart';
// Phase 6C imports
import 'package:smartq_estates/core/models/grocery_request.dart';
import 'package:smartq_estates/core/repositories/grocery_repository.dart';
import 'package:smartq_estates/screens/services/groceries_screen.dart';
import 'package:smartq_estates/screens/services/groceries_requested_screen.dart';
// Phase 6D imports
import 'package:smartq_estates/core/models/gas_request.dart';
import 'package:smartq_estates/core/repositories/gas_repository.dart';
import 'package:smartq_estates/screens/services/gas_screen.dart';
import 'package:smartq_estates/screens/services/gas_requested_screen.dart';
// Phase 6E imports
import 'package:smartq_estates/core/models/petrol_request.dart';
import 'package:smartq_estates/core/repositories/petrol_repository.dart';
import 'package:smartq_estates/screens/services/petrol_screen.dart';
import 'package:smartq_estates/screens/services/petrol_requested_screen.dart';
// Phase 6F imports
import 'package:smartq_estates/core/models/generator_request.dart';
import 'package:smartq_estates/core/repositories/generator_repository.dart';
import 'package:smartq_estates/screens/services/generator_screen.dart';
import 'package:smartq_estates/screens/services/generator_requested_screen.dart';
// Phase 6G imports
import 'package:smartq_estates/core/models/maintenance_request.dart';
import 'package:smartq_estates/core/repositories/maintenance_repository.dart';
import 'package:smartq_estates/screens/services/maintenance_screen.dart';
import 'package:smartq_estates/screens/services/maintenance_requested_screen.dart';
// Phase 7 imports
import 'package:smartq_estates/core/models/service_request_item.dart';
import 'package:smartq_estates/core/services/service_coordinator.dart';
import 'package:smartq_estates/screens/services/my_service_requests_screen.dart';
import 'package:smartq_estates/screens/services/service_request_detail_screen.dart';
import 'package:smartq_estates/screens/operations/estate_operations_screen.dart';
import 'package:smartq_estates/screens/management/management_home_screen.dart';
import 'package:smartq_estates/screens/management/management_request_detail_screen.dart';
import 'package:smartq_estates/screens/management/management_requests_screen.dart';
import 'package:smartq_estates/screens/management/management_shell_screen.dart';
import 'package:smartq_estates/widgets/prototype_role_switcher.dart';





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

    testWidgets('VerifyAccessScannerScreen provides showcase test buttons and navigates to AccessResultScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const VerifyAccessScannerScreen(),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('TEST VALID PASS'), findsOneWidget);
      expect(find.text('TEST EXPIRED PASS'), findsOneWidget);

      await tester.tap(find.text('TEST VALID PASS'));
      await tester.pumpAndSettle();

      expect(find.byType(AccessResultScreen), findsOneWidget);
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

  group('SmartQ Estates - Phase 6A Resident Services Home Tests', () {
    testWidgets('ServicesHomeScreen renders header, subtitle, and primary question',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ServicesHomeScreen(),
        ),
      );

      // Header & Subtitle
      expect(find.text(AppStrings.servicesTitle), findsOneWidget);
      expect(find.text(AppStrings.servicesSubtitle), findsOneWidget);

      // Primary Question
      expect(find.text(AppStrings.servicesQuestion), findsOneWidget);
      expect(find.text(AppStrings.servicesQuestionSubtitle), findsOneWidget);
    });

    testWidgets('All six service cards render with correct titles and subtitles',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ServicesHomeScreen(),
        ),
      );

      // 1. MARKET RUN
      expect(find.text(AppStrings.marketRunTitle), findsOneWidget);
      expect(find.text(AppStrings.marketRunSubtitle), findsOneWidget);

      // 2. GROCERIES
      expect(find.text(AppStrings.groceriesTitle), findsOneWidget);
      expect(find.text(AppStrings.groceriesSubtitle), findsOneWidget);

      // 3. GAS
      expect(find.text(AppStrings.gasTitle), findsOneWidget);
      expect(find.text(AppStrings.gasSubtitle), findsOneWidget);

      // 4. PETROL
      expect(find.text(AppStrings.petrolTitle), findsOneWidget);
      expect(find.text(AppStrings.petrolSubtitle), findsOneWidget);

      // 5. GENERATOR
      expect(find.text(AppStrings.generatorTitle), findsOneWidget);
      expect(find.text(AppStrings.generatorSubtitle), findsOneWidget);

      // 6. MAINTENANCE
      expect(find.text(AppStrings.maintenanceTitle), findsOneWidget);
      expect(find.text(AppStrings.maintenanceSubtitle), findsOneWidget);
    });

    testWidgets('Tapping each service card navigates to its corresponding placeholder screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ServicesHomeScreen(),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      // Market Run navigates to MarketRunScreen (Phase 6B)
      await tester.ensureVisible(find.text(AppStrings.marketRunTitle));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.marketRunTitle));
      await tester.pumpAndSettle();
      expect(find.byType(MarketRunScreen), findsOneWidget);
      final marketRunBackButton = find.descendant(
        of: find.byType(MarketRunScreen),
        matching: find.byIcon(Icons.arrow_back),
      );
      await tester.tap(marketRunBackButton);
      await tester.pumpAndSettle();
      expect(find.byType(ServicesHomeScreen), findsOneWidget);

      // Groceries navigates to GroceriesScreen (Phase 6C)
      await tester.ensureVisible(find.text(AppStrings.groceriesTitle));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.groceriesTitle));
      await tester.pumpAndSettle();
      expect(find.byType(GroceriesScreen), findsOneWidget);
      final groceriesBackButton = find.descendant(
        of: find.byType(GroceriesScreen),
        matching: find.byIcon(Icons.arrow_back),
      );
      await tester.tap(groceriesBackButton);
      await tester.pumpAndSettle();
      expect(find.byType(ServicesHomeScreen), findsOneWidget);

      // Gas navigates to GasScreen (Phase 6D)
      await tester.ensureVisible(find.text(AppStrings.gasTitle));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.gasTitle));
      await tester.pumpAndSettle();
      expect(find.byType(GasScreen), findsOneWidget);
      final gasBackButton = find.descendant(
        of: find.byType(GasScreen),
        matching: find.byIcon(Icons.arrow_back),
      );
      await tester.tap(gasBackButton);
      await tester.pumpAndSettle();
      expect(find.byType(ServicesHomeScreen), findsOneWidget);

      // Petrol navigates to PetrolScreen (Phase 6E)
      await tester.ensureVisible(find.text(AppStrings.petrolTitle));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.petrolTitle));
      await tester.pumpAndSettle();
      expect(find.byType(PetrolScreen), findsOneWidget);
      final petrolBackButton = find.descendant(
        of: find.byType(PetrolScreen),
        matching: find.byIcon(Icons.arrow_back),
      );
      await tester.tap(petrolBackButton);
      await tester.pumpAndSettle();
      expect(find.byType(ServicesHomeScreen), findsOneWidget);

      // Generator navigates to GeneratorScreen (Phase 6F)
      await tester.ensureVisible(find.text(AppStrings.generatorTitle));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.generatorTitle));
      await tester.pumpAndSettle();
      expect(find.byType(GeneratorScreen), findsOneWidget);
      final generatorBackButton = find.descendant(
        of: find.byType(GeneratorScreen),
        matching: find.byIcon(Icons.arrow_back),
      );
      await tester.tap(generatorBackButton);
      await tester.pumpAndSettle();
      expect(find.byType(ServicesHomeScreen), findsOneWidget);

      // Maintenance navigates to MaintenanceScreen (Phase 6G)
      await tester.ensureVisible(find.text(AppStrings.maintenanceTitle));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.maintenanceTitle));
      await tester.pumpAndSettle();
      expect(find.byType(MaintenanceScreen), findsOneWidget);
      final maintenanceBackButton = find.descendant(
        of: find.byType(MaintenanceScreen),
        matching: find.byIcon(Icons.arrow_back),
      );
      await tester.tap(maintenanceBackButton);
      await tester.pumpAndSettle();
      expect(find.byType(ServicesHomeScreen), findsOneWidget);
    });

    testWidgets('Back navigation from ServicesHomeScreen returns to previous screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ServicesHomeScreen()),
                ),
                child: const Text('RESIDENT HOME'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('RESIDENT HOME'));
      await tester.pumpAndSettle();
      expect(find.byType(ServicesHomeScreen), findsOneWidget);

      // Tap back in header
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byType(ServicesHomeScreen), findsNothing);
      expect(find.text('RESIDENT HOME'), findsOneWidget);
    });
  });

  group('SmartQ Estates - Phase 6B MarketRunRequest Model Tests', () {
    test('MarketRunRequest.create initializes defaults and fields', () {
      final req = MarketRunRequest.create(
        items: 'Tomatoes, Onions, Peppers, Rice',
        timing: MarketRunTiming.asSoonAsPossible,
      );

      expect(req.id.startsWith('MR-'), isTrue);
      expect(req.items, 'Tomatoes, Onions, Peppers, Rice');
      expect(req.timing, MarketRunTiming.asSoonAsPossible);
      expect(req.scheduledFor, isNull);
      expect(req.deliveryLocation, 'estateAddress');
      expect(req.notes, isNull);
      expect(req.status, MarketRunStatus.requested);
      expect(req.createdAt, isNotNull);
    });

    test('MarketRunRequest supports scheduled timing and optional notes', () {
      final scheduledTime = DateTime.now().add(const Duration(days: 1));
      final req = MarketRunRequest.create(
        items: '2 cartons of bottled water',
        timing: MarketRunTiming.scheduled,
        scheduledFor: scheduledTime,
        notes: 'Call before arriving',
      );

      expect(req.items, '2 cartons of bottled water');
      expect(req.timing, MarketRunTiming.scheduled);
      expect(req.scheduledFor, scheduledTime);
      expect(req.notes, 'Call before arriving');
      expect(req.status, MarketRunStatus.requested);
    });

    test('MarketRunTiming enum has expected values', () {
      expect(MarketRunTiming.values, containsAll([
        MarketRunTiming.asSoonAsPossible,
        MarketRunTiming.laterToday,
        MarketRunTiming.scheduled,
      ]));
    });

    test('MarketRunStatus enum has expected values', () {
      expect(MarketRunStatus.values, containsAll([
        MarketRunStatus.requested,
        MarketRunStatus.assigned,
        MarketRunStatus.shopping,
        MarketRunStatus.outForDelivery,
        MarketRunStatus.delivered,
        MarketRunStatus.cancelled,
      ]));
    });
  });

  group('SmartQ Estates - Phase 6B MarketRunRepository Tests', () {
    late LocalMarketRunRepository repo;

    setUp(() {
      repo = LocalMarketRunRepository.testInstance();
    });

    test('createRequest stores and returns request', () {
      final req = MarketRunRequest.create(
        items: 'Bread and Eggs',
        timing: MarketRunTiming.asSoonAsPossible,
      );

      final created = repo.createRequest(req);
      expect(created.id, req.id);
      expect(repo.getRequests().length, 1);
      expect(repo.getRequests().first.id, req.id);
    });

    test('getRequests returns requests sorted by createdAt descending', () {
      final first = MarketRunRequest.create(
        items: 'First Item',
        timing: MarketRunTiming.laterToday,
        createdAt: DateTime(2026, 1, 1, 10, 0),
      );
      final second = MarketRunRequest.create(
        items: 'Second Item',
        timing: MarketRunTiming.asSoonAsPossible,
        createdAt: DateTime(2026, 1, 1, 11, 0),
      );

      repo.createRequest(first);
      repo.createRequest(second);

      final list = repo.getRequests();
      expect(list.length, 2);
      expect(list[0].id, second.id);
      expect(list[1].id, first.id);
    });

    test('getRequestById returns matching request or null', () {
      final req = MarketRunRequest.create(
        items: 'Yams and Palm Oil',
        timing: MarketRunTiming.asSoonAsPossible,
      );
      repo.createRequest(req);

      expect(repo.getRequestById(req.id)?.items, 'Yams and Palm Oil');
      expect(repo.getRequestById('NON-EXISTENT'), isNull);
    });

    test('clear removes all requests', () {
      repo.createRequest(MarketRunRequest.create(
        items: 'Sugar and Milk',
        timing: MarketRunTiming.laterToday,
      ));
      expect(repo.getRequests().length, 1);

      repo.clear();
      expect(repo.getRequests(), isEmpty);
    });
  });

  group('SmartQ Estates - Phase 6B MarketRunScreen Widget Tests', () {
    late LocalMarketRunRepository testRepo;

    setUp(() {
      testRepo = LocalMarketRunRepository.testInstance();
    });

    testWidgets('MarketRunScreen renders header, subtitle, question, and inputs',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MarketRunScreen(repository: testRepo),
        ),
      );

      // Header & Subtitle
      expect(find.text(AppStrings.marketRunTitle), findsOneWidget);
      expect(find.text(AppStrings.marketRunHeaderSubtitle), findsOneWidget);

      // Question section
      expect(find.text(AppStrings.marketRunQuestion), findsOneWidget);
      expect(find.text(AppStrings.marketRunQuestionSubtitle), findsOneWidget);

      // Multiline items input
      expect(find.text(AppStrings.labelItems), findsOneWidget);
      expect(find.text(AppStrings.hintMarketRunItems), findsOneWidget);

      // Timing options
      expect(find.text(AppStrings.timingHeading), findsOneWidget);
      expect(find.text(AppStrings.timingAsap), findsOneWidget);
      expect(find.text(AppStrings.timingLaterToday), findsOneWidget);
      expect(find.text(AppStrings.timingSchedule), findsOneWidget);

      // Deliver to
      expect(find.text(AppStrings.labelDeliverTo), findsOneWidget);
      expect(find.text(AppStrings.myEstateAddress), findsOneWidget);

      // Notes (optional)
      expect(find.text(AppStrings.labelNotesOptional), findsOneWidget);
      expect(find.text(AppStrings.hintMarketRunNotes), findsOneWidget);

      // Submit button
      expect(find.text(AppStrings.actionRequestMarketRun), findsOneWidget);
    });

    testWidgets('Submitting with empty items displays error message',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MarketRunScreen(repository: testRepo),
        ),
      );

      await tester.ensureVisible(find.text(AppStrings.actionRequestMarketRun));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.actionRequestMarketRun));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.errorItemsRequired), findsOneWidget);
      expect(testRepo.getRequests(), isEmpty);
    });

    testWidgets('Can select timing options: ASAP, LATER TODAY, SCHEDULE',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MarketRunScreen(repository: testRepo),
        ),
      );

      // Default is ASAP
      // Select LATER TODAY
      await tester.ensureVisible(find.text(AppStrings.timingLaterToday));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.timingLaterToday));
      await tester.pumpAndSettle();

      // Schedule pickers should not be shown yet
      expect(find.text('Select Date'), findsNothing);

      // Select SCHEDULE
      await tester.ensureVisible(find.text(AppStrings.timingSchedule));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.timingSchedule));
      await tester.pumpAndSettle();

      // Schedule pickers should now appear
      expect(find.text('Select Date'), findsOneWidget);
      expect(find.text('Select Time'), findsOneWidget);
    });

    testWidgets('SCHEDULE without choosing date/time displays error when submitting',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MarketRunScreen(repository: testRepo),
        ),
      );

      // Enter valid items
      await tester.enterText(
        find.widgetWithText(TextField, AppStrings.hintMarketRunItems),
        'Bag of Rice, 5L Groundnut Oil',
      );
      await tester.pumpAndSettle();

      // Select SCHEDULE
      await tester.ensureVisible(find.text(AppStrings.timingSchedule));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.timingSchedule));
      await tester.pumpAndSettle();

      // Tap submit without setting date/time
      await tester.ensureVisible(find.text(AppStrings.actionRequestMarketRun));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.actionRequestMarketRun));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.errorScheduledRequired), findsOneWidget);
      expect(testRepo.getRequests(), isEmpty);
    });

    testWidgets('Valid submission saves request to repo and navigates to requested screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MarketRunScreen(repository: testRepo),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      // Enter items
      await tester.enterText(
        find.widgetWithText(TextField, AppStrings.hintMarketRunItems),
        'Tomatoes, Onions, Fresh Pepper, Chicken',
      );
      await tester.pumpAndSettle();

      // Enter optional notes
      await tester.ensureVisible(find.widgetWithText(TextField, AppStrings.hintMarketRunNotes));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, AppStrings.hintMarketRunNotes),
        'Please get hard chicken if available.',
      );
      await tester.pumpAndSettle();

      // Tap submit
      await tester.ensureVisible(find.text(AppStrings.actionRequestMarketRun));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.actionRequestMarketRun));
      await tester.pumpAndSettle();

      // Verify request in repository
      final requests = testRepo.getRequests();
      expect(requests.length, 1);
      expect(requests.first.items, 'Tomatoes, Onions, Fresh Pepper, Chicken');
      expect(requests.first.notes, 'Please get hard chicken if available.');
      expect(requests.first.timing, MarketRunTiming.asSoonAsPossible);
      expect(requests.first.status, MarketRunStatus.requested);

      // Verify transition to MarketRunRequestedScreen
      expect(find.byType(MarketRunRequestedScreen), findsOneWidget);
      expect(find.text(AppStrings.requestReceivedTitle), findsOneWidget);
      expect(find.text(AppStrings.requestReceivedSubtitle), findsOneWidget);
      expect(find.text('Tomatoes, Onions, Fresh Pepper, Chicken'), findsOneWidget);
      expect(find.text(AppStrings.timingAsap), findsOneWidget);
      expect(find.text(AppStrings.myEstateAddress), findsOneWidget);
      expect(find.text('Please get hard chicken if available.'), findsOneWidget);
    });
  });

  group('SmartQ Estates - Phase 6B MarketRunRequestedScreen Tests', () {
    testWidgets('Displays all request details and notes when provided',
        (WidgetTester tester) async {
      final request = MarketRunRequest.create(
        items: 'Fresh bread, Butter, Milk, Plantains',
        timing: MarketRunTiming.laterToday,
        notes: 'Deliver to Block B gate.',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MarketRunRequestedScreen(request: request),
        ),
      );

      // Header & subtitle
      expect(find.text(AppStrings.requestReceivedTitle), findsOneWidget);
      expect(find.text(AppStrings.requestReceivedSubtitle), findsOneWidget);

      // What you asked for
      expect(find.text(AppStrings.labelWhatYouAskedFor), findsOneWidget);
      expect(find.text('Fresh bread, Butter, Milk, Plantains'), findsOneWidget);

      // When
      expect(find.text(AppStrings.labelWhen), findsOneWidget);
      expect(find.text(AppStrings.timingLaterToday), findsOneWidget);

      // Deliver to
      expect(find.text(AppStrings.labelDeliverTo), findsOneWidget);
      expect(find.text(AppStrings.myEstateAddress), findsOneWidget);

      // Notes
      expect(find.text(AppStrings.labelNotes), findsOneWidget);
      expect(find.text('Deliver to Block B gate.'), findsOneWidget);

      // Done button
      expect(find.text(AppStrings.doneAction), findsOneWidget);
    });

    testWidgets('Does not display notes section when notes are null or empty',
        (WidgetTester tester) async {
      final request = MarketRunRequest.create(
        items: 'Bottled water',
        timing: MarketRunTiming.asSoonAsPossible,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MarketRunRequestedScreen(request: request),
        ),
      );

      expect(find.text(AppStrings.labelWhatYouAskedFor), findsOneWidget);
      expect(find.text(AppStrings.labelNotes), findsNothing);
    });

    testWidgets('DONE button returns to Services Home',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRouter.services),
                child: const Text('GO TO SERVICES'),
              ),
            ),
          ),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      // Open ServicesHomeScreen with named route
      await tester.tap(find.text('GO TO SERVICES'));
      await tester.pumpAndSettle();
      expect(find.byType(ServicesHomeScreen), findsOneWidget);

      // Navigate to MarketRunScreen
      await tester.ensureVisible(find.text(AppStrings.marketRunTitle));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.marketRunTitle));
      await tester.pumpAndSettle();

      expect(find.byType(MarketRunScreen), findsOneWidget);

      // Enter items
      await tester.enterText(
        find.widgetWithText(TextField, AppStrings.hintMarketRunItems),
        'Bottled water',
      );
      await tester.pumpAndSettle();

      // Submit
      await tester.ensureVisible(find.text(AppStrings.actionRequestMarketRun));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.actionRequestMarketRun));
      await tester.pumpAndSettle();

      expect(find.byType(MarketRunRequestedScreen), findsOneWidget);

      // Tap DONE
      await tester.ensureVisible(find.text(AppStrings.doneAction));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.doneAction));
      await tester.pumpAndSettle();

      // Returns to ServicesHomeScreen
      expect(find.byType(MarketRunRequestedScreen), findsNothing);
      expect(find.byType(MarketRunScreen), findsNothing);
      expect(find.byType(ServicesHomeScreen), findsOneWidget);
    });
  });

  group('SmartQ Estates - Phase 6C GroceryRequest Model Tests', () {
    test('GroceryRequest.create initializes defaults and fields', () {
      final req = GroceryRequest.create(
        items: 'Milk, Eggs, Bread, Butter',
        timing: GroceryTiming.asSoonAsPossible,
      );

      expect(req.id.startsWith('GR-'), isTrue);
      expect(req.items, 'Milk, Eggs, Bread, Butter');
      expect(req.timing, GroceryTiming.asSoonAsPossible);
      expect(req.scheduledFor, isNull);
      expect(req.deliveryLocation, 'estateAddress');
      expect(req.notes, isNull);
      expect(req.status, GroceryRequestStatus.requested);
      expect(req.createdAt, isNotNull);
    });

    test('GroceryRequest supports scheduled timing and optional notes', () {
      final scheduledTime = DateTime.now().add(const Duration(days: 2));
      final req = GroceryRequest.create(
        items: 'Cornflakes, Oat Milk, Orange Juice',
        timing: GroceryTiming.scheduled,
        scheduledFor: scheduledTime,
        notes: 'Leave at the doorstep',
      );

      expect(req.items, 'Cornflakes, Oat Milk, Orange Juice');
      expect(req.timing, GroceryTiming.scheduled);
      expect(req.scheduledFor, scheduledTime);
      expect(req.notes, 'Leave at the doorstep');
      expect(req.status, GroceryRequestStatus.requested);
    });

    test('GroceryTiming enum has expected values', () {
      expect(GroceryTiming.values, containsAll([
        GroceryTiming.asSoonAsPossible,
        GroceryTiming.laterToday,
        GroceryTiming.scheduled,
      ]));
    });

    test('GroceryRequestStatus enum has expected values', () {
      expect(GroceryRequestStatus.values, containsAll([
        GroceryRequestStatus.requested,
        GroceryRequestStatus.assigned,
        GroceryRequestStatus.shopping,
        GroceryRequestStatus.outForDelivery,
        GroceryRequestStatus.delivered,
        GroceryRequestStatus.cancelled,
      ]));
    });
  });

  group('SmartQ Estates - Phase 6C GroceryRepository Tests', () {
    late LocalGroceryRepository repo;

    setUp(() {
      repo = LocalGroceryRepository.testInstance();
    });

    test('createRequest stores and returns request', () {
      final req = GroceryRequest.create(
        items: 'Apples, Bananas',
        timing: GroceryTiming.asSoonAsPossible,
      );

      final created = repo.createRequest(req);
      expect(created.id, req.id);
      expect(repo.getRequests().length, 1);
      expect(repo.getRequests().first.id, req.id);
    });

    test('getRequests returns requests sorted by createdAt descending', () {
      final first = GroceryRequest.create(
        items: 'First Grocery Item',
        timing: GroceryTiming.laterToday,
        createdAt: DateTime(2026, 1, 1, 10, 0),
      );
      final second = GroceryRequest.create(
        items: 'Second Grocery Item',
        timing: GroceryTiming.asSoonAsPossible,
        createdAt: DateTime(2026, 1, 1, 11, 0),
      );

      repo.createRequest(first);
      repo.createRequest(second);

      final list = repo.getRequests();
      expect(list.length, 2);
      expect(list[0].id, second.id);
      expect(list[1].id, first.id);
    });

    test('getRequestById returns matching request or null', () {
      final req = GroceryRequest.create(
        items: 'Cereal and Almond Milk',
        timing: GroceryTiming.asSoonAsPossible,
      );
      repo.createRequest(req);

      expect(repo.getRequestById(req.id)?.items, 'Cereal and Almond Milk');
      expect(repo.getRequestById('NON-EXISTENT'), isNull);
    });

    test('clear removes all requests', () {
      repo.createRequest(GroceryRequest.create(
        items: 'Cheese and Crackers',
        timing: GroceryTiming.laterToday,
      ));
      expect(repo.getRequests().length, 1);

      repo.clear();
      expect(repo.getRequests(), isEmpty);
    });
  });

  group('SmartQ Estates - Phase 6C GroceriesScreen Widget Tests', () {
    late LocalGroceryRepository testRepo;

    setUp(() {
      testRepo = LocalGroceryRepository.testInstance();
    });

    testWidgets('GroceriesScreen renders header, subtitle, question, and inputs',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GroceriesScreen(repository: testRepo),
        ),
      );

      // Header & Subtitle
      expect(find.text(AppStrings.groceriesTitle), findsOneWidget);
      expect(find.text(AppStrings.groceriesHeaderSubtitle), findsOneWidget);

      // Question section
      expect(find.text(AppStrings.groceriesQuestion), findsOneWidget);
      expect(find.text(AppStrings.groceriesQuestionSubtitle), findsOneWidget);

      // Multiline items input
      expect(find.text(AppStrings.labelItems), findsOneWidget);
      expect(find.text(AppStrings.hintGroceriesItems), findsOneWidget);

      // Timing options
      expect(find.text(AppStrings.timingHeading), findsOneWidget);
      expect(find.text(AppStrings.timingAsap), findsOneWidget);
      expect(find.text(AppStrings.timingLaterToday), findsOneWidget);
      expect(find.text(AppStrings.timingSchedule), findsOneWidget);

      // Deliver to
      expect(find.text(AppStrings.labelDeliverTo), findsOneWidget);
      expect(find.text(AppStrings.myEstateAddress), findsOneWidget);

      // Notes (optional)
      expect(find.text(AppStrings.labelNotesOptional), findsOneWidget);
      expect(find.text(AppStrings.hintGroceriesNotes), findsOneWidget);

      // Submit button
      expect(find.text(AppStrings.actionRequestGroceries), findsOneWidget);
    });

    testWidgets('Submitting with empty items displays error message',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GroceriesScreen(repository: testRepo),
        ),
      );

      await tester.ensureVisible(find.text(AppStrings.actionRequestGroceries));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.actionRequestGroceries));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.errorItemsRequired), findsOneWidget);
      expect(testRepo.getRequests(), isEmpty);
    });

    testWidgets('Can select timing options: ASAP, LATER TODAY, SCHEDULE',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GroceriesScreen(repository: testRepo),
        ),
      );

      // Default is ASAP
      // Select LATER TODAY
      await tester.ensureVisible(find.text(AppStrings.timingLaterToday));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.timingLaterToday));
      await tester.pumpAndSettle();

      // Schedule pickers should not be shown yet
      expect(find.text('Select Date'), findsNothing);

      // Select SCHEDULE
      await tester.ensureVisible(find.text(AppStrings.timingSchedule));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.timingSchedule));
      await tester.pumpAndSettle();

      // Schedule pickers should now appear
      expect(find.text('Select Date'), findsOneWidget);
      expect(find.text('Select Time'), findsOneWidget);
    });

    testWidgets('SCHEDULE without choosing date/time displays error when submitting',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GroceriesScreen(repository: testRepo),
        ),
      );

      // Enter valid items
      await tester.enterText(
        find.widgetWithText(TextField, AppStrings.hintGroceriesItems),
        'Bread, Eggs, Butter, Jam',
      );
      await tester.pumpAndSettle();

      // Select SCHEDULE
      await tester.ensureVisible(find.text(AppStrings.timingSchedule));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.timingSchedule));
      await tester.pumpAndSettle();

      // Tap submit without setting date/time
      await tester.ensureVisible(find.text(AppStrings.actionRequestGroceries));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.actionRequestGroceries));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.errorScheduledRequired), findsOneWidget);
      expect(testRepo.getRequests(), isEmpty);
    });

    testWidgets('Valid submission saves request to repo and navigates to requested screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GroceriesScreen(repository: testRepo),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      // Enter items
      await tester.enterText(
        find.widgetWithText(TextField, AppStrings.hintGroceriesItems),
        'Fresh Milk, Sliced Bread, Brown Eggs',
      );
      await tester.pumpAndSettle();

      // Enter optional notes
      await tester.ensureVisible(find.widgetWithText(TextField, AppStrings.hintGroceriesNotes));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, AppStrings.hintGroceriesNotes),
        'Whole milk preferred.',
      );
      await tester.pumpAndSettle();

      // Tap submit
      await tester.ensureVisible(find.text(AppStrings.actionRequestGroceries));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.actionRequestGroceries));
      await tester.pumpAndSettle();

      // Verify request in repository
      final requests = testRepo.getRequests();
      expect(requests.length, 1);
      expect(requests.first.items, 'Fresh Milk, Sliced Bread, Brown Eggs');
      expect(requests.first.notes, 'Whole milk preferred.');
      expect(requests.first.timing, GroceryTiming.asSoonAsPossible);
      expect(requests.first.status, GroceryRequestStatus.requested);

      // Verify transition to GroceriesRequestedScreen
      expect(find.byType(GroceriesRequestedScreen), findsOneWidget);
      expect(find.text(AppStrings.requestReceivedTitle), findsOneWidget);
      expect(find.text(AppStrings.groceriesRequestReceivedSubtitle), findsOneWidget);
      expect(find.text('Fresh Milk, Sliced Bread, Brown Eggs'), findsOneWidget);
      expect(find.text(AppStrings.timingAsap), findsOneWidget);
      expect(find.text(AppStrings.myEstateAddress), findsOneWidget);
      expect(find.text('Whole milk preferred.'), findsOneWidget);
    });
  });

  group('SmartQ Estates - Phase 6C GroceriesRequestedScreen Tests', () {
    testWidgets('Displays all request details and notes when provided',
        (WidgetTester tester) async {
      final request = GroceryRequest.create(
        items: 'Avocados, Spinach, Greek Yogurt',
        timing: GroceryTiming.laterToday,
        notes: 'Ring bell upon arrival.',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: GroceriesRequestedScreen(request: request),
        ),
      );

      // Header & subtitle
      expect(find.text(AppStrings.requestReceivedTitle), findsOneWidget);
      expect(find.text(AppStrings.groceriesRequestReceivedSubtitle), findsOneWidget);

      // What you asked for
      expect(find.text(AppStrings.labelWhatYouAskedFor), findsOneWidget);
      expect(find.text('Avocados, Spinach, Greek Yogurt'), findsOneWidget);

      // When
      expect(find.text(AppStrings.labelWhen), findsOneWidget);
      expect(find.text(AppStrings.timingLaterToday), findsOneWidget);

      // Deliver to
      expect(find.text(AppStrings.labelDeliverTo), findsOneWidget);
      expect(find.text(AppStrings.myEstateAddress), findsOneWidget);

      // Notes
      expect(find.text(AppStrings.labelNotes), findsOneWidget);
      expect(find.text('Ring bell upon arrival.'), findsOneWidget);

      // Done button
      expect(find.text(AppStrings.doneAction), findsOneWidget);
    });

    testWidgets('Does not display notes section when notes are null or empty',
        (WidgetTester tester) async {
      final request = GroceryRequest.create(
        items: 'Orange Juice 1L',
        timing: GroceryTiming.asSoonAsPossible,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: GroceriesRequestedScreen(request: request),
        ),
      );

      expect(find.text(AppStrings.labelWhatYouAskedFor), findsOneWidget);
      expect(find.text(AppStrings.labelNotes), findsNothing);
    });

    testWidgets('DONE button returns to Services Home',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRouter.services),
                child: const Text('GO TO SERVICES'),
              ),
            ),
          ),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      // Open ServicesHomeScreen with named route
      await tester.tap(find.text('GO TO SERVICES'));
      await tester.pumpAndSettle();
      expect(find.byType(ServicesHomeScreen), findsOneWidget);

      // Navigate to GroceriesScreen
      await tester.ensureVisible(find.text(AppStrings.groceriesTitle));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.groceriesTitle));
      await tester.pumpAndSettle();

      expect(find.byType(GroceriesScreen), findsOneWidget);

      // Enter items
      await tester.enterText(
        find.widgetWithText(TextField, AppStrings.hintGroceriesItems),
        'Apples and Pears',
      );
      await tester.pumpAndSettle();

      // Submit
      await tester.ensureVisible(find.text(AppStrings.actionRequestGroceries));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.actionRequestGroceries));
      await tester.pumpAndSettle();

      expect(find.byType(GroceriesRequestedScreen), findsOneWidget);

      // Tap DONE
      await tester.ensureVisible(find.text(AppStrings.doneAction));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.doneAction));
      await tester.pumpAndSettle();

      // Returns to ServicesHomeScreen
      expect(find.byType(GroceriesRequestedScreen), findsNothing);
      expect(find.byType(GroceriesScreen), findsNothing);
      expect(find.byType(ServicesHomeScreen), findsOneWidget);
    });
  });

  group('SmartQ Estates - Phase 6D GasRequest Model Tests', () {
    test('GasRequest.create initializes defaults and fields', () {
      final req = GasRequest.create(
        cylinderSize: '12.5 KG',
        timing: GasTiming.asSoonAsPossible,
      );

      expect(req.id.startsWith('GAS-'), isTrue);
      expect(req.cylinderSize, '12.5 KG');
      expect(req.isCustom, isFalse);
      expect(req.timing, GasTiming.asSoonAsPossible);
      expect(req.scheduledFor, isNull);
      expect(req.deliveryLocation, 'estateAddress');
      expect(req.notes, isNull);
      expect(req.status, GasRequestStatus.requested);
      expect(req.createdAt, isNotNull);
    });

    test('GasRequest supports custom cylinder size, scheduled timing and optional notes', () {
      final scheduledTime = DateTime.now().add(const Duration(days: 1));
      final req = GasRequest.create(
        cylinderSize: '2 x 12.5 KG',
        isCustom: true,
        timing: GasTiming.scheduled,
        scheduledFor: scheduledTime,
        notes: 'Handle cylinders carefully',
      );

      expect(req.cylinderSize, '2 x 12.5 KG');
      expect(req.isCustom, isTrue);
      expect(req.timing, GasTiming.scheduled);
      expect(req.scheduledFor, scheduledTime);
      expect(req.notes, 'Handle cylinders carefully');
      expect(req.status, GasRequestStatus.requested);
    });

    test('GasTiming enum has expected values', () {
      expect(GasTiming.values, containsAll([
        GasTiming.asSoonAsPossible,
        GasTiming.laterToday,
        GasTiming.scheduled,
      ]));
    });

    test('GasRequestStatus enum has expected values', () {
      expect(GasRequestStatus.values, containsAll([
        GasRequestStatus.requested,
        GasRequestStatus.assigned,
        GasRequestStatus.refilling,
        GasRequestStatus.outForDelivery,
        GasRequestStatus.delivered,
        GasRequestStatus.cancelled,
      ]));
    });
  });

  group('SmartQ Estates - Phase 6D GasRepository Tests', () {
    late LocalGasRepository repo;

    setUp(() {
      repo = LocalGasRepository.testInstance();
    });

    test('createRequest stores and returns request', () {
      final req = GasRequest.create(
        cylinderSize: '6 KG',
        timing: GasTiming.asSoonAsPossible,
      );

      final created = repo.createRequest(req);
      expect(created.id, req.id);
      expect(repo.getRequests().length, 1);
      expect(repo.getRequests().first.id, req.id);
    });

    test('getRequests returns requests sorted by createdAt descending', () {
      final first = GasRequest.create(
        cylinderSize: '5 KG',
        timing: GasTiming.laterToday,
        createdAt: DateTime(2026, 1, 1, 10, 0),
      );
      final second = GasRequest.create(
        cylinderSize: '12.5 KG',
        timing: GasTiming.asSoonAsPossible,
        createdAt: DateTime(2026, 1, 1, 11, 0),
      );

      repo.createRequest(first);
      repo.createRequest(second);

      final list = repo.getRequests();
      expect(list.length, 2);
      expect(list[0].id, second.id);
      expect(list[1].id, first.id);
    });

    test('getRequestById returns matching request or null', () {
      final req = GasRequest.create(
        cylinderSize: '10 KG',
        timing: GasTiming.asSoonAsPossible,
      );
      repo.createRequest(req);

      expect(repo.getRequestById(req.id)?.cylinderSize, '10 KG');
      expect(repo.getRequestById('NON-EXISTENT'), isNull);
    });

    test('clear removes all requests', () {
      repo.createRequest(GasRequest.create(
        cylinderSize: '3 KG',
        timing: GasTiming.laterToday,
      ));
      expect(repo.getRequests().length, 1);

      repo.clear();
      expect(repo.getRequests(), isEmpty);
    });
  });

  group('SmartQ Estates - Phase 6D GasScreen Widget Tests', () {
    late LocalGasRepository testRepo;

    setUp(() {
      testRepo = LocalGasRepository.testInstance();
    });

    testWidgets('GasScreen renders header, subtitle, question, cylinder sizes, and inputs',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GasScreen(repository: testRepo),
        ),
      );

      // Header & Subtitle
      expect(find.text(AppStrings.gasTitle), findsOneWidget);
      expect(find.text(AppStrings.gasHeaderSubtitle), findsOneWidget);

      // Question section
      expect(find.text(AppStrings.gasQuestion), findsOneWidget);
      expect(find.text(AppStrings.gasQuestionSubtitle), findsOneWidget);

      // Cylinder sizes
      expect(find.text(AppStrings.labelCylinderSize), findsOneWidget);
      expect(find.text('3 KG'), findsOneWidget);
      expect(find.text('5 KG'), findsOneWidget);
      expect(find.text('6 KG'), findsOneWidget);
      expect(find.text('10 KG'), findsOneWidget);
      expect(find.text('12.5 KG'), findsOneWidget);
      expect(find.text('CUSTOM'), findsOneWidget);

      // Timing options
      expect(find.text(AppStrings.timingHeading), findsOneWidget);
      expect(find.text(AppStrings.timingAsap), findsOneWidget);
      expect(find.text(AppStrings.timingLaterToday), findsOneWidget);
      expect(find.text(AppStrings.timingSchedule), findsOneWidget);

      // Deliver to
      expect(find.text(AppStrings.labelDeliverTo), findsOneWidget);
      expect(find.text(AppStrings.myEstateAddress), findsOneWidget);

      // Notes (optional)
      expect(find.text(AppStrings.labelNotesOptional), findsOneWidget);
      expect(find.text(AppStrings.hintGasNotes), findsOneWidget);

      // Submit button
      expect(find.text(AppStrings.actionRequestGas), findsOneWidget);
    });

    testWidgets('Selecting cylinder size updates selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GasScreen(repository: testRepo),
        ),
      );

      // Default is 12.5 KG, tap 6 KG
      await tester.tap(find.text('6 KG'));
      await tester.pumpAndSettle();

      // Custom field should not be present
      expect(find.text(AppStrings.labelCustomQuantity), findsNothing);
    });

    testWidgets('Selecting CUSTOM reveals custom quantity field and validates required',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GasScreen(repository: testRepo),
        ),
      );

      // Tap CUSTOM
      await tester.ensureVisible(find.text('CUSTOM'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CUSTOM'));
      await tester.pumpAndSettle();

      // Custom input field should appear
      expect(find.text(AppStrings.labelCustomQuantity), findsOneWidget);
      expect(find.text(AppStrings.hintCustomGasQuantity), findsOneWidget);

      // Tap submit with empty custom field
      await tester.ensureVisible(find.text(AppStrings.actionRequestGas));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.actionRequestGas));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.errorGasQuantityRequired), findsOneWidget);
      expect(testRepo.getRequests(), isEmpty);
    });

    testWidgets('Can select timing options: ASAP, LATER TODAY, SCHEDULE',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GasScreen(repository: testRepo),
        ),
      );

      // Select LATER TODAY
      await tester.ensureVisible(find.text(AppStrings.timingLaterToday));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.timingLaterToday));
      await tester.pumpAndSettle();

      expect(find.text('Select Date'), findsNothing);

      // Select SCHEDULE
      await tester.ensureVisible(find.text(AppStrings.timingSchedule));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.timingSchedule));
      await tester.pumpAndSettle();

      expect(find.text('Select Date'), findsOneWidget);
      expect(find.text('Select Time'), findsOneWidget);
    });

    testWidgets('SCHEDULE without choosing date/time displays error when submitting',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GasScreen(repository: testRepo),
        ),
      );

      // Select SCHEDULE
      await tester.ensureVisible(find.text(AppStrings.timingSchedule));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.timingSchedule));
      await tester.pumpAndSettle();

      // Tap submit without setting date/time
      await tester.ensureVisible(find.text(AppStrings.actionRequestGas));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.actionRequestGas));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.errorScheduledRequired), findsOneWidget);
      expect(testRepo.getRequests(), isEmpty);
    });

    testWidgets('Valid submission saves request to repo and navigates to requested screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GasScreen(repository: testRepo),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      // Select 12.5 KG (default)
      // Enter optional notes
      await tester.ensureVisible(find.widgetWithText(TextField, AppStrings.hintGasNotes));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, AppStrings.hintGasNotes),
        'Cylinder is by the back door.',
      );
      await tester.pumpAndSettle();

      // Tap submit
      await tester.ensureVisible(find.text(AppStrings.actionRequestGas));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.actionRequestGas));
      await tester.pumpAndSettle();

      // Verify request in repository
      final requests = testRepo.getRequests();
      expect(requests.length, 1);
      expect(requests.first.cylinderSize, '12.5 KG');
      expect(requests.first.isCustom, isFalse);
      expect(requests.first.notes, 'Cylinder is by the back door.');
      expect(requests.first.timing, GasTiming.asSoonAsPossible);
      expect(requests.first.status, GasRequestStatus.requested);

      // Verify transition to GasRequestedScreen
      expect(find.byType(GasRequestedScreen), findsOneWidget);
      expect(find.text(AppStrings.requestReceivedTitle), findsOneWidget);
      expect(find.text(AppStrings.gasRequestReceivedSubtitle), findsOneWidget);
      expect(find.text('12.5 KG'), findsOneWidget);
      expect(find.text(AppStrings.timingAsap), findsOneWidget);
      expect(find.text(AppStrings.myEstateAddress), findsOneWidget);
      expect(find.text('Cylinder is by the back door.'), findsOneWidget);
    });
  });

  group('SmartQ Estates - Phase 6D GasRequestedScreen Tests', () {
    testWidgets('Displays all request details and notes when provided',
        (WidgetTester tester) async {
      final request = GasRequest.create(
        cylinderSize: '2 x 12.5 KG',
        isCustom: true,
        timing: GasTiming.laterToday,
        notes: 'Please call security before entering.',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: GasRequestedScreen(request: request),
        ),
      );

      // Header & subtitle
      expect(find.text(AppStrings.requestReceivedTitle), findsOneWidget);
      expect(find.text(AppStrings.gasRequestReceivedSubtitle), findsOneWidget);

      // Quantity
      expect(find.text(AppStrings.labelQuantityRequested), findsOneWidget);
      expect(find.text('2 x 12.5 KG'), findsOneWidget);

      // When
      expect(find.text(AppStrings.labelWhen), findsOneWidget);
      expect(find.text(AppStrings.timingLaterToday), findsOneWidget);

      // Deliver to
      expect(find.text(AppStrings.labelDeliverTo), findsOneWidget);
      expect(find.text(AppStrings.myEstateAddress), findsOneWidget);

      // Notes
      expect(find.text(AppStrings.labelNotes), findsOneWidget);
      expect(find.text('Please call security before entering.'), findsOneWidget);

      // Done button
      expect(find.text(AppStrings.doneAction), findsOneWidget);
    });

    testWidgets('Does not display notes section when notes are null or empty',
        (WidgetTester tester) async {
      final request = GasRequest.create(
        cylinderSize: '6 KG',
        timing: GasTiming.asSoonAsPossible,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: GasRequestedScreen(request: request),
        ),
      );

      expect(find.text(AppStrings.labelQuantityRequested), findsOneWidget);
      expect(find.text(AppStrings.labelNotes), findsNothing);
    });

    testWidgets('DONE button returns to Services Home',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRouter.services),
                child: const Text('GO TO SERVICES'),
              ),
            ),
          ),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      // Open ServicesHomeScreen with named route
      await tester.tap(find.text('GO TO SERVICES'));
      await tester.pumpAndSettle();
      expect(find.byType(ServicesHomeScreen), findsOneWidget);

      // Navigate to GasScreen
      await tester.ensureVisible(find.text(AppStrings.gasTitle));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.gasTitle));
      await tester.pumpAndSettle();

      expect(find.byType(GasScreen), findsOneWidget);

      // Submit
      await tester.ensureVisible(find.text(AppStrings.actionRequestGas));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.actionRequestGas));
      await tester.pumpAndSettle();

      expect(find.byType(GasRequestedScreen), findsOneWidget);

      // Tap DONE
      await tester.ensureVisible(find.text(AppStrings.doneAction));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.doneAction));
      await tester.pumpAndSettle();

      // Returns to ServicesHomeScreen
      expect(find.byType(GasRequestedScreen), findsNothing);
      expect(find.byType(GasScreen), findsNothing);
      expect(find.byType(ServicesHomeScreen), findsOneWidget);
    });
  });

  group('SmartQ Estates - Phase 6E PetrolRequest Model Tests', () {
    test('PetrolRequest.create initializes defaults and fields', () {
      final req = PetrolRequest.create(
        quantity: '20 L',
        timing: PetrolTiming.asSoonAsPossible,
      );

      expect(req.id.startsWith('PETROL-'), isTrue);
      expect(req.quantity, '20 L');
      expect(req.isCustom, isFalse);
      expect(req.vehicle, isNull);
      expect(req.timing, PetrolTiming.asSoonAsPossible);
      expect(req.scheduledFor, isNull);
      expect(req.deliveryLocation, 'estateAddress');
      expect(req.notes, isNull);
      expect(req.status, PetrolRequestStatus.requested);
      expect(req.createdAt, isNotNull);
    });

    test('PetrolRequest supports custom quantity, vehicle, scheduled timing and optional notes', () {
      final scheduledTime = DateTime.now().add(const Duration(days: 1));
      final req = PetrolRequest.create(
        quantity: '55 L',
        isCustom: true,
        vehicle: 'Black Toyota Camry',
        timing: PetrolTiming.scheduled,
        scheduledFor: scheduledTime,
        notes: 'Leave with security if not home',
      );

      expect(req.quantity, '55 L');
      expect(req.isCustom, isTrue);
      expect(req.vehicle, 'Black Toyota Camry');
      expect(req.timing, PetrolTiming.scheduled);
      expect(req.scheduledFor, scheduledTime);
      expect(req.notes, 'Leave with security if not home');
      expect(req.status, PetrolRequestStatus.requested);
    });

    test('PetrolTiming enum has expected values', () {
      expect(PetrolTiming.values, containsAll([
        PetrolTiming.asSoonAsPossible,
        PetrolTiming.laterToday,
        PetrolTiming.scheduled,
      ]));
    });

    test('PetrolRequestStatus enum has expected values', () {
      expect(PetrolRequestStatus.values, containsAll([
        PetrolRequestStatus.requested,
        PetrolRequestStatus.assigned,
        PetrolRequestStatus.refuelling,
        PetrolRequestStatus.outForDelivery,
        PetrolRequestStatus.delivered,
        PetrolRequestStatus.cancelled,
      ]));
    });
  });

  group('SmartQ Estates - Phase 6E PetrolRepository Tests', () {
    late LocalPetrolRepository repo;

    setUp(() {
      repo = LocalPetrolRepository.testInstance();
    });

    test('createRequest stores and returns request', () {
      final req = PetrolRequest.create(
        quantity: '10 L',
        timing: PetrolTiming.asSoonAsPossible,
      );

      final created = repo.createRequest(req);
      expect(created.id, req.id);
      expect(repo.getRequests().length, 1);
      expect(repo.getRequests().first.id, req.id);
    });

    test('getRequests returns requests sorted by createdAt descending', () {
      final first = PetrolRequest.create(
        quantity: '5 L',
        timing: PetrolTiming.laterToday,
        createdAt: DateTime(2026, 1, 1, 10, 0),
      );
      final second = PetrolRequest.create(
        quantity: '30 L',
        timing: PetrolTiming.asSoonAsPossible,
        createdAt: DateTime(2026, 1, 1, 11, 0),
      );

      repo.createRequest(first);
      repo.createRequest(second);

      final list = repo.getRequests();
      expect(list.length, 2);
      expect(list[0].id, second.id);
      expect(list[1].id, first.id);
    });

    test('getRequestById returns matching request or null', () {
      final req = PetrolRequest.create(
        quantity: '40 L',
        timing: PetrolTiming.asSoonAsPossible,
      );
      repo.createRequest(req);

      expect(repo.getRequestById(req.id)?.quantity, '40 L');
      expect(repo.getRequestById('NON-EXISTENT'), isNull);
    });

    test('clear removes all requests', () {
      repo.createRequest(PetrolRequest.create(
        quantity: '5 L',
        timing: PetrolTiming.laterToday,
      ));
      expect(repo.getRequests().length, 1);

      repo.clear();
      expect(repo.getRequests(), isEmpty);
    });
  });

  group('SmartQ Estates - Phase 6E PetrolScreen Widget Tests', () {
    late LocalPetrolRepository testRepo;

    setUp(() {
      testRepo = LocalPetrolRepository.testInstance();
    });

    testWidgets('PetrolScreen renders header, subtitle, question, fuel quantities, vehicle field, and inputs',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PetrolScreen(repository: testRepo),
        ),
      );

      // Header & Subtitle
      expect(find.text(AppStrings.petrolTitle), findsOneWidget);
      expect(find.text(AppStrings.petrolHeaderSubtitle), findsOneWidget);

      // Question section
      expect(find.text(AppStrings.petrolQuestion), findsOneWidget);
      expect(find.text(AppStrings.petrolQuestionSubtitle), findsOneWidget);

      // Fuel quantities
      expect(find.text(AppStrings.labelFuelQuantity), findsOneWidget);
      expect(find.text('5 L'), findsOneWidget);
      expect(find.text('10 L'), findsOneWidget);
      expect(find.text('20 L'), findsOneWidget);
      expect(find.text('30 L'), findsOneWidget);
      expect(find.text('40 L'), findsOneWidget);
      expect(find.text('CUSTOM'), findsOneWidget);

      // Vehicle (optional)
      expect(find.text(AppStrings.labelVehicleOptional), findsOneWidget);
      expect(find.text(AppStrings.hintVehicle), findsOneWidget);

      // Timing options
      expect(find.text(AppStrings.timingHeading), findsOneWidget);
      expect(find.text(AppStrings.timingAsap), findsOneWidget);
      expect(find.text(AppStrings.timingLaterToday), findsOneWidget);
      expect(find.text(AppStrings.timingSchedule), findsOneWidget);

      // Deliver to
      expect(find.text(AppStrings.labelDeliverTo), findsOneWidget);
      expect(find.text(AppStrings.myEstateAddress), findsOneWidget);

      // Notes (optional)
      expect(find.text(AppStrings.labelNotesOptional), findsOneWidget);
      expect(find.text(AppStrings.hintPetrolNotes), findsOneWidget);

      // Submit button
      expect(find.text(AppStrings.actionRequestPetrol), findsOneWidget);
    });

    testWidgets('Selecting fuel quantity updates selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PetrolScreen(repository: testRepo),
        ),
      );

      // Default is 20 L, tap 10 L
      await tester.tap(find.text('10 L'));
      await tester.pumpAndSettle();

      // Custom field should not be present
      expect(find.text(AppStrings.labelCustomLiters), findsNothing);
    });

    testWidgets('Selecting CUSTOM reveals custom quantity field and validates required',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PetrolScreen(repository: testRepo),
        ),
      );

      // Tap CUSTOM
      await tester.ensureVisible(find.text('CUSTOM'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CUSTOM'));
      await tester.pumpAndSettle();

      // Custom input field should appear
      expect(find.text(AppStrings.labelCustomLiters), findsOneWidget);
      expect(find.text(AppStrings.hintCustomPetrolQuantity), findsOneWidget);

      // Tap submit with empty custom field
      await tester.ensureVisible(find.text(AppStrings.actionRequestPetrol));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.actionRequestPetrol));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.errorPetrolQuantityRequired), findsOneWidget);
      expect(testRepo.getRequests(), isEmpty);
    });

    testWidgets('Can select timing options: ASAP, LATER TODAY, SCHEDULE',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PetrolScreen(repository: testRepo),
        ),
      );

      // Select LATER TODAY
      await tester.ensureVisible(find.text(AppStrings.timingLaterToday));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.timingLaterToday));
      await tester.pumpAndSettle();

      expect(find.text('Select Date'), findsNothing);

      // Select SCHEDULE
      await tester.ensureVisible(find.text(AppStrings.timingSchedule));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.timingSchedule));
      await tester.pumpAndSettle();

      expect(find.text('Select Date'), findsOneWidget);
      expect(find.text('Select Time'), findsOneWidget);
    });

    testWidgets('SCHEDULE without choosing date/time displays error when submitting',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PetrolScreen(repository: testRepo),
        ),
      );

      // Select SCHEDULE
      await tester.ensureVisible(find.text(AppStrings.timingSchedule));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.timingSchedule));
      await tester.pumpAndSettle();

      // Tap submit without setting date/time
      await tester.ensureVisible(find.text(AppStrings.actionRequestPetrol));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.actionRequestPetrol));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.errorScheduledRequired), findsOneWidget);
      expect(testRepo.getRequests(), isEmpty);
    });

    testWidgets('Valid submission with vehicle and notes saves request to repo and navigates to requested screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PetrolScreen(repository: testRepo),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      // Enter optional vehicle
      await tester.ensureVisible(find.widgetWithText(TextField, AppStrings.hintVehicle));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, AppStrings.hintVehicle),
        'Black Toyota Camry',
      );
      await tester.pumpAndSettle();

      // Enter optional notes
      await tester.ensureVisible(find.widgetWithText(TextField, AppStrings.hintPetrolNotes));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, AppStrings.hintPetrolNotes),
        'Please call when arriving at the gate.',
      );
      await tester.pumpAndSettle();

      // Tap submit (default 20 L, ASAP)
      await tester.ensureVisible(find.text(AppStrings.actionRequestPetrol));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.actionRequestPetrol));
      await tester.pumpAndSettle();

      // Verify request in repository
      final requests = testRepo.getRequests();
      expect(requests.length, 1);
      expect(requests.first.quantity, '20 L');
      expect(requests.first.isCustom, isFalse);
      expect(requests.first.vehicle, 'Black Toyota Camry');
      expect(requests.first.notes, 'Please call when arriving at the gate.');
      expect(requests.first.timing, PetrolTiming.asSoonAsPossible);
      expect(requests.first.status, PetrolRequestStatus.requested);

      // Verify transition to PetrolRequestedScreen
      expect(find.byType(PetrolRequestedScreen), findsOneWidget);
      expect(find.text(AppStrings.requestReceivedTitle), findsOneWidget);
      expect(find.text(AppStrings.petrolRequestReceivedSubtitle), findsOneWidget);
      expect(find.text('20 L'), findsOneWidget);
      expect(find.text(AppStrings.labelVehicle), findsOneWidget);
      expect(find.text('Black Toyota Camry'), findsOneWidget);
      expect(find.text(AppStrings.timingAsap), findsOneWidget);
      expect(find.text(AppStrings.myEstateAddress), findsOneWidget);
      expect(find.text('Please call when arriving at the gate.'), findsOneWidget);
    });
  });

  group('SmartQ Estates - Phase 6E PetrolRequestedScreen Tests', () {
    testWidgets('Displays all request details including vehicle and notes when provided',
        (WidgetTester tester) async {
      final request = PetrolRequest.create(
        quantity: '40 L',
        vehicle: 'Silver Honda Accord',
        timing: PetrolTiming.laterToday,
        notes: 'Leave petrol near the generator house.',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: PetrolRequestedScreen(request: request),
        ),
      );

      // Header & subtitle
      expect(find.text(AppStrings.requestReceivedTitle), findsOneWidget);
      expect(find.text(AppStrings.petrolRequestReceivedSubtitle), findsOneWidget);

      // Quantity
      expect(find.text(AppStrings.labelQuantityRequested), findsOneWidget);
      expect(find.text('40 L'), findsOneWidget);

      // Vehicle
      expect(find.text(AppStrings.labelVehicle), findsOneWidget);
      expect(find.text('Silver Honda Accord'), findsOneWidget);

      // When
      expect(find.text(AppStrings.labelWhen), findsOneWidget);
      expect(find.text(AppStrings.timingLaterToday), findsOneWidget);

      // Deliver to
      expect(find.text(AppStrings.labelDeliverTo), findsOneWidget);
      expect(find.text(AppStrings.myEstateAddress), findsOneWidget);

      // Notes
      expect(find.text(AppStrings.labelNotes), findsOneWidget);
      expect(find.text('Leave petrol near the generator house.'), findsOneWidget);

      // Done button
      expect(find.text(AppStrings.doneAction), findsOneWidget);
    });

    testWidgets('Does not display vehicle or notes sections when they are null or empty',
        (WidgetTester tester) async {
      final request = PetrolRequest.create(
        quantity: '10 L',
        timing: PetrolTiming.asSoonAsPossible,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: PetrolRequestedScreen(request: request),
        ),
      );

      expect(find.text(AppStrings.labelQuantityRequested), findsOneWidget);
      expect(find.text('10 L'), findsOneWidget);
      expect(find.text(AppStrings.labelVehicle), findsNothing);
      expect(find.text(AppStrings.labelNotes), findsNothing);
    });

    testWidgets('DONE button returns to Services Home',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRouter.services),
                child: const Text('GO TO SERVICES'),
              ),
            ),
          ),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      // Open ServicesHomeScreen with named route
      await tester.tap(find.text('GO TO SERVICES'));
      await tester.pumpAndSettle();
      expect(find.byType(ServicesHomeScreen), findsOneWidget);

      // Navigate to PetrolScreen
      await tester.ensureVisible(find.text(AppStrings.petrolTitle));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.petrolTitle));
      await tester.pumpAndSettle();

      expect(find.byType(PetrolScreen), findsOneWidget);

      // Submit
      await tester.ensureVisible(find.text(AppStrings.actionRequestPetrol));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.actionRequestPetrol));
      await tester.pumpAndSettle();

      expect(find.byType(PetrolRequestedScreen), findsOneWidget);

      // Tap DONE
      await tester.ensureVisible(find.text(AppStrings.doneAction));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.doneAction));
      await tester.pumpAndSettle();

      // Returns to ServicesHomeScreen
      expect(find.byType(PetrolRequestedScreen), findsNothing);
      expect(find.byType(PetrolScreen), findsNothing);
      expect(find.byType(ServicesHomeScreen), findsOneWidget);
    });
  });

  group('SmartQ Estates - Phase 6F GeneratorRequest Model Tests', () {
    test('GeneratorRequest.create initializes defaults and fields', () {
      final req = GeneratorRequest.create(
        serviceDescription: 'Needs oil change and spark plug check',
        timing: GeneratorTiming.asSoonAsPossible,
      );

      expect(req.id.startsWith('GEN-'), isTrue);
      expect(req.serviceDescription, 'Needs oil change and spark plug check');
      expect(req.generatorModel, isNull);
      expect(req.timing, GeneratorTiming.asSoonAsPossible);
      expect(req.scheduledFor, isNull);
      expect(req.deliveryLocation, 'estateAddress');
      expect(req.notes, isNull);
      expect(req.status, GeneratorRequestStatus.requested);
      expect(req.createdAt, isNotNull);
    });

    test('GeneratorRequest supports optional generatorModel, scheduled timing and optional notes', () {
      final scheduledTime = DateTime.now().add(const Duration(days: 1));
      final req = GeneratorRequest.create(
        serviceDescription: 'Generator not picking load and producing heavy smoke',
        generatorModel: '20kVA Mikano Soundproof Diesel',
        timing: GeneratorTiming.scheduled,
        scheduledFor: scheduledTime,
        notes: 'Leave pass with security gate',
      );

      expect(req.serviceDescription, 'Generator not picking load and producing heavy smoke');
      expect(req.generatorModel, '20kVA Mikano Soundproof Diesel');
      expect(req.timing, GeneratorTiming.scheduled);
      expect(req.scheduledFor, scheduledTime);
      expect(req.notes, 'Leave pass with security gate');
      expect(req.status, GeneratorRequestStatus.requested);
    });

    test('GeneratorTiming enum has expected values', () {
      expect(GeneratorTiming.values, containsAll([
        GeneratorTiming.asSoonAsPossible,
        GeneratorTiming.laterToday,
        GeneratorTiming.scheduled,
      ]));
    });

    test('GeneratorRequestStatus enum has expected values', () {
      expect(GeneratorRequestStatus.values, containsAll([
        GeneratorRequestStatus.requested,
        GeneratorRequestStatus.assigned,
        GeneratorRequestStatus.inProgress,
        GeneratorRequestStatus.completed,
        GeneratorRequestStatus.cancelled,
      ]));
    });
  });

  group('SmartQ Estates - Phase 6F GeneratorRepository Tests', () {
    late LocalGeneratorRepository repo;

    setUp(() {
      repo = LocalGeneratorRepository.testInstance();
    });

    test('createRequest stores and returns request', () {
      final req = GeneratorRequest.create(
        serviceDescription: 'Needs routine servicing',
        timing: GeneratorTiming.asSoonAsPossible,
      );

      final created = repo.createRequest(req);
      expect(created.id, req.id);
      expect(repo.getRequests().length, 1);
      expect(repo.getRequests().first.id, req.id);
    });

    test('getRequests returns requests sorted by createdAt descending', () {
      final first = GeneratorRequest.create(
        serviceDescription: 'Oil and filter change',
        timing: GeneratorTiming.laterToday,
        createdAt: DateTime(2026, 1, 1, 10, 0),
      );
      final second = GeneratorRequest.create(
        serviceDescription: 'Won’t start',
        timing: GeneratorTiming.asSoonAsPossible,
        createdAt: DateTime(2026, 1, 1, 11, 0),
      );

      repo.createRequest(first);
      repo.createRequest(second);

      final list = repo.getRequests();
      expect(list.length, 2);
      expect(list[0].id, second.id);
      expect(list[1].id, first.id);
    });

    test('getRequestById returns matching request or null', () {
      final req = GeneratorRequest.create(
        serviceDescription: 'General inspection before weekend',
        timing: GeneratorTiming.asSoonAsPossible,
      );
      repo.createRequest(req);

      expect(repo.getRequestById(req.id)?.serviceDescription,
          'General inspection before weekend');
      expect(repo.getRequestById('NON-EXISTENT'), isNull);
    });

    test('clear removes all requests', () {
      repo.createRequest(GeneratorRequest.create(
        serviceDescription: 'Needs servicing',
        timing: GeneratorTiming.laterToday,
      ));
      expect(repo.getRequests().length, 1);

      repo.clear();
      expect(repo.getRequests(), isEmpty);
    });
  });

  group('SmartQ Estates - Phase 6F GeneratorScreen Widget Tests', () {
    late LocalGeneratorRepository testRepo;

    setUp(() {
      testRepo = LocalGeneratorRepository.testInstance();
    });

    testWidgets('GeneratorScreen renders header, subtitle, question, service description, generator field, and inputs',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GeneratorScreen(repository: testRepo),
        ),
      );

      // Header & Subtitle
      expect(find.text(AppStrings.generatorTitle), findsOneWidget);
      expect(find.text(AppStrings.generatorHeaderSubtitle), findsOneWidget);

      // Question section
      expect(find.text(AppStrings.generatorQuestion), findsOneWidget);
      expect(find.text(AppStrings.generatorQuestionSubtitle), findsOneWidget);

      // Service description field
      expect(find.text(AppStrings.labelServiceDescription), findsOneWidget);
      expect(find.text(AppStrings.hintGeneratorServiceDescription), findsOneWidget);

      // Generator (optional)
      expect(find.text(AppStrings.labelGeneratorModelOptional), findsOneWidget);
      expect(find.text(AppStrings.hintGeneratorModel), findsOneWidget);

      // Timing options
      expect(find.text(AppStrings.timingHeading), findsOneWidget);
      expect(find.text(AppStrings.timingAsap), findsOneWidget);
      expect(find.text(AppStrings.timingLaterToday), findsOneWidget);
      expect(find.text(AppStrings.timingSchedule), findsOneWidget);

      // Deliver to
      expect(find.text(AppStrings.labelDeliverTo), findsOneWidget);
      expect(find.text(AppStrings.myEstateAddress), findsOneWidget);

      // Notes (optional)
      expect(find.text(AppStrings.labelNotesOptional), findsOneWidget);
      expect(find.text(AppStrings.hintGeneratorNotes), findsOneWidget);

      // Submit button
      expect(find.text(AppStrings.actionRequestGenerator), findsOneWidget);
    });

    testWidgets('Submitting with empty service description displays validation error',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GeneratorScreen(repository: testRepo),
        ),
      );

      // Tap submit with empty service description
      await tester.ensureVisible(find.text(AppStrings.actionRequestGenerator));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.actionRequestGenerator));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.errorGeneratorDescriptionRequired), findsOneWidget);
      expect(testRepo.getRequests(), isEmpty);
    });

    testWidgets('Can select timing options: ASAP, LATER TODAY, SCHEDULE',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GeneratorScreen(repository: testRepo),
        ),
      );

      // Select LATER TODAY
      await tester.ensureVisible(find.text(AppStrings.timingLaterToday));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.timingLaterToday));
      await tester.pumpAndSettle();

      expect(find.text('Select Date'), findsNothing);

      // Select SCHEDULE
      await tester.ensureVisible(find.text(AppStrings.timingSchedule));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.timingSchedule));
      await tester.pumpAndSettle();

      expect(find.text('Select Date'), findsOneWidget);
      expect(find.text('Select Time'), findsOneWidget);
    });

    testWidgets('SCHEDULE without choosing date/time displays error when submitting',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GeneratorScreen(repository: testRepo),
        ),
      );

      // Enter service description first
      await tester.enterText(
        find.widgetWithText(TextField, AppStrings.hintGeneratorServiceDescription),
        'Generator won’t start',
      );
      await tester.pumpAndSettle();

      // Select SCHEDULE
      await tester.ensureVisible(find.text(AppStrings.timingSchedule));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.timingSchedule));
      await tester.pumpAndSettle();

      // Tap submit without setting date/time
      await tester.ensureVisible(find.text(AppStrings.actionRequestGenerator));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.actionRequestGenerator));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.errorScheduledRequired), findsOneWidget);
      expect(testRepo.getRequests(), isEmpty);
    });

    testWidgets('Valid submission with generator and notes saves request to repo and navigates to requested screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GeneratorScreen(repository: testRepo),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      // Enter service description
      await tester.enterText(
        find.widgetWithText(TextField, AppStrings.hintGeneratorServiceDescription),
        'Generator produces black smoke and won’t carry AC load.',
      );
      await tester.pumpAndSettle();

      // Enter optional generator model
      await tester.ensureVisible(find.widgetWithText(TextField, AppStrings.hintGeneratorModel));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, AppStrings.hintGeneratorModel),
        '5kVA Firman',
      );
      await tester.pumpAndSettle();

      // Enter optional notes
      await tester.ensureVisible(find.widgetWithText(TextField, AppStrings.hintGeneratorNotes));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, AppStrings.hintGeneratorNotes),
        'Technician should call before entering.',
      );
      await tester.pumpAndSettle();

      // Tap submit (ASAP)
      await tester.ensureVisible(find.text(AppStrings.actionRequestGenerator));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.actionRequestGenerator));
      await tester.pumpAndSettle();

      // Verify request in repository
      final requests = testRepo.getRequests();
      expect(requests.length, 1);
      expect(requests.first.serviceDescription,
          'Generator produces black smoke and won’t carry AC load.');
      expect(requests.first.generatorModel, '5kVA Firman');
      expect(requests.first.notes, 'Technician should call before entering.');
      expect(requests.first.timing, GeneratorTiming.asSoonAsPossible);
      expect(requests.first.status, GeneratorRequestStatus.requested);

      // Verify transition to GeneratorRequestedScreen
      expect(find.byType(GeneratorRequestedScreen), findsOneWidget);
      expect(find.text(AppStrings.requestReceivedTitle), findsOneWidget);
      expect(find.text(AppStrings.generatorRequestReceivedSubtitle), findsOneWidget);
      expect(find.text('Generator produces black smoke and won’t carry AC load.'),
          findsOneWidget);
      expect(find.text(AppStrings.labelGeneratorSummary), findsOneWidget);
      expect(find.text('5kVA Firman'), findsOneWidget);
      expect(find.text(AppStrings.timingAsap), findsOneWidget);
      expect(find.text(AppStrings.myEstateAddress), findsOneWidget);
      expect(find.text('Technician should call before entering.'), findsOneWidget);
    });
  });

  group('SmartQ Estates - Phase 6F GeneratorRequestedScreen Tests', () {
    testWidgets('Displays all request details including generator and notes when provided',
        (WidgetTester tester) async {
      final request = GeneratorRequest.create(
        serviceDescription: 'Oil change and filter replacement needed',
        generatorModel: '10kVA Lutian',
        timing: GeneratorTiming.laterToday,
        notes: 'Oil has been bought already.',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: GeneratorRequestedScreen(request: request),
        ),
      );

      // Header & subtitle
      expect(find.text(AppStrings.requestReceivedTitle), findsOneWidget);
      expect(find.text(AppStrings.generatorRequestReceivedSubtitle), findsOneWidget);

      // Service description
      expect(find.text(AppStrings.labelServiceDescriptionSummary), findsOneWidget);
      expect(find.text('Oil change and filter replacement needed'), findsOneWidget);

      // Generator
      expect(find.text(AppStrings.labelGeneratorSummary), findsOneWidget);
      expect(find.text('10kVA Lutian'), findsOneWidget);

      // When
      expect(find.text(AppStrings.labelWhen), findsOneWidget);
      expect(find.text(AppStrings.timingLaterToday), findsOneWidget);

      // Deliver to
      expect(find.text(AppStrings.labelDeliverTo), findsOneWidget);
      expect(find.text(AppStrings.myEstateAddress), findsOneWidget);

      // Notes
      expect(find.text(AppStrings.labelNotes), findsOneWidget);
      expect(find.text('Oil has been bought already.'), findsOneWidget);

      // Done button
      expect(find.text(AppStrings.doneAction), findsOneWidget);
    });

    testWidgets('Does not display generator or notes sections when they are null or empty',
        (WidgetTester tester) async {
      final request = GeneratorRequest.create(
        serviceDescription: 'General inspection before weekend',
        timing: GeneratorTiming.asSoonAsPossible,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: GeneratorRequestedScreen(request: request),
        ),
      );

      expect(find.text(AppStrings.labelServiceDescriptionSummary), findsOneWidget);
      expect(find.text('General inspection before weekend'), findsOneWidget);
      expect(find.text(AppStrings.labelGeneratorSummary), findsNothing);
      expect(find.text(AppStrings.labelNotes), findsNothing);
    });

    testWidgets('DONE button returns to Services Home',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRouter.services),
                child: const Text('GO TO SERVICES'),
              ),
            ),
          ),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      // Open ServicesHomeScreen with named route
      await tester.tap(find.text('GO TO SERVICES'));
      await tester.pumpAndSettle();
      expect(find.byType(ServicesHomeScreen), findsOneWidget);

      // Navigate to GeneratorScreen
      await tester.ensureVisible(find.text(AppStrings.generatorTitle));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.generatorTitle));
      await tester.pumpAndSettle();

      expect(find.byType(GeneratorScreen), findsOneWidget);

      // Fill required description
      await tester.enterText(
        find.widgetWithText(TextField, AppStrings.hintGeneratorServiceDescription),
        'Need regular servicing',
      );
      await tester.pumpAndSettle();

      // Submit
      await tester.ensureVisible(find.text(AppStrings.actionRequestGenerator));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.actionRequestGenerator));
      await tester.pumpAndSettle();

      expect(find.byType(GeneratorRequestedScreen), findsOneWidget);

      // Tap DONE
      await tester.ensureVisible(find.text(AppStrings.doneAction));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.doneAction));
      await tester.pumpAndSettle();

      // Returns to ServicesHomeScreen
      expect(find.byType(GeneratorRequestedScreen), findsNothing);
      expect(find.byType(GeneratorScreen), findsNothing);
      expect(find.byType(ServicesHomeScreen), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // SMARTQ ESTATES — PHASE 6G TESTS (MAINTENANCE REQUEST)
  // ═══════════════════════════════════════════════════════════════════════════

  group('SmartQ Estates - Phase 6G MaintenanceRequest Model Tests', () {
    test('create with required fields generates defaults properly', () {
      final now = DateTime(2026, 9, 21, 10, 0);
      final request = MaintenanceRequest.create(
        description: '  Kitchen faucet is leaking continuously  ',
        timing: MaintenanceTiming.asSoonAsPossible,
        createdAt: now,
      );

      expect(request.id, startsWith('MAINT-'));
      expect(request.description, 'Kitchen faucet is leaking continuously');
      expect(request.category, isNull);
      expect(request.timing, MaintenanceTiming.asSoonAsPossible);
      expect(request.scheduledFor, isNull);
      expect(request.deliveryLocation, 'estateAddress');
      expect(request.notes, isNull);
      expect(request.status, MaintenanceRequestStatus.requested);
      expect(request.createdAt, now);
    });

    test('create with optional category, notes, and scheduled date preserves trimmed values', () {
      final scheduled = DateTime(2026, 9, 22, 14, 30);
      final request = MaintenanceRequest.create(
        description: 'Main breaker trips when AC is turned on',
        category: '  ELECTRICAL  ',
        timing: MaintenanceTiming.scheduled,
        scheduledFor: scheduled,
        notes: '  Gate key with security guard.  ',
      );

      expect(request.category, 'ELECTRICAL');
      expect(request.timing, MaintenanceTiming.scheduled);
      expect(request.scheduledFor, scheduled);
      expect(request.notes, 'Gate key with security guard.');
      expect(request.status, MaintenanceRequestStatus.requested);
    });

    test('create with empty or whitespace category and notes sets them to null', () {
      final request = MaintenanceRequest.create(
        description: 'Door lock is stuck',
        category: '   ',
        timing: MaintenanceTiming.laterToday,
        notes: '   ',
      );

      expect(request.category, isNull);
      expect(request.notes, isNull);
    });

    test('MaintenanceTiming display names are correct', () {
      expect(MaintenanceTiming.asSoonAsPossible.displayName, 'AS SOON AS POSSIBLE');
      expect(MaintenanceTiming.laterToday.displayName, 'LATER TODAY');
      expect(MaintenanceTiming.scheduled.displayName, 'SCHEDULED');
    });

    test('MaintenanceRequestStatus display names are correct', () {
      expect(MaintenanceRequestStatus.requested.displayName, 'REQUESTED');
      expect(MaintenanceRequestStatus.assigned.displayName, 'ASSIGNED');
      expect(MaintenanceRequestStatus.inProgress.displayName, 'IN PROGRESS');
      expect(MaintenanceRequestStatus.completed.displayName, 'COMPLETED');
      expect(MaintenanceRequestStatus.cancelled.displayName, 'CANCELLED');
    });
  });

  group('SmartQ Estates - Phase 6G MaintenanceRepository Tests', () {
    late LocalMaintenanceRepository repo;

    setUp(() {
      repo = LocalMaintenanceRepository.testInstance();
    });

    test('createRequest stores and returns the request', () {
      final req = MaintenanceRequest.create(
        description: 'Broken window latch',
        timing: MaintenanceTiming.asSoonAsPossible,
      );

      final returned = repo.createRequest(req);
      expect(returned.id, req.id);
      expect(repo.getRequests().length, 1);
      expect(repo.getRequests().first.id, req.id);
    });

    test('getRequests returns requests sorted by createdAt descending', () {
      final t1 = DateTime(2026, 9, 21, 8, 0);
      final t2 = DateTime(2026, 9, 21, 9, 0);
      final t3 = DateTime(2026, 9, 21, 10, 0);

      repo.createRequest(MaintenanceRequest.create(
        description: 'First req',
        timing: MaintenanceTiming.asSoonAsPossible,
        createdAt: t1,
      ));
      repo.createRequest(MaintenanceRequest.create(
        description: 'Third req',
        timing: MaintenanceTiming.asSoonAsPossible,
        createdAt: t3,
      ));
      repo.createRequest(MaintenanceRequest.create(
        description: 'Second req',
        timing: MaintenanceTiming.asSoonAsPossible,
        createdAt: t2,
      ));

      final requests = repo.getRequests();
      expect(requests.length, 3);
      expect(requests[0].description, 'Third req');
      expect(requests[1].description, 'Second req');
      expect(requests[2].description, 'First req');
    });

    test('getRequestById finds request or returns null', () {
      final req = MaintenanceRequest.create(
        description: 'AC not cooling',
        category: 'AC / COOLING',
        timing: MaintenanceTiming.asSoonAsPossible,
      );
      repo.createRequest(req);

      expect(repo.getRequestById(req.id)?.id, req.id);
      expect(repo.getRequestById('NON_EXISTENT'), isNull);
    });

    test('clear empties the repository', () {
      repo.createRequest(MaintenanceRequest.create(
        description: 'Test req',
        timing: MaintenanceTiming.asSoonAsPossible,
      ));
      expect(repo.getRequests().length, 1);

      repo.clear();
      expect(repo.getRequests(), isEmpty);
    });

    test('testInstance returns isolated instances', () {
      final repo1 = LocalMaintenanceRepository.testInstance();
      final repo2 = LocalMaintenanceRepository.testInstance();

      repo1.createRequest(MaintenanceRequest.create(
        description: 'Only in repo1',
        timing: MaintenanceTiming.asSoonAsPossible,
      ));

      expect(repo1.getRequests().length, 1);
      expect(repo2.getRequests().length, 0);
    });
  });

  group('SmartQ Estates - Phase 6G MaintenanceScreen Widget Tests', () {
    late LocalMaintenanceRepository testRepo;

    setUp(() {
      testRepo = LocalMaintenanceRepository.testInstance();
    });

    testWidgets('Renders all initial UI elements properly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MaintenanceScreen(repository: testRepo),
        ),
      );

      // Header
      expect(find.text(AppStrings.maintenanceTitle), findsOneWidget);
      expect(find.text(AppStrings.maintenanceHeaderSubtitle), findsOneWidget);

      // Main question & subtitle
      expect(find.text(AppStrings.maintenanceQuestion), findsOneWidget);
      expect(find.text(AppStrings.maintenanceQuestionSubtitle), findsOneWidget);

      // Description section & text field
      expect(find.text(AppStrings.labelMaintenanceDescription), findsOneWidget);
      expect(
        find.widgetWithText(TextField, AppStrings.hintMaintenanceDescription),
        findsOneWidget,
      );

      // Category chips
      expect(find.text(AppStrings.labelCategoryOptional), findsOneWidget);
      expect(find.text('PLUMBING'), findsOneWidget);
      expect(find.text('ELECTRICAL'), findsOneWidget);
      expect(find.text('CARPENTRY'), findsOneWidget);
      expect(find.text('AC / COOLING'), findsOneWidget);
      expect(find.text('PAINTING'), findsOneWidget);
      expect(find.text('OTHER'), findsOneWidget);

      // Timing options
      expect(find.text(AppStrings.timingHeading), findsOneWidget);
      expect(find.text(AppStrings.timingAsap), findsOneWidget);
      expect(find.text(AppStrings.timingLaterToday), findsOneWidget);
      expect(find.text(AppStrings.timingSchedule), findsOneWidget);

      // Deliver/service location
      expect(find.text(AppStrings.labelDeliverTo), findsOneWidget);
      expect(find.text(AppStrings.myEstateAddress), findsOneWidget);

      // Notes (optional)
      expect(find.text(AppStrings.labelNotesOptional), findsOneWidget);
      expect(
        find.widgetWithText(TextField, AppStrings.hintMaintenanceNotes),
        findsOneWidget,
      );

      // Submit button
      expect(find.text(AppStrings.actionRequestMaintenance), findsOneWidget);
    });

    testWidgets('Shows error when submitting with empty description',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MaintenanceScreen(repository: testRepo),
        ),
      );

      await tester.ensureVisible(find.text(AppStrings.actionRequestMaintenance));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.actionRequestMaintenance));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.errorMaintenanceDescriptionRequired), findsOneWidget);
      expect(testRepo.getRequests(), isEmpty);
    });

    testWidgets('Clears description error when user enters text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MaintenanceScreen(repository: testRepo),
        ),
      );

      // Trigger error
      await tester.ensureVisible(find.text(AppStrings.actionRequestMaintenance));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.actionRequestMaintenance));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.errorMaintenanceDescriptionRequired), findsOneWidget);

      // Type text
      final descField =
          find.widgetWithText(TextField, AppStrings.hintMaintenanceDescription);
      await tester.enterText(descField, 'Kitchen pipe is leaking');
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.errorMaintenanceDescriptionRequired), findsNothing);
    });

    testWidgets('Selecting category chip toggles selection on and off',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MaintenanceScreen(repository: testRepo),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      // Tap PLUMBING
      await tester.ensureVisible(find.text('PLUMBING'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('PLUMBING'));
      await tester.pumpAndSettle();

      // Enter description and submit
      await tester.enterText(
        find.widgetWithText(TextField, AppStrings.hintMaintenanceDescription),
        'Leaking pipe under sink',
      );
      await tester.pumpAndSettle();

      // Tap submit
      await tester.ensureVisible(find.text(AppStrings.actionRequestMaintenance));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.actionRequestMaintenance));
      await tester.pumpAndSettle();

      expect(testRepo.getRequests().first.category, 'PLUMBING');
    });

    testWidgets('Tapping the same category chip unselects it',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MaintenanceScreen(repository: testRepo),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      // Tap ELECTRICAL then tap it again to unselect
      await tester.ensureVisible(find.text('ELECTRICAL'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ELECTRICAL'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ELECTRICAL'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, AppStrings.hintMaintenanceDescription),
        'Issue with wall socket',
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text(AppStrings.actionRequestMaintenance));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.actionRequestMaintenance));
      await tester.pumpAndSettle();

      expect(testRepo.getRequests().first.category, isNull);
    });

    testWidgets('Timing selection switches between ASAP, LATER TODAY, and SCHEDULE',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MaintenanceScreen(repository: testRepo),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      // Initially ASAP is selected, no date/time pickers
      expect(find.text('Select Date'), findsNothing);

      // Tap LATER TODAY
      await tester.ensureVisible(find.text(AppStrings.timingLaterToday));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.timingLaterToday));
      await tester.pumpAndSettle();
      expect(find.text('Select Date'), findsNothing);

      // Tap SCHEDULE
      await tester.ensureVisible(find.text(AppStrings.timingSchedule));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.timingSchedule));
      await tester.pumpAndSettle();
      expect(find.text('Select Date'), findsOneWidget);
      expect(find.text('Select Time'), findsOneWidget);
    });

    testWidgets('Selecting SCHEDULE without picking date/time shows error upon submission',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MaintenanceScreen(repository: testRepo),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextField, AppStrings.hintMaintenanceDescription),
        'Bedroom door hinges loose',
      );
      await tester.pumpAndSettle();

      // Switch to SCHEDULE
      await tester.ensureVisible(find.text(AppStrings.timingSchedule));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.timingSchedule));
      await tester.pumpAndSettle();

      // Try to submit without picking date and time
      await tester.ensureVisible(find.text(AppStrings.actionRequestMaintenance));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.actionRequestMaintenance));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.errorScheduledRequired), findsOneWidget);
      expect(testRepo.getRequests(), isEmpty);
    });

    testWidgets('Valid submission saves to repository and navigates to MaintenanceRequestedScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MaintenanceScreen(repository: testRepo),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      // Fill in description
      await tester.enterText(
        find.widgetWithText(TextField, AppStrings.hintMaintenanceDescription),
        'Repaint master bedroom ceiling and fix water stain',
      );
      await tester.pumpAndSettle();

      // Select category
      await tester.ensureVisible(find.text('PAINTING'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('PAINTING'));
      await tester.pumpAndSettle();

      // Select LATER TODAY
      await tester.ensureVisible(find.text(AppStrings.timingLaterToday));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.timingLaterToday));
      await tester.pumpAndSettle();

      // Enter notes
      await tester.ensureVisible(find.widgetWithText(TextField, AppStrings.hintMaintenanceNotes));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, AppStrings.hintMaintenanceNotes),
        'Paint cans are already inside the store room.',
      );
      await tester.pumpAndSettle();

      // Submit
      await tester.ensureVisible(find.text(AppStrings.actionRequestMaintenance));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.actionRequestMaintenance));
      await tester.pumpAndSettle();

      // Verify stored in repo
      expect(testRepo.getRequests().length, 1);
      final stored = testRepo.getRequests().first;
      expect(stored.description, 'Repaint master bedroom ceiling and fix water stain');
      expect(stored.category, 'PAINTING');
      expect(stored.timing, MaintenanceTiming.laterToday);
      expect(stored.notes, 'Paint cans are already inside the store room.');

      // Navigated to confirmation screen
      expect(find.byType(MaintenanceRequestedScreen), findsOneWidget);
    });
  });

  group('SmartQ Estates - Phase 6G MaintenanceRequestedScreen Tests', () {
    testWidgets('Displays all request details when fully populated',
        (WidgetTester tester) async {
      final scheduled = DateTime(2026, 9, 25, 15, 30);
      final request = MaintenanceRequest.create(
        description: 'AC compressor is making loud rattling noise',
        category: 'AC / COOLING',
        timing: MaintenanceTiming.scheduled,
        scheduledFor: scheduled,
        notes: 'Security knows about the technician visit.',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MaintenanceRequestedScreen(request: request),
        ),
      );

      // Header
      expect(find.text(AppStrings.requestReceivedTitle), findsOneWidget);
      expect(find.text(AppStrings.maintenanceRequestReceivedSubtitle), findsOneWidget);

      // Problem description
      expect(find.text(AppStrings.labelDescriptionSummary), findsOneWidget);
      expect(find.text('AC compressor is making loud rattling noise'), findsOneWidget);

      // Category
      expect(find.text(AppStrings.labelCategorySummary), findsOneWidget);
      expect(find.text('AC / COOLING'), findsOneWidget);

      // Timing
      expect(find.text(AppStrings.labelWhen), findsOneWidget);
      expect(find.text('25 Sep, 2026 · 3:30 PM'), findsOneWidget);

      // Deliver to
      expect(find.text(AppStrings.labelDeliverTo), findsOneWidget);
      expect(find.text(AppStrings.myEstateAddress), findsOneWidget);

      // Notes
      expect(find.text(AppStrings.labelNotes), findsOneWidget);
      expect(find.text('Security knows about the technician visit.'), findsOneWidget);

      // Done button
      expect(find.text(AppStrings.doneAction), findsOneWidget);
    });

    testWidgets('Does not display category or notes sections when they are null or empty',
        (WidgetTester tester) async {
      final request = MaintenanceRequest.create(
        description: 'Fixing balcony door handle',
        timing: MaintenanceTiming.asSoonAsPossible,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MaintenanceRequestedScreen(request: request),
        ),
      );

      expect(find.text(AppStrings.labelDescriptionSummary), findsOneWidget);
      expect(find.text('Fixing balcony door handle'), findsOneWidget);
      expect(find.text(AppStrings.labelCategorySummary), findsNothing);
      expect(find.text(AppStrings.labelNotes), findsNothing);
    });

    testWidgets('DONE button returns to Services Home',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRouter.services),
                child: const Text('GO TO SERVICES'),
              ),
            ),
          ),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      // Open ServicesHomeScreen with named route
      await tester.tap(find.text('GO TO SERVICES'));
      await tester.pumpAndSettle();
      expect(find.byType(ServicesHomeScreen), findsOneWidget);

      // Navigate to MaintenanceScreen
      await tester.ensureVisible(find.text(AppStrings.maintenanceTitle));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.maintenanceTitle));
      await tester.pumpAndSettle();

      expect(find.byType(MaintenanceScreen), findsOneWidget);

      // Fill required description
      await tester.enterText(
        find.widgetWithText(TextField, AppStrings.hintMaintenanceDescription),
        'Fix water heater switch',
      );
      await tester.pumpAndSettle();

      // Submit
      await tester.ensureVisible(find.text(AppStrings.actionRequestMaintenance));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.actionRequestMaintenance));
      await tester.pumpAndSettle();

      expect(find.byType(MaintenanceRequestedScreen), findsOneWidget);

      // Tap DONE
      await tester.ensureVisible(find.text(AppStrings.doneAction));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.doneAction));
      await tester.pumpAndSettle();

      // Returns to ServicesHomeScreen
      expect(find.byType(MaintenanceRequestedScreen), findsNothing);
      expect(find.byType(MaintenanceScreen), findsNothing);
      expect(find.byType(ServicesHomeScreen), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // SMARTQ ESTATES — PHASE 7 TESTS (SERVICE LIFECYCLE, TRACKING & OPERATIONS)
  // ═══════════════════════════════════════════════════════════════════════════

  group('SmartQ Estates - Phase 7 ServiceRequestItem & Model copyWith Tests', () {
    test('MarketRunRequest copyWith and ServiceRequestItem getters', () {
      final req = MarketRunRequest.create(
        items: 'Tomatoes and pepper',
        timing: MarketRunTiming.asSoonAsPossible,
      );

      expect(req.serviceTitle, 'MARKET RUN');
      expect(req.serviceType, 'marketRun');
      expect(req.summaryText, 'Tomatoes and pepper');
      expect(req.timingDisplay, 'AS SOON AS POSSIBLE');
      expect(req.statusDisplayName, 'REQUESTED');
      expect(req.operationalPhase, ServiceOperationalPhase.requested);
      expect(req.isActive, isTrue);
      expect(req.canBeCancelled, isTrue);

      final updated = req.copyWith(status: MarketRunStatus.shopping);
      expect(updated.status, MarketRunStatus.shopping);
      expect(updated.statusDisplayName, 'SHOPPING');
      expect(updated.operationalPhase, ServiceOperationalPhase.inProgress);
      expect(updated.isActive, isTrue);
      expect(updated.canBeCancelled, isFalse);

      final delivered = updated.copyWith(status: MarketRunStatus.delivered);
      expect(delivered.operationalPhase, ServiceOperationalPhase.completed);
      expect(delivered.isActive, isFalse);
    });

    test('GroceryRequest copyWith and ServiceRequestItem getters', () {
      final req = GroceryRequest.create(
        items: 'Milk, bread, eggs',
        timing: GroceryTiming.laterToday,
      );

      expect(req.serviceTitle, 'GROCERIES');
      expect(req.serviceType, 'groceries');
      expect(req.operationalPhase, ServiceOperationalPhase.requested);
      expect(req.isActive, isTrue);
      expect(req.canBeCancelled, isTrue);

      final outForDelivery = req.copyWith(status: GroceryRequestStatus.outForDelivery);
      expect(outForDelivery.operationalPhase, ServiceOperationalPhase.inProgress);
      expect(outForDelivery.canBeCancelled, isFalse);

      final cancelled = req.copyWith(status: GroceryRequestStatus.cancelled);
      expect(cancelled.operationalPhase, ServiceOperationalPhase.cancelled);
      expect(cancelled.isActive, isFalse);
    });

    test('GasRequest copyWith and ServiceRequestItem getters', () {
      final req = GasRequest.create(
        cylinderSize: '12.5 KG',
        timing: GasTiming.asSoonAsPossible,
      );

      expect(req.serviceTitle, 'COOKING GAS');
      expect(req.serviceType, 'gas');
      expect(req.summaryText, '12.5 KG');

      final refilling = req.copyWith(status: GasRequestStatus.refilling);
      expect(refilling.operationalPhase, ServiceOperationalPhase.inProgress);
    });

    test('PetrolRequest copyWith and ServiceRequestItem getters', () {
      final req = PetrolRequest.create(
        quantity: '25 L',
        vehicle: 'Toyota Corolla',
        timing: PetrolTiming.asSoonAsPossible,
      );

      expect(req.serviceTitle, 'PETROL');
      expect(req.serviceType, 'petrol');
      expect(req.summaryText, '25 L · Toyota Corolla');

      final refuelling = req.copyWith(status: PetrolRequestStatus.refuelling);
      expect(refuelling.operationalPhase, ServiceOperationalPhase.inProgress);
    });

    test('GeneratorRequest copyWith and ServiceRequestItem getters', () {
      final req = GeneratorRequest.create(
        serviceDescription: 'Check battery connection',
        generatorModel: 'Firman 5kVA',
        timing: GeneratorTiming.asSoonAsPossible,
      );

      expect(req.serviceTitle, 'GENERATOR');
      expect(req.serviceType, 'generator');
      expect(req.summaryText, 'Firman 5kVA · Check battery connection');

      final inProgress = req.copyWith(status: GeneratorRequestStatus.inProgress);
      expect(inProgress.operationalPhase, ServiceOperationalPhase.inProgress);
      expect(inProgress.canBeCancelled, isFalse);

      final completed = req.copyWith(status: GeneratorRequestStatus.completed);
      expect(completed.operationalPhase, ServiceOperationalPhase.completed);
      expect(completed.isActive, isFalse);
    });

    test('MaintenanceRequest copyWith and ServiceRequestItem getters', () {
      final req = MaintenanceRequest.create(
        description: 'Sink leak in kitchen',
        category: 'PLUMBING',
        timing: MaintenanceTiming.asSoonAsPossible,
      );

      expect(req.serviceTitle, 'MAINTENANCE');
      expect(req.serviceType, 'maintenance');
      expect(req.summaryText, 'PLUMBING · Sink leak in kitchen');

      final inProgress = req.copyWith(status: MaintenanceRequestStatus.inProgress);
      expect(inProgress.operationalPhase, ServiceOperationalPhase.inProgress);
    });
  });

  group('SmartQ Estates - Phase 7 Repository Lifecycle Tests', () {
    test('updateStatus and cancelRequest on MarketRunRepository', () {
      final repo = LocalMarketRunRepository.testInstance();
      final req = repo.createRequest(MarketRunRequest.create(
        items: 'Bananas',
        timing: MarketRunTiming.asSoonAsPossible,
      ));

      final updated = repo.updateStatus(req.id, MarketRunStatus.shopping);
      expect(updated?.status, MarketRunStatus.shopping);
      expect(repo.getRequestById(req.id)?.status, MarketRunStatus.shopping);

      // Cannot cancel once in shopping
      expect(repo.cancelRequest(req.id), isFalse);

      // Create another in requested status and cancel it
      final req2 = repo.createRequest(MarketRunRequest.create(
        items: 'Oranges',
        timing: MarketRunTiming.asSoonAsPossible,
      ));
      expect(repo.cancelRequest(req2.id), isTrue);
      expect(repo.getRequestById(req2.id)?.status, MarketRunStatus.cancelled);
    });

    test('updateStatus and cancelRequest on MaintenanceRepository', () {
      final repo = LocalMaintenanceRepository.testInstance();
      final req = repo.createRequest(MaintenanceRequest.create(
        description: 'Broken latch',
        timing: MaintenanceTiming.asSoonAsPossible,
      ));

      expect(repo.cancelRequest(req.id), isTrue);
      expect(repo.getRequestById(req.id)?.status, MaintenanceRequestStatus.cancelled);
    });
  });

  group('SmartQ Estates - Phase 7 ServiceCoordinator Tests', () {
    late LocalMarketRunRepository marketRunRepo;
    late LocalGroceryRepository groceryRepo;
    late LocalGasRepository gasRepo;
    late LocalPetrolRepository petrolRepo;
    late LocalGeneratorRepository generatorRepo;
    late LocalMaintenanceRepository maintenanceRepo;
    late ServiceCoordinator coordinator;

    setUp(() {
      marketRunRepo = LocalMarketRunRepository.testInstance();
      groceryRepo = LocalGroceryRepository.testInstance();
      gasRepo = LocalGasRepository.testInstance();
      petrolRepo = LocalPetrolRepository.testInstance();
      generatorRepo = LocalGeneratorRepository.testInstance();
      maintenanceRepo = LocalMaintenanceRepository.testInstance();

      coordinator = ServiceCoordinator(
        marketRunRepo: marketRunRepo,
        groceryRepo: groceryRepo,
        gasRepo: gasRepo,
        petrolRepo: petrolRepo,
        generatorRepo: generatorRepo,
        maintenanceRepo: maintenanceRepo,
      );
    });

    test('getAllRequests aggregates all domains and sorts descending', () {
      final t1 = DateTime(2026, 9, 21, 8, 0);
      final t2 = DateTime(2026, 9, 21, 9, 0);
      final t3 = DateTime(2026, 9, 21, 10, 0);

      marketRunRepo.createRequest(MarketRunRequest.create(
        items: 'Items 1',
        timing: MarketRunTiming.asSoonAsPossible,
        createdAt: t1,
      ));
      gasRepo.createRequest(GasRequest.create(
        cylinderSize: '12.5 KG',
        timing: GasTiming.asSoonAsPossible,
        createdAt: t3,
      ));
      maintenanceRepo.createRequest(MaintenanceRequest.create(
        description: 'Repair door',
        timing: MaintenanceTiming.asSoonAsPossible,
        createdAt: t2,
      ));

      final all = coordinator.getAllRequests();
      expect(all.length, 3);
      expect(all[0].serviceTitle, 'COOKING GAS');
      expect(all[1].serviceTitle, 'MAINTENANCE');
      expect(all[2].serviceTitle, 'MARKET RUN');
    });

    test('getActiveRequests and getCompletedRequests filter correctly', () {
      marketRunRepo.createRequest(MarketRunRequest.create(
        items: 'Active market run',
        timing: MarketRunTiming.asSoonAsPossible,
      ));
      final gasReq = gasRepo.createRequest(GasRequest.create(
        cylinderSize: '12.5 KG',
        timing: GasTiming.asSoonAsPossible,
      ));
      gasRepo.updateStatus(gasReq.id, GasRequestStatus.delivered);

      expect(coordinator.getActiveRequests().length, 1);
      expect(coordinator.getActiveRequests().first.serviceTitle, 'MARKET RUN');

      expect(coordinator.getCompletedRequests().length, 1);
      expect(coordinator.getCompletedRequests().first.serviceTitle, 'COOKING GAS');
    });

    test('getRequestById finds request by ID', () {
      final req = generatorRepo.createRequest(GeneratorRequest.create(
        serviceDescription: 'Service generator',
        timing: GeneratorTiming.asSoonAsPossible,
      ));

      final found = coordinator.getRequestById(req.id);
      expect(found, isNotNull);
      expect(found!.id, req.id);
      expect(found.serviceTitle, 'GENERATOR');
    });

    test('cancelRequest cancels intake request', () {
      final req = petrolRepo.createRequest(PetrolRequest.create(
        quantity: '20 L',
        timing: PetrolTiming.asSoonAsPossible,
      ));

      expect(coordinator.cancelRequest(req.id), isTrue);
      expect(coordinator.getRequestById(req.id)?.statusDisplayName, 'CANCELLED');
    });

    test('advanceStatus moves request through lifecycle', () {
      final req = maintenanceRepo.createRequest(MaintenanceRequest.create(
        description: 'Paint wall',
        timing: MaintenanceTiming.asSoonAsPossible,
      ));

      // 1. requested -> assigned
      expect(coordinator.advanceStatus(req.id), isTrue);
      expect(coordinator.getRequestById(req.id)?.statusDisplayName, 'ASSIGNED');

      // 2. assigned -> inProgress
      expect(coordinator.advanceStatus(req.id), isTrue);
      expect(coordinator.getRequestById(req.id)?.statusDisplayName, 'IN PROGRESS');

      // 3. inProgress -> completed
      expect(coordinator.advanceStatus(req.id), isTrue);
      expect(coordinator.getRequestById(req.id)?.statusDisplayName, 'COMPLETED');

      // Cannot advance past completed
      expect(coordinator.advanceStatus(req.id), isFalse);
    });
  });

  group('SmartQ Estates - Phase 7 ServicesHomeScreen Active Banner & My Requests Tests', () {
    late ServiceCoordinator testCoordinator;

    setUp(() {
      testCoordinator = ServiceCoordinator.testInstance();
    });

    testWidgets('Does not show Active Requests card when queue is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ServicesHomeScreen(coordinator: testCoordinator),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      expect(find.text(AppStrings.activeRequestsSection), findsNothing);
      expect(find.text(AppStrings.myRequestsTitle), findsOneWidget);
    });

    testWidgets('Shows Active Requests banner when active request exists',
        (WidgetTester tester) async {
      testCoordinator.marketRunRepo.createRequest(MarketRunRequest.create(
        items: 'Apples, Bread',
        timing: MarketRunTiming.asSoonAsPossible,
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: ServicesHomeScreen(coordinator: testCoordinator),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      expect(find.text('${AppStrings.activeRequestsSection} (1)'), findsOneWidget);
      expect(find.text('MARKET RUN · REQUESTED'), findsOneWidget);
    });

    testWidgets('Tapping MY REQUESTS card navigates to MyServiceRequestsScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ServicesHomeScreen(coordinator: testCoordinator),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      await tester.ensureVisible(find.text(AppStrings.myRequestsTitle));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.myRequestsTitle));
      await tester.pumpAndSettle();

      expect(find.byType(MyServiceRequestsScreen), findsOneWidget);
    });
  });

  group('SmartQ Estates - Phase 7 MyServiceRequestsScreen Widget Tests', () {
    late ServiceCoordinator testCoordinator;

    setUp(() {
      testCoordinator = ServiceCoordinator.testInstance();
    });

    testWidgets('Renders tabs and empty state when no requests exist',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MyServiceRequestsScreen(coordinator: testCoordinator),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      expect(find.text(AppStrings.myRequestsTitle), findsOneWidget);
      expect(find.text('${AppStrings.tabActive} (0)'), findsOneWidget);
      expect(find.text('${AppStrings.tabHistory} (0)'), findsOneWidget);
      expect(find.text(AppStrings.noActiveRequests), findsOneWidget);
    });

    testWidgets('Displays active requests and switches to HISTORY tab',
        (WidgetTester tester) async {
      testCoordinator.gasRepo.createRequest(GasRequest.create(
        cylinderSize: '12.5 KG',
        timing: GasTiming.asSoonAsPossible,
      ));
      final pastReq = testCoordinator.maintenanceRepo.createRequest(
        MaintenanceRequest.create(
          description: 'Fixed kitchen tap',
          timing: MaintenanceTiming.asSoonAsPossible,
        ),
      );
      testCoordinator.maintenanceRepo.updateStatus(
        pastReq.id,
        MaintenanceRequestStatus.completed,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MyServiceRequestsScreen(coordinator: testCoordinator),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      // Active tab shows active Gas request
      expect(find.text('${AppStrings.tabActive} (1)'), findsOneWidget);
      expect(find.text('${AppStrings.tabHistory} (1)'), findsOneWidget);
      expect(find.text('COOKING GAS'), findsOneWidget);
      expect(find.text('12.5 KG'), findsOneWidget);

      // Tap HISTORY tab
      await tester.tap(find.text('${AppStrings.tabHistory} (1)'));
      await tester.pumpAndSettle();

      expect(find.text('MAINTENANCE'), findsOneWidget);
      expect(find.text('Fixed kitchen tap'), findsOneWidget);
    });

    testWidgets('Tapping a request card navigates to ServiceRequestDetailScreen',
        (WidgetTester tester) async {
      testCoordinator.petrolRepo.createRequest(PetrolRequest.create(
        quantity: '20 L',
        vehicle: 'Honda Accord',
        timing: PetrolTiming.asSoonAsPossible,
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: MyServiceRequestsScreen(coordinator: testCoordinator),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      await tester.tap(find.text('PETROL'));
      await tester.pumpAndSettle();

      expect(find.byType(ServiceRequestDetailScreen), findsOneWidget);
      expect(find.text(AppStrings.requestDetailTitle), findsOneWidget);
      expect(find.text('20 L · Honda Accord'), findsOneWidget);
    });
  });

  group('SmartQ Estates - Phase 7 ServiceRequestDetailScreen Widget Tests', () {
    late ServiceCoordinator testCoordinator;

    setUp(() {
      testCoordinator = ServiceCoordinator.testInstance();
    });

    testWidgets('Displays timeline nodes, full request details, and cancel action',
        (WidgetTester tester) async {
      final req = testCoordinator.groceryRepo.createRequest(GroceryRequest.create(
        items: 'Eggs, Bread, Butter',
        timing: GroceryTiming.asSoonAsPossible,
        notes: 'Ring the bell twice',
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: ServiceRequestDetailScreen(
            request: req,
            coordinator: testCoordinator,
          ),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      // Timeline labels & status
      expect(find.text(AppStrings.timelineStep1), findsWidgets);
      expect(find.text(AppStrings.timelineStep2), findsOneWidget);
      expect(find.text(AppStrings.timelineStep3), findsOneWidget);

      // Metadata
      expect(find.text('GROCERIES'), findsOneWidget);
      expect(find.text('Eggs, Bread, Butter'), findsOneWidget);
      expect(find.text('Ring the bell twice'), findsOneWidget);

      // Cancel button is available for requested status
      expect(find.text(AppStrings.actionCancelRequest), findsOneWidget);
    });

    testWidgets('Cancelling request via dialog updates status and shows notice',
        (WidgetTester tester) async {
      final req = testCoordinator.generatorRepo.createRequest(GeneratorRequest.create(
        serviceDescription: 'Check engine oil',
        timing: GeneratorTiming.asSoonAsPossible,
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: ServiceRequestDetailScreen(
            request: req,
            coordinator: testCoordinator,
          ),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      // Tap cancel request
      await tester.ensureVisible(find.text(AppStrings.actionCancelRequest));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.actionCancelRequest));
      await tester.pumpAndSettle();

      // Dialog appears
      expect(find.text(AppStrings.cancelDialogTitle), findsOneWidget);
      expect(find.text(AppStrings.actionConfirmCancel), findsOneWidget);

      // Confirm cancel
      await tester.tap(find.text(AppStrings.actionConfirmCancel));
      await tester.pumpAndSettle();

      // Status is now cancelled, cancel button gone, cancellation notice visible
      expect(find.text(AppStrings.requestCancelledNotice), findsOneWidget);
      expect(find.text(AppStrings.actionCancelRequest), findsNothing);
    });
  });

  group('SmartQ Estates - Phase 7 EstateOperationsScreen Widget Tests', () {
    late ServiceCoordinator testCoordinator;

    setUp(() {
      testCoordinator = ServiceCoordinator.testInstance();
    });

    testWidgets('Renders filters and advances active request status',
        (WidgetTester tester) async {
      testCoordinator.gasRepo.createRequest(GasRequest.create(
        cylinderSize: '12.5 KG',
        timing: GasTiming.asSoonAsPossible,
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: EstateOperationsScreen(coordinator: testCoordinator),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      // Header & filter chips
      expect(find.text(AppStrings.operationsDeskTitle), findsOneWidget);
      expect(find.text(AppStrings.filterAll), findsOneWidget);
      expect(find.text('COOKING GAS'), findsOneWidget);
      expect(find.text(AppStrings.actionAdvanceStatus), findsOneWidget);

      // Advance status
      await tester.tap(find.text(AppStrings.actionAdvanceStatus));
      await tester.pumpAndSettle();

      // Request is now ASSIGNED
      expect(find.text('ASSIGNED'), findsOneWidget);
      expect(find.text(AppStrings.statusUpdatedNotice), findsOneWidget);
    });

    testWidgets('Filtering by COMPLETED shows empty queue when none completed',
        (WidgetTester tester) async {
      testCoordinator.marketRunRepo.createRequest(MarketRunRequest.create(
        items: 'Fresh bread',
        timing: MarketRunTiming.asSoonAsPossible,
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: EstateOperationsScreen(coordinator: testCoordinator),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      // Tap COMPLETED filter
      await tester.tap(find.text('COMPLETED'));
      await tester.pumpAndSettle();

      expect(find.text('QUEUE IS EMPTY'), findsOneWidget);
    });
  });

  group('SmartQ Estates - Phase 7 Connected Resident ↔ Management Showcase Tests', () {
    late ServiceCoordinator testCoordinator;

    setUp(() {
      testCoordinator = ServiceCoordinator.testInstance();
    });

    testWidgets(
        'Complete end-to-end flow: Resident creates maintenance -> Management accepts -> Resident sees IN PROGRESS -> Management completes -> Resident sees COMPLETED',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // Step 1: Resident submits a Maintenance request: "Leaking pipe in my kitchen"
      final createdRequest = testCoordinator.maintenanceRepo.createRequest(
        MaintenanceRequest.create(
          description: 'Leaking pipe in my kitchen',
          timing: MaintenanceTiming.asSoonAsPossible,
          deliveryLocation: 'Unit 4B • Pinecrest Royal Estate',
        ),
      );

      expect(createdRequest.status, MaintenanceRequestStatus.requested);
      expect(createdRequest.operationalPhase, ServiceOperationalPhase.requested);
      expect(testCoordinator.getAllRequests().length, 1);

      // Step 2: Management opens ManagementRequestsScreen
      await tester.pumpWidget(
        MaterialApp(
          home: ManagementRequestsScreen(coordinator: testCoordinator),
          onGenerateRoute: (settings) {
            if (settings.name == AppRouter.managementRequestDetail) {
              final req = settings.arguments as ServiceRequestItem;
              return MaterialPageRoute(
                builder: (_) => ManagementRequestDetailScreen(
                  request: req,
                  coordinator: testCoordinator,
                ),
              );
            }
            return AppRouter.onGenerateRoute(settings);
          },
        ),
      );

      // Verify request appears with exact description and resident info
      expect(find.text('Leaking pipe in my kitchen'), findsOneWidget);
      expect(find.text('MAINTENANCE'), findsOneWidget);
      expect(find.text('John Doe • Unit 4B • Pinecrest Royal Estate'), findsOneWidget);
      expect(find.text('REQUESTED'), findsWidgets);

      // Step 3: Management taps request to open ManagementRequestDetailScreen
      await tester.tap(find.text('Leaking pipe in my kitchen'));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.managementRequestDetailTitle), findsOneWidget);
      expect(find.text(AppStrings.actionAcceptAndStart), findsOneWidget);

      // Step 4: Management taps "ACCEPT / START"
      await tester.tap(find.text(AppStrings.actionAcceptAndStart));
      await tester.pumpAndSettle();

      // Verify status transitions to IN PROGRESS and action changes to "MARK COMPLETED"
      expect(find.text(AppStrings.actionMarkCompleted), findsOneWidget);
      expect(testCoordinator.getRequestById(createdRequest.id)!.operationalPhase,
          ServiceOperationalPhase.inProgress);

      // Step 5: Resident opens MyServiceRequestsScreen to check progress
      await tester.pumpWidget(
        MaterialApp(
          key: UniqueKey(),
          home: MyServiceRequestsScreen(coordinator: testCoordinator),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );
      await tester.pumpAndSettle();

      // Active tab shows 1 request with status IN PROGRESS
      expect(find.text('${AppStrings.tabActive} (1)'), findsOneWidget);
      expect(find.text('Leaking pipe in my kitchen'), findsOneWidget);
      expect(find.text('IN PROGRESS'), findsWidgets);

      // Step 6: Management re-opens request detail to finish the job
      final inProgressReq = testCoordinator.getRequestById(createdRequest.id)!;
      await tester.pumpWidget(
        MaterialApp(
          key: UniqueKey(),
          home: ManagementRequestDetailScreen(
            request: inProgressReq,
            coordinator: testCoordinator,
          ),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );
      await tester.pumpAndSettle();

      // Step 7: Management marks the request COMPLETED
      await tester.tap(find.text(AppStrings.actionMarkCompleted));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.statusCompletedNotice), findsOneWidget);
      expect(testCoordinator.getRequestById(createdRequest.id)!.operationalPhase,
          ServiceOperationalPhase.completed);

      // Step 8: Resident checks MyServiceRequestsScreen again
      await tester.pumpWidget(
        MaterialApp(
          key: UniqueKey(),
          home: MyServiceRequestsScreen(coordinator: testCoordinator),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );
      await tester.pumpAndSettle();

      // Active tab is now 0
      expect(find.text('${AppStrings.tabActive} (0)'), findsOneWidget);
      expect(find.text('${AppStrings.tabHistory} (1)'), findsOneWidget);

      // Tap HISTORY tab
      await tester.tap(find.text('${AppStrings.tabHistory} (1)'));
      await tester.pumpAndSettle();

      // Request appears in History as COMPLETED
      expect(find.text('Leaking pipe in my kitchen'), findsOneWidget);
      expect(find.text('COMPLETED'), findsWidgets);
    });

    testWidgets('Management Requests queue displays all 6 services with filtering',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      testCoordinator.marketRunRepo.createRequest(MarketRunRequest.create(
        items: 'Tomatoes and pepper',
        timing: MarketRunTiming.asSoonAsPossible,
      ));
      testCoordinator.groceryRepo.createRequest(GroceryRequest.create(
        items: 'Milk and cereal',
        timing: GroceryTiming.asSoonAsPossible,
      ));
      testCoordinator.gasRepo.createRequest(GasRequest.create(
        cylinderSize: '12.5 KG',
        timing: GasTiming.asSoonAsPossible,
      ));
      testCoordinator.petrolRepo.createRequest(PetrolRequest.create(
        quantity: '20 L',
        timing: PetrolTiming.asSoonAsPossible,
      ));
      testCoordinator.generatorRepo.createRequest(GeneratorRequest.create(
        serviceDescription: 'Generator won\'t start',
        timing: GeneratorTiming.asSoonAsPossible,
      ));
      testCoordinator.maintenanceRepo.createRequest(MaintenanceRequest.create(
        description: 'AC leaking water',
        timing: MaintenanceTiming.asSoonAsPossible,
      ));

      expect(testCoordinator.getAllRequests().length, 6);

      await tester.pumpWidget(
        MaterialApp(
          home: ManagementRequestsScreen(coordinator: testCoordinator),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      // All 6 service titles are present
      expect(find.text('MARKET RUN'), findsOneWidget);
      expect(find.text('GROCERIES'), findsOneWidget);
      expect(find.text('COOKING GAS'), findsOneWidget);
      expect(find.text('PETROL'), findsOneWidget);
      expect(find.text('GENERATOR'), findsOneWidget);
      expect(find.text('MAINTENANCE'), findsOneWidget);

      // Filter by COMPLETED shows empty queue
      await tester.tap(find.text(AppStrings.filterCompleted));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.noManagementRequests), findsOneWidget);

      // Filter by NEW shows all 6
      await tester.tap(find.text(AppStrings.filterNew));
      await tester.pumpAndSettle();
      expect(find.text('MARKET RUN'), findsOneWidget);
    });

    testWidgets('Management Dashboard renders metrics and recent items',
        (WidgetTester tester) async {
      testCoordinator.generatorRepo.createRequest(GeneratorRequest.create(
        serviceDescription: 'Service needed',
        timing: GeneratorTiming.asSoonAsPossible,
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: ManagementHomeScreen(coordinator: testCoordinator),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      expect(find.text(AppStrings.managementDashboardTitle), findsOneWidget);
      expect(find.text(AppStrings.liveOperationsQueue), findsOneWidget);
      expect(find.text('Service needed'), findsOneWidget);
    });

    testWidgets('ManagementShellScreen switches between Dashboard, Requests, and Account tabs',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ManagementShellScreen(),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      // Tab 0: Management Dashboard
      expect(find.text(AppStrings.managementDashboardSubtitle), findsOneWidget);

      // Tap Tab 1: Requests
      await tester.tap(find.text(AppStrings.tabManagementRequests));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.managementRequestsSubtitle), findsOneWidget);

      // Tap Tab 2: Account
      await tester.tap(find.text(AppStrings.tabManagementAccount));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.managementAccountTitle), findsOneWidget);
      expect(find.text(AppStrings.prototypeRoleSwitcherTitle), findsOneWidget);
    });

    testWidgets('HomeScreen displays active requests banner when requests exist',
        (WidgetTester tester) async {
      testCoordinator.gasRepo.createRequest(GasRequest.create(
        cylinderSize: '6 KG',
        timing: GasTiming.asSoonAsPossible,
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(coordinator: testCoordinator),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      expect(find.text('ACTIVE REQUESTS (1)'), findsOneWidget);
      expect(find.text('TRACK'), findsOneWidget);
    });

    testWidgets('PrototypeRoleSwitcher switches between roles',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const Scaffold(
            body: PrototypeRoleSwitcher(currentRole: PrototypeRole.resident),
          ),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      expect(find.text(AppStrings.prototypeRoleSwitcherTitle), findsOneWidget);
      expect(find.text(AppStrings.roleResident), findsOneWidget);
      expect(find.text(AppStrings.roleManagement), findsOneWidget);
      expect(find.text(AppStrings.roleSecurity), findsOneWidget);

      // Tap Management
      await tester.tap(find.text(AppStrings.roleManagement));
      await tester.pumpAndSettle();

      // Now inside ManagementShellScreen
      expect(find.text(AppStrings.managementDashboardSubtitle), findsOneWidget);
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
