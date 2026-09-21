import '../models/grocery_request.dart';

/// Architecture contract for managing grocery delivery requests.
///
/// Designed with an interface so that [LocalGroceryRepository] (in-memory prototype)
/// can be replaced with a persistent network/database provider in future phases without breaking
/// client screens.
abstract class GroceryRepository {
  /// Stores a new [request] and returns it.
  GroceryRequest createRequest(GroceryRequest request);

  /// Returns all stored grocery requests, sorted by createdAt descending.
  List<GroceryRequest> getRequests();

  /// Retrieves a specific request by its [id], or null if not found.
  GroceryRequest? getRequestById(String id);

  /// Updates the operational status of a request.
  GroceryRequest? updateStatus(String id, GroceryRequestStatus newStatus);

  /// Cancels a request if it is still in the `requested` intake state.
  /// Returns true if cancelled, false otherwise.
  bool cancelRequest(String id);

  /// Clears stored requests (primarily for test suite isolation).
  void clear();
}

/// In-memory implementation of [GroceryRepository] for the local prototype.
class LocalGroceryRepository implements GroceryRepository {
  LocalGroceryRepository._();

  /// The application-wide shared singleton.
  static final LocalGroceryRepository instance = LocalGroceryRepository._();

  /// Creates an isolated instance for unit tests.
  // ignore: prefer_constructors_over_static_methods
  static LocalGroceryRepository testInstance() => LocalGroceryRepository._();

  final List<GroceryRequest> _requests = [];

  @override
  GroceryRequest createRequest(GroceryRequest request) {
    _requests.add(request);
    return request;
  }

  @override
  List<GroceryRequest> getRequests() {
    final sorted = List<GroceryRequest>.from(_requests)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(sorted);
  }

  @override
  GroceryRequest? getRequestById(String id) {
    final matches = _requests.where((r) => r.id == id);
    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  GroceryRequest? updateStatus(String id, GroceryRequestStatus newStatus) {
    final index = _requests.indexWhere((r) => r.id == id);
    if (index == -1) return null;
    final updated = _requests[index].copyWith(status: newStatus);
    _requests[index] = updated;
    return updated;
  }

  @override
  bool cancelRequest(String id) {
    final index = _requests.indexWhere((r) => r.id == id);
    if (index == -1) return false;
    if (_requests[index].status != GroceryRequestStatus.requested) {
      return false;
    }
    _requests[index] = _requests[index].copyWith(status: GroceryRequestStatus.cancelled);
    return true;
  }

  @override
  void clear() {
    _requests.clear();
  }
}
