import '../models/generator_request.dart';

/// Architecture contract for managing generator service requests.
///
/// Designed with an interface so that [LocalGeneratorRepository] (in-memory prototype)
/// can be replaced with a persistent network/database provider in future phases without breaking
/// client screens.
abstract class GeneratorRepository {
  /// Stores a new [request] and returns it.
  GeneratorRequest createRequest(GeneratorRequest request);

  /// Returns all stored generator requests, sorted by createdAt descending.
  List<GeneratorRequest> getRequests();

  /// Retrieves a specific request by its [id], or null if not found.
  GeneratorRequest? getRequestById(String id);

  /// Clears stored requests (primarily for test suite isolation).
  void clear();
}

/// In-memory implementation of [GeneratorRepository] for the local prototype.
class LocalGeneratorRepository implements GeneratorRepository {
  LocalGeneratorRepository._();

  /// The application-wide shared singleton.
  static final LocalGeneratorRepository instance = LocalGeneratorRepository._();

  /// Creates an isolated instance for unit tests.
  // ignore: prefer_constructors_over_static_methods
  static LocalGeneratorRepository testInstance() => LocalGeneratorRepository._();

  final List<GeneratorRequest> _requests = [];

  @override
  GeneratorRequest createRequest(GeneratorRequest request) {
    _requests.add(request);
    return request;
  }

  @override
  List<GeneratorRequest> getRequests() {
    final sorted = List<GeneratorRequest>.from(_requests)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(sorted);
  }

  @override
  GeneratorRequest? getRequestById(String id) {
    final matches = _requests.where((r) => r.id == id);
    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  void clear() {
    _requests.clear();
  }
}
