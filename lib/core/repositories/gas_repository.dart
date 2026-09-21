import '../models/gas_request.dart';

/// Architecture contract for managing gas delivery requests.
///
/// Designed with an interface so that [LocalGasRepository] (in-memory prototype)
/// can be replaced with a persistent network/database provider in future phases without breaking
/// client screens.
abstract class GasRepository {
  /// Stores a new [request] and returns it.
  GasRequest createRequest(GasRequest request);

  /// Returns all stored gas requests, sorted by createdAt descending.
  List<GasRequest> getRequests();

  /// Retrieves a specific request by its [id], or null if not found.
  GasRequest? getRequestById(String id);

  /// Updates the operational status of a request.
  GasRequest? updateStatus(String id, GasRequestStatus newStatus);

  /// Cancels a request if it is still in the `requested` intake state.
  /// Returns true if cancelled, false otherwise.
  bool cancelRequest(String id);

  /// Clears stored requests (primarily for test suite isolation).
  void clear();
}

/// In-memory implementation of [GasRepository] for the local prototype.
class LocalGasRepository implements GasRepository {
  LocalGasRepository._();

  /// The application-wide shared singleton.
  static final LocalGasRepository instance = LocalGasRepository._();

  /// Creates an isolated instance for unit tests.
  // ignore: prefer_constructors_over_static_methods
  static LocalGasRepository testInstance() => LocalGasRepository._();

  final List<GasRequest> _requests = [];

  @override
  GasRequest createRequest(GasRequest request) {
    _requests.add(request);
    return request;
  }

  @override
  List<GasRequest> getRequests() {
    final sorted = List<GasRequest>.from(_requests)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(sorted);
  }

  @override
  GasRequest? getRequestById(String id) {
    final matches = _requests.where((r) => r.id == id);
    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  GasRequest? updateStatus(String id, GasRequestStatus newStatus) {
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
    if (_requests[index].status != GasRequestStatus.requested) {
      return false;
    }
    _requests[index] = _requests[index].copyWith(status: GasRequestStatus.cancelled);
    return true;
  }

  @override
  void clear() {
    _requests.clear();
  }
}
