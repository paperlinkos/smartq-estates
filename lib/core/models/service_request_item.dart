/// Universal operational phase used for high-level resident tracking and UI timelines.
enum ServiceOperationalPhase {
  requested,
  inProgress,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case ServiceOperationalPhase.requested:
        return 'REQUESTED';
      case ServiceOperationalPhase.inProgress:
        return 'IN PROGRESS';
      case ServiceOperationalPhase.completed:
        return 'COMPLETED';
      case ServiceOperationalPhase.cancelled:
        return 'CANCELLED';
    }
  }
}

/// A common read-only interface implemented by all six domain-specific service requests
/// (`MarketRunRequest`, `GroceryRequest`, `GasRequest`, `PetrolRequest`, `GeneratorRequest`, `MaintenanceRequest`).
///
/// This permits unified listing, filtering, and timeline rendering across resident and operational screens
/// without discarding domain-specific strongly-typed models or tight coupling.
abstract class ServiceRequestItem {
  /// Unique request identifier (e.g. 'MR-1710000000', 'GAS-1710000000').
  String get id;

  /// High-level service title (e.g. 'MARKET RUN', 'COOKING GAS', 'MAINTENANCE').
  String get serviceTitle;

  /// Service category icon identifier for UI rendering.
  String get serviceType;

  /// Primary description or quantity summary (e.g. 'Tomatoes, onions...', '12.5 KG', 'Need oil change').
  String get summaryText;

  /// Human-readable timing preference (e.g. 'AS SOON AS POSSIBLE', '25 Sep, 2026 · 3:00 PM').
  String get timingDisplay;

  /// Delivery or service address (e.g. 'MY ESTATE ADDRESS').
  String get deliveryLocation;

  /// Optional resident notes or instructions.
  String? get notes;

  /// Domain-specific raw status display name (e.g. 'REQUESTED', 'SHOPPING', 'REFILLING', 'DELIVERED').
  String get statusDisplayName;

  /// High-level 3-phase lifecycle state for standard progress timeline rendering.
  ServiceOperationalPhase get operationalPhase;

  /// Whether the request is still actively being processed (not completed/delivered or cancelled).
  bool get isActive;

  /// Whether the resident is allowed to cancel the request (only permitted while in intake 'requested' state).
  bool get canBeCancelled;

  /// When the request was submitted.
  DateTime get createdAt;

  /// Identifier of the requesting resident.
  String get residentId;

  /// Display name of the requesting resident (e.g. 'John Doe').
  String get residentName;

  /// Resident's unit or estate address (e.g. 'Unit 4B • Pinecrest Royal Estate').
  String get unitOrEstate;
}
