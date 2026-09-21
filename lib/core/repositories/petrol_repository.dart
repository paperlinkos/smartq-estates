import '../models/petrol_request.dart';

/// Architecture contract for managing petrol delivery requests.
///
/// Designed with an interface so that [LocalPetrolRepository] (in-memory prototype)
/// can be replaced with a persistent network/database provider in future phases without breaking
/// client screens.
abstract class PetrolRepository {
  /// Stores a new [request] and returns it.
  PetrolRequest createRequest(PetrolRequest request);

  /// Returns all stored petrol requests, sorted by createdAt descending.
  List<PetrolRequest> getRequests();

  /// Retrieves a specific request by its [id], or null if not found.
  PetrolRequest? getRequestById(String id);

  /// Clears stored requests (primarily for test suite isolation).
  void clear();
}

/// In-memory implementation of [PetrolRepository] for the local prototype.
class LocalPetrolRepository implements PetrolRepository {
  LocalPetrolRepository._();

  /// The application-wide shared singleton.
  static final LocalPetrolRepository instance = LocalPetrolRepository._();

  /// Creates an isolated instance for unit tests.
  // ignore: prefer_constructors_over_static_methods
  static LocalPetrolRepository testInstance() => LocalPetrolRepository._();

  final List<PetrolRequest> _requests = [];

  @override
  PetrolRequest createRequest(PetrolRequest request) {
    _requests.add(request);
    return request;
  }

  @override
  List<PetrolRequest> getRequests() {
    final sorted = List<PetrolRequest>.from(_requests)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(sorted);
  }

  @override
  PetrolRequest? getRequestById(String id) {
    final matches = _requests.where((r) => r.id == id);
    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  void clear() {
    _requests.clear();
  }
}
