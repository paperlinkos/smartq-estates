/// The timing preference specified by the resident for their petrol delivery.
enum PetrolTiming {
  asSoonAsPossible,
  laterToday,
  scheduled;

  String get displayName {
    switch (this) {
      case PetrolTiming.asSoonAsPossible:
        return 'AS SOON AS POSSIBLE';
      case PetrolTiming.laterToday:
        return 'LATER TODAY';
      case PetrolTiming.scheduled:
        return 'SCHEDULED';
    }
  }
}

/// The operational status of a petrol delivery request.
/// In Phase 6E, only [requested] is actively used. Other states are reserved for future phases.
enum PetrolRequestStatus {
  requested,
  assigned,
  refuelling,
  outForDelivery,
  delivered,
  cancelled;

  String get displayName {
    switch (this) {
      case PetrolRequestStatus.requested:
        return 'REQUESTED';
      case PetrolRequestStatus.assigned:
        return 'ASSIGNED';
      case PetrolRequestStatus.refuelling:
        return 'REFUELLING';
      case PetrolRequestStatus.outForDelivery:
        return 'OUT FOR DELIVERY';
      case PetrolRequestStatus.delivered:
        return 'DELIVERED';
      case PetrolRequestStatus.cancelled:
        return 'CANCELLED';
    }
  }
}

/// A structured model representing a resident's request for petrol delivery.
class PetrolRequest {
  /// Unique request identifier (e.g. 'PETROL-1710000000000').
  final String id;

  /// The fuel quantity (e.g. '20 L' or custom entered liters).
  final String quantity;

  /// Whether the quantity was custom-specified by the resident.
  final bool isCustom;

  /// Optional vehicle description (e.g. 'Black Toyota Camry' or 'Generator fuel tank').
  final String? vehicle;

  /// The delivery timing preference.
  final PetrolTiming timing;

  /// Specific scheduled date and time when [timing] is [PetrolTiming.scheduled].
  final DateTime? scheduledFor;

  /// Delivery location identifier or structured key.
  final String deliveryLocation;

  /// Optional instructions or notes for delivery.
  final String? notes;

  /// Operational status of the request.
  final PetrolRequestStatus status;

  /// Timestamp when the request was submitted.
  final DateTime createdAt;

  const PetrolRequest({
    required this.id,
    required this.quantity,
    required this.isCustom,
    this.vehicle,
    required this.timing,
    this.scheduledFor,
    required this.deliveryLocation,
    this.notes,
    required this.status,
    required this.createdAt,
  });

  /// Creates a new [PetrolRequest] with generated identifier and default status.
  factory PetrolRequest.create({
    required String quantity,
    bool isCustom = false,
    String? vehicle,
    required PetrolTiming timing,
    DateTime? scheduledFor,
    String deliveryLocation = 'estateAddress',
    String? notes,
    DateTime? createdAt,
    String? id,
  }) {
    final now = createdAt ?? DateTime.now();
    return PetrolRequest(
      id: id ?? 'PETROL-${now.microsecondsSinceEpoch}',
      quantity: quantity.trim(),
      isCustom: isCustom,
      vehicle: vehicle != null && vehicle.trim().isNotEmpty ? vehicle.trim() : null,
      timing: timing,
      scheduledFor: scheduledFor,
      deliveryLocation: deliveryLocation,
      notes: notes != null && notes.trim().isNotEmpty ? notes.trim() : null,
      status: PetrolRequestStatus.requested,
      createdAt: now,
    );
  }
}
