import 'package:flutter/material.dart';
import '../core/models/decoded_qr_payload.dart';
import '../core/models/estate.dart';
import '../core/models/estate_event.dart';
import '../core/models/event_pass.dart';
import '../core/models/gas_request.dart';
import '../core/models/generator_request.dart';
import '../core/models/grocery_request.dart';
import '../core/models/maintenance_request.dart';
import '../core/models/market_run_request.dart';
import '../core/models/petrol_request.dart';
import '../core/models/service_request_item.dart';
import '../core/models/visitor_pass.dart';
import '../screens/operations/estate_operations_screen.dart';
import '../screens/estate_selection/estate_selection_screen.dart';
import '../screens/main_shell/main_shell_screen.dart';
import '../screens/maintenance/maintenance_placeholder_screen.dart';
import '../screens/payments/payments_placeholder_screen.dart';
import '../screens/security/access_result_screen.dart';
import '../screens/security/decoded_result_screen.dart';
import '../screens/security/security_shell_screen.dart';
import '../screens/security/verify_access_scanner_screen.dart';
import '../screens/services/gas_screen.dart';
import '../screens/services/gas_requested_screen.dart';
import '../screens/services/generator_screen.dart';
import '../screens/services/generator_requested_screen.dart';
import '../screens/services/groceries_screen.dart';
import '../screens/services/groceries_requested_screen.dart';
import '../screens/services/maintenance_screen.dart';
import '../screens/services/maintenance_requested_screen.dart';
import '../screens/services/market_run_screen.dart';
import '../screens/services/market_run_requested_screen.dart';
import '../screens/services/my_service_requests_screen.dart';
import '../screens/services/petrol_screen.dart';
import '../screens/services/petrol_requested_screen.dart';
import '../screens/services/service_request_detail_screen.dart';
import '../screens/services/services_home_screen.dart';
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

  // Services category routes (Phase 6A, 6B, 6C, 6D, 6E, 6F & 6G)
  static const String marketRun = '/services/market-run';
  static const String marketRunRequested = '/services/market-run/requested';
  static const String groceries = '/services/groceries';
  static const String groceriesRequested = '/services/groceries/requested';
  static const String gas = '/services/gas';
  static const String gasRequested = '/services/gas/requested';
  static const String petrol = '/services/petrol';
  static const String petrolRequested = '/services/petrol/requested';
  static const String generator = '/services/generator';
  static const String generatorRequested = '/services/generator/requested';
  static const String serviceMaintenance = '/services/maintenance';
  static const String serviceMaintenanceRequested =
      '/services/maintenance/requested';

  // Phase 7 Service Request Lifecycle & Operations
  static const String myServiceRequests = '/services/my-requests';
  static const String serviceRequestDetail = '/services/request-detail';
  static const String estateOperations = '/operations/services';

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
          builder: (_) => const ServicesHomeScreen(),
          settings: settings,
        );
      case marketRun:
        return MaterialPageRoute(
          builder: (_) => const MarketRunScreen(),
          settings: settings,
        );
      case marketRunRequested:
        final request = settings.arguments as MarketRunRequest;
        return MaterialPageRoute(
          builder: (_) => MarketRunRequestedScreen(request: request),
          settings: settings,
        );
      case groceries:
        return MaterialPageRoute(
          builder: (_) => const GroceriesScreen(),
          settings: settings,
        );
      case groceriesRequested:
        final request = settings.arguments as GroceryRequest;
        return MaterialPageRoute(
          builder: (_) => GroceriesRequestedScreen(request: request),
          settings: settings,
        );
      case gas:
        return MaterialPageRoute(
          builder: (_) => const GasScreen(),
          settings: settings,
        );
      case gasRequested:
        final request = settings.arguments as GasRequest;
        return MaterialPageRoute(
          builder: (_) => GasRequestedScreen(request: request),
          settings: settings,
        );
      case petrol:
        return MaterialPageRoute(
          builder: (_) => const PetrolScreen(),
          settings: settings,
        );
      case petrolRequested:
        final request = settings.arguments as PetrolRequest;
        return MaterialPageRoute(
          builder: (_) => PetrolRequestedScreen(request: request),
          settings: settings,
        );
      case generator:
        return MaterialPageRoute(
          builder: (_) => const GeneratorScreen(),
          settings: settings,
        );
      case generatorRequested:
        final request = settings.arguments as GeneratorRequest;
        return MaterialPageRoute(
          builder: (_) => GeneratorRequestedScreen(request: request),
          settings: settings,
        );
      case serviceMaintenance:
        return MaterialPageRoute(
          builder: (_) => const MaintenanceScreen(),
          settings: settings,
        );
      case serviceMaintenanceRequested:
        final request = settings.arguments as MaintenanceRequest;
        return MaterialPageRoute(
          builder: (_) => MaintenanceRequestedScreen(request: request),
          settings: settings,
        );
      case myServiceRequests:
        return MaterialPageRoute(
          builder: (_) => const MyServiceRequestsScreen(),
          settings: settings,
        );
      case serviceRequestDetail:
        final request = settings.arguments as ServiceRequestItem;
        return MaterialPageRoute(
          builder: (_) => ServiceRequestDetailScreen(request: request),
          settings: settings,
        );
      case estateOperations:
        return MaterialPageRoute(
          builder: (_) => const EstateOperationsScreen(),
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
