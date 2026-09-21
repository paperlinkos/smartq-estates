import 'package:flutter/material.dart';
import '../core/models/decoded_qr_payload.dart';
import '../core/models/estate.dart';
import '../core/models/estate_event.dart';
import '../core/models/event_pass.dart';
import '../core/models/visitor_pass.dart';
import '../screens/estate_selection/estate_selection_screen.dart';
import '../screens/main_shell/main_shell_screen.dart';
import '../screens/maintenance/maintenance_placeholder_screen.dart';
import '../screens/payments/payments_placeholder_screen.dart';
import '../screens/security/access_result_screen.dart';
import '../screens/security/decoded_result_screen.dart';
import '../screens/security/security_shell_screen.dart';
import '../screens/security/verify_access_scanner_screen.dart';
import '../screens/services/services_placeholder_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/visitors/create_event_screen.dart';
import '../screens/visitors/event_created_screen.dart';
import '../screens/visitors/event_pass_screen.dart';
import '../screens/visitors/invite_someone_screen.dart';
import '../screens/visitors/visitor_pass_screen.dart';
import '../screens/visitors/visitors_home_screen.dart';
import '../screens/welcome/welcome_screen.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String estateSelection = '/estate-selection';
  static const String mainShell = '/main';

  // Home primary action routes
  static const String visitors = '/visitors';
  static const String services = '/services';
  static const String maintenance = '/maintenance';
  static const String payments = '/payments';

  // Visitors action routes
  static const String inviteSomeone = '/visitors/invite';
  static const String createEvent = '/visitors/create-event';
  static const String visitorPass = '/visitors/pass';
  static const String eventPass = '/visitors/event-pass';
  static const String eventCreated = '/visitors/event-created';

  // Security routes
  static const String security = '/security';
  static const String verifyAccess = '/security/verify-access';
  static const String scanResult = '/security/scan-result'; // Phase 5B (kept for test compatibility)
  static const String accessResult = '/security/access-result'; // Phase 5C

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
      case welcome:
        return PageRouteBuilder(
          pageBuilder: (_, _, _) => const WelcomeScreen(),
          transitionsBuilder: (_, animation, _, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          settings: settings,
        );
      case estateSelection:
        return MaterialPageRoute(
          builder: (_) => const EstateSelectionScreen(),
          settings: settings,
        );
      case mainShell:
        final estate = settings.arguments as Estate?;
        return MaterialPageRoute(
          builder: (_) => MainShellScreen(initialEstate: estate),
          settings: settings,
        );
      case visitors:
        return MaterialPageRoute(
          builder: (_) => const VisitorsHomeScreen(),
          settings: settings,
        );
      case inviteSomeone:
        return MaterialPageRoute(
          builder: (_) => const InviteSomeoneScreen(),
          settings: settings,
        );
      case createEvent:
        return MaterialPageRoute(
          builder: (_) => const CreateEventScreen(),
          settings: settings,
        );
      case visitorPass:
        final pass = settings.arguments as VisitorPass;
        return MaterialPageRoute(
          builder: (_) => VisitorPassScreen(pass: pass),
          settings: settings,
        );
      case eventPass:
        final pass = settings.arguments as EventPass;
        return MaterialPageRoute(
          builder: (_) => EventPassScreen(pass: pass),
          settings: settings,
        );
      case eventCreated:
        final event = settings.arguments as EstateEvent?;
        return MaterialPageRoute(
          builder: (_) => EventCreatedScreen(event: event),
          settings: settings,
        );
      case services:
        return MaterialPageRoute(
          builder: (_) => const ServicesPlaceholderScreen(),
          settings: settings,
        );
      case maintenance:
        return MaterialPageRoute(
          builder: (_) => const MaintenancePlaceholderScreen(),
          settings: settings,
        );
      case payments:
        return MaterialPageRoute(
          builder: (_) => const PaymentsPlaceholderScreen(),
          settings: settings,
        );
      case security:
        final estate = settings.arguments as Estate?;
        return MaterialPageRoute(
          builder: (_) => SecurityShellScreen(initialEstate: estate),
          settings: settings,
        );
      case verifyAccess:
        return MaterialPageRoute(
          builder: (_) => const VerifyAccessScannerScreen(),
          settings: settings,
        );
      case scanResult:
        final payload = settings.arguments as DecodedQrPayload;
        return MaterialPageRoute(
          builder: (_) => DecodedResultScreen(payload: payload),
          settings: settings,
        );
      case accessResult:
        final payload = settings.arguments as DecodedQrPayload;
        return MaterialPageRoute(
          builder: (_) => AccessResultScreen(payload: payload),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
    }
  }
}
