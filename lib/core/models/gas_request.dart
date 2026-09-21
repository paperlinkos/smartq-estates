/// The timing preference specified by the resident for their cooking gas delivery.
enum GasTiming {
  asSoonAsPossible,
  laterToday,
  scheduled;

  String get displayName {
    switch (this) {
      case GasTiming.asSoonAsPossible:
        return 'AS SOON AS POSSIBLE';
      case GasTiming.laterToday:
        return 'LATER TODAY';
      case GasTiming.scheduled:
        return 'SCHEDULED';
    }
  }
}

/// The operational status of a gas delivery request.
/// In Phase 6D, only [requested] is actively used. Other states are reserved for future phases.
enum GasRequestStatus {
  requested,
  assigned,
  refilling,
  outForDelivery,
  delivered,
  cancelled;

  String get displayName {
    switch (this) {
      case GasRequestStatus.requested:
        return 'REQUESTED';
      case GasRequestStatus.assigned:
        return 'ASSIGNED';
      case GasRequestStatus.refilling:
        return 'REFILLING';
      case GasRequestStatus.outForDelivery:
        return 'OUT FOR DELIVERY';
      case GasRequestStatus.delivered:
        return 'DELIVERED';
      case GasRequestStatus.cancelled:
        return 'CANCELLED';
    }
  }
}

/// A structured model representing a resident's request for cooking gas delivery.
class GasRequest {
  /// Unique request identifier (e.g. 'GAS-1710000000000').
  final String id;

  /// The cylinder size or quantity (e.g. '12.5 KG' or custom entered text).
  final String cylinderSize;

  /// Whether the cylinder size was custom-specified by the resident.
  final bool isCustom;

  /// The delivery timing preference.
  final GasTiming timing;

  /// Specific scheduled date and time when [timing] is [GasTiming.scheduled].
  final DateTime? scheduledFor;

  /// Delivery location identifier or structured key.
  final String deliveryLocation;

  /// Optional instructions or notes for delivery.
  final String? notes;

  /// Operational status of the request.
  final GasRequestStatus status;

  /// Timestamp when the request was submitted.
  final DateTime createdAt;

  const GasRequest({
    required this.id,
    required this.cylinderSize,
    required this.isCustom,
    required this.timing,
    this.scheduledFor,
    required this.deliveryLocation,
    this.notes,
    required this.status,
    required this.createdAt,
  });

  /// Creates a new [GasRequest] with generated identifier and default status.
  factory GasRequest.create({
    required String cylinderSize,
    bool isCustom = false,
    required GasTiming timing,
    DateTime? scheduledFor,
    String deliveryLocation = 'estateAddress',
    String? notes,
    DateTime? createdAt,
    String? id,
  }) {
    final now = createdAt ?? DateTime.now();
    return GasRequest(
      id: id ?? 'GAS-${now.microsecondsSinceEpoch}',
      cylinderSize: cylinderSize.trim(),
      isCustom: isCustom,
      timing: timing,
      scheduledFor: scheduledFor,
      deliveryLocation: deliveryLocation,
      notes: notes != null && notes.trim().isNotEmpty ? notes.trim() : null,
      status: GasRequestStatus.requested,
      createdAt: now,
    );
  }
}
