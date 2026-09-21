import '../models/market_run_request.dart';

/// Architecture contract for managing market run requests.
///
/// Designed with an interface so that [LocalMarketRunRepository] (in-memory prototype)
/// can be replaced with a network/database provider in future phases without breaking
/// client screens.
abstract class MarketRunRepository {
  /// Stores a new [request] and returns it.
  MarketRunRequest createRequest(MarketRunRequest request);

  /// Returns all stored market run requests.
  List<MarketRunRequest> getRequests();

  /// Retrieves a specific request by its [id], or null if not found.
  MarketRunRequest? getRequestById(String id);

  /// Updates the operational status of a request.
  MarketRunRequest? updateStatus(String id, MarketRunStatus newStatus);

  /// Cancels a request if it is still in the `requested` intake state.
  /// Returns true if cancelled, false otherwise.
  bool cancelRequest(String id);

  /// Clears stored requests (primarily for test suite isolation).
  void clear();
}

/// In-memory implementation of [MarketRunRepository] for the local prototype.
class LocalMarketRunRepository implements MarketRunRepository {
  LocalMarketRunRepository._();

  /// The application-wide shared singleton.
  static final LocalMarketRunRepository instance = LocalMarketRunRepository._();

  /// Creates an isolated instance for unit tests.
  // ignore: prefer_constructors_over_static_methods
  static LocalMarketRunRepository testInstance() => LocalMarketRunRepository._();

  final List<MarketRunRequest> _requests = [];

  @override
  MarketRunRequest createRequest(MarketRunRequest request) {
    _requests.add(request);
    return request;
  }

  @override
  List<MarketRunRequest> getRequests() {
    final sorted = List<MarketRunRequest>.from(_requests)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(sorted);
  }

  @override
  MarketRunRequest? getRequestById(String id) {
    final matches = _requests.where((r) => r.id == id);
    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  MarketRunRequest? updateStatus(String id, MarketRunStatus newStatus) {
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
    if (_requests[index].status != MarketRunStatus.requested) {
      return false; // Only intake state can be cancelled by resident
    }
    _requests[index] = _requests[index].copyWith(status: MarketRunStatus.cancelled);
    return true;
  }

  @override
  void clear() {
    _requests.clear();
  }
}
