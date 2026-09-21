import '../models/event_pass.dart';
import '../models/visitor_pass.dart';

/// Architecture contract for the local pass registry.
///
/// The registry is the single source of truth for all passes created during
/// a prototype session. The verification service queries this registry —
/// it never trusts data from the scanned QR payload.
///
/// This interface is designed so that [LocalPassRegistry] (in-memory prototype)
/// can be replaced with a network-backed implementation without changing any
/// calling code.
abstract class PassRegistry {
  /// Stores a newly created visitor pass.
  void registerVisitorPass(VisitorPass pass);

  /// Stores a newly created event pass.
  void registerEventPass(EventPass pass);

  /// Retrieves a visitor pass by its [passId]. Returns null if not found.
  VisitorPass? findVisitorPass(String passId);

  /// Retrieves an event pass by its [passId]. Returns null if not found.
  EventPass? findEventPass(String passId);

  /// Replaces the stored visitor pass record (used when status changes, e.g. cancellation).
  void updateVisitorPass(VisitorPass pass);

  /// Replaces the stored event pass record (used when status changes, e.g. cancellation).
  void updateEventPass(EventPass pass);
}

/// In-memory implementation of [PassRegistry] for the local prototype.
///
/// Uses a singleton pattern so that any screen in the app shares the same
/// registry state within a session.
///
/// IMPORTANT: Data is not persisted between app launches. This is intentional
/// for the prototype phase. Replace with a backend-backed implementation when
/// persistent verification is required.
class LocalPassRegistry implements PassRegistry {
  LocalPassRegistry._();

  /// The singleton instance shared across the app.
  static final LocalPassRegistry instance = LocalPassRegistry._();

  /// Creates an isolated registry instance for unit tests.
  /// Tests must use this factory to avoid polluting the app singleton.
  // ignore: prefer_constructors_over_static_methods
  static LocalPassRegistry testInstance() => LocalPassRegistry._();

  final Map<String, VisitorPass> _visitorPasses = {};
  final Map<String, EventPass> _eventPasses = {};

  @override
  void registerVisitorPass(VisitorPass pass) {
    _visitorPasses[pass.passId] = pass;
  }

  @override
  void registerEventPass(EventPass pass) {
    _eventPasses[pass.passId] = pass;
  }

  @override
  VisitorPass? findVisitorPass(String passId) {
    return _visitorPasses[passId];
  }

  @override
  EventPass? findEventPass(String passId) {
    return _eventPasses[passId];
  }

  @override
  void updateVisitorPass(VisitorPass pass) {
    _visitorPasses[pass.passId] = pass;
  }

  @override
  void updateEventPass(EventPass pass) {
    _eventPasses[pass.passId] = pass;
  }
}
