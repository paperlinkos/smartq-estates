/// The timing preference specified by the resident for their groceries delivery.
enum GroceryTiming {
  asSoonAsPossible,
  laterToday,
  scheduled;

  String get displayName {
    switch (this) {
      case GroceryTiming.asSoonAsPossible:
        return 'AS SOON AS POSSIBLE';
      case GroceryTiming.laterToday:
        return 'LATER TODAY';
      case GroceryTiming.scheduled:
        return 'SCHEDULED';
    }
  }
}

/// The operational status of a grocery delivery request.
/// In Phase 6C, only [requested] is actively used. Other states are reserved for future phases.
enum GroceryRequestStatus {
  requested,
  assigned,
  shopping,
  outForDelivery,
  delivered,
  cancelled;

  String get displayName {
    switch (this) {
      case GroceryRequestStatus.requested:
        return 'REQUESTED';
      case GroceryRequestStatus.assigned:
        return 'ASSIGNED';
      case GroceryRequestStatus.shopping:
        return 'SHOPPING';
      case GroceryRequestStatus.outForDelivery:
        return 'OUT FOR DELIVERY';
      case GroceryRequestStatus.delivered:
        return 'DELIVERED';
      case GroceryRequestStatus.cancelled:
        return 'CANCELLED';
    }
  }
}

/// A structured model representing a resident's request for grocery delivery.
class GroceryRequest {
  /// Unique request identifier (e.g. 'GR-1710000000000').
  final String id;

  /// The raw multiline text of grocery items requested by the resident.
  final String items;

  /// The delivery timing preference.
  final GroceryTiming timing;

  /// Specific scheduled date and time when [timing] is [GroceryTiming.scheduled].
  final DateTime? scheduledFor;

  /// Delivery location identifier or structured key.
  final String deliveryLocation;

  /// Optional instructions or notes for delivery.
  final String? notes;

  /// Operational status of the request.
  final GroceryRequestStatus status;

  /// Timestamp when the request was submitted.
  final DateTime createdAt;

  const GroceryRequest({
    required this.id,
    required this.items,
    required this.timing,
    this.scheduledFor,
    required this.deliveryLocation,
    this.notes,
    required this.status,
    required this.createdAt,
  });

  /// Creates a new [GroceryRequest] with generated identifier and default status.
  factory GroceryRequest.create({
    required String items,
    required GroceryTiming timing,
    DateTime? scheduledFor,
    String deliveryLocation = 'estateAddress',
    String? notes,
    DateTime? createdAt,
    String? id,
  }) {
    final now = createdAt ?? DateTime.now();
    return GroceryRequest(
      id: id ?? 'GR-${now.microsecondsSinceEpoch}',
      items: items.trim(),
      timing: timing,
      scheduledFor: scheduledFor,
      deliveryLocation: deliveryLocation,
      notes: notes != null && notes.trim().isNotEmpty ? notes.trim() : null,
      status: GroceryRequestStatus.requested,
      createdAt: now,
    );
  }
}
