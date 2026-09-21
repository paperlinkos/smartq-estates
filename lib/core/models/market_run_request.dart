/// The timing preference specified by the resident for their market run.
enum MarketRunTiming {
  asSoonAsPossible,
  laterToday,
  scheduled;

  String get displayName {
    switch (this) {
      case MarketRunTiming.asSoonAsPossible:
        return 'AS SOON AS POSSIBLE';
      case MarketRunTiming.laterToday:
        return 'LATER TODAY';
      case MarketRunTiming.scheduled:
        return 'SCHEDULED';
    }
  }
}

/// The lifecycle status of a market run request.
/// In Phase 6B, only [requested] is actively used. Other states are reserved for future phases.
enum MarketRunStatus {
  requested,
  assigned,
  shopping,
  outForDelivery,
  delivered,
  cancelled;

  String get displayName {
    switch (this) {
      case MarketRunStatus.requested:
        return 'REQUESTED';
      case MarketRunStatus.assigned:
        return 'ASSIGNED';
      case MarketRunStatus.shopping:
        return 'SHOPPING';
      case MarketRunStatus.outForDelivery:
        return 'OUT FOR DELIVERY';
      case MarketRunStatus.delivered:
        return 'DELIVERED';
      case MarketRunStatus.cancelled:
        return 'CANCELLED';
    }
  }
}

/// A structured model representing a resident's request for market shopping assistance.
class MarketRunRequest {
  /// Unique request identifier (e.g. 'MR-1710000000000').
  final String id;

  /// The raw multiline text of items requested by the resident.
  final String items;

  /// The delivery timing preference.
  final MarketRunTiming timing;

  /// Specific scheduled date and time when [timing] is [MarketRunTiming.scheduled].
  final DateTime? scheduledFor;

  /// Delivery location identifier or structured key.
  final String deliveryLocation;

  /// Optional instructions or notes for the shopper.
  final String? notes;

  /// Operational status of the request.
  final MarketRunStatus status;

  /// Timestamp when the request was submitted.
  final DateTime createdAt;

  const MarketRunRequest({
    required this.id,
    required this.items,
    required this.timing,
    this.scheduledFor,
    required this.deliveryLocation,
    this.notes,
    required this.status,
    required this.createdAt,
  });

  /// Creates a new [MarketRunRequest] with generated identifier and default status.
  factory MarketRunRequest.create({
    required String items,
    required MarketRunTiming timing,
    DateTime? scheduledFor,
    String deliveryLocation = 'estateAddress',
    String? notes,
    DateTime? createdAt,
  }) {
    final now = createdAt ?? DateTime.now();
    return MarketRunRequest(
      id: 'MR-${now.microsecondsSinceEpoch}',
      items: items.trim(),
      timing: timing,
      scheduledFor: scheduledFor,
      deliveryLocation: deliveryLocation,
      notes: notes != null && notes.trim().isNotEmpty ? notes.trim() : null,
      status: MarketRunStatus.requested,
      createdAt: now,
    );
  }
}
