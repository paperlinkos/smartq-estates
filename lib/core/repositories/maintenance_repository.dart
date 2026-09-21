import '../models/maintenance_request.dart';

/// Architecture contract for managing maintenance service requests.
///
/// Designed with an interface so that [LocalMaintenanceRepository] (in-memory prototype)
/// can be replaced with a persistent network/database provider in future phases without breaking
/// client screens.
abstract class MaintenanceRepository {
  /// Stores a new [request] and returns it.
  MaintenanceRequest createRequest(MaintenanceRequest request);

  /// Returns all stored maintenance requests, sorted by createdAt descending.
  List<MaintenanceRequest> getRequests();

  /// Retrieves a specific request by its [id], or null if not found.
  MaintenanceRequest? getRequestById(String id);

  /// Clears stored requests (primarily for test suite isolation).
  void clear();
}

/// In-memory implementation of [MaintenanceRepository] for the local prototype.
class LocalMaintenanceRepository implements MaintenanceRepository {
  LocalMaintenanceRepository._();

  /// The application-wide shared singleton.
  static final LocalMaintenanceRepository instance =
      LocalMaintenanceRepository._();

  /// Creates an isolated instance for unit tests.
  // ignore: prefer_constructors_over_static_methods
  static LocalMaintenanceRepository testInstance() =>
      LocalMaintenanceRepository._();

  final List<MaintenanceRequest> _requests = [];

  @override
  MaintenanceRequest createRequest(MaintenanceRequest request) {
    _requests.add(request);
    return request;
  }

  @override
  List<MaintenanceRequest> getRequests() {
    final sorted = List<MaintenanceRequest>.from(_requests)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(sorted);
  }

  @override
  MaintenanceRequest? getRequestById(String id) {
    final matches = _requests.where((r) => r.id == id);
    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  void clear() {
    _requests.clear();
  }
}
