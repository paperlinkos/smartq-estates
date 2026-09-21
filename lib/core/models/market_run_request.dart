import 'service_request_item.dart';

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
class MarketRunRequest implements ServiceRequestItem {
  /// Unique request identifier (e.g. 'MR-1710000000000').
  @override
  final String id;

  /// The raw multiline text of items requested by the resident.
  final String items;

  /// The delivery timing preference.
  final MarketRunTiming timing;

  /// Specific scheduled date and time when [timing] is [MarketRunTiming.scheduled].
  final DateTime? scheduledFor;

  /// Delivery location identifier or structured key.
  @override
  final String deliveryLocation;

  /// Optional instructions or notes for the shopper.
  @override
  final String? notes;

  /// Operational status of the request.
  final MarketRunStatus status;

  /// Timestamp when the request was submitted.
  @override
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

  /// Creates a copy with modified values.
  MarketRunRequest copyWith({
    String? items,
    MarketRunTiming? timing,
    DateTime? scheduledFor,
    String? deliveryLocation,
    String? notes,
    MarketRunStatus? status,
  }) {
    return MarketRunRequest(
      id: id,
      items: items ?? this.items,
      timing: timing ?? this.timing,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  // ── ServiceRequestItem Implementation ──────────────────────────────────────

  @override
  String get serviceTitle => 'MARKET RUN';

  @override
  String get serviceType => 'marketRun';

  @override
  String get summaryText => items;

  @override
  String get timingDisplay {
    switch (timing) {
      case MarketRunTiming.asSoonAsPossible:
        return 'AS SOON AS POSSIBLE';
      case MarketRunTiming.laterToday:
        return 'LATER TODAY';
      case MarketRunTiming.scheduled:
        if (scheduledFor != null) {
          const months = [
            'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
          ];
          final hour = scheduledFor!.hour == 0
              ? 12
              : (scheduledFor!.hour > 12 ? scheduledFor!.hour - 12 : scheduledFor!.hour);
          final period = scheduledFor!.hour >= 12 ? 'PM' : 'AM';
          final minute = scheduledFor!.minute.toString().padLeft(2, '0');
          return '${scheduledFor!.day} ${months[scheduledFor!.month - 1]}, ${scheduledFor!.year} · $hour:$minute $period';
        }
        return 'SCHEDULED';
    }
  }

  @override
  String get statusDisplayName => status.displayName;

  @override
  ServiceOperationalPhase get operationalPhase {
    switch (status) {
      case MarketRunStatus.requested:
        return ServiceOperationalPhase.requested;
      case MarketRunStatus.assigned:
      case MarketRunStatus.shopping:
      case MarketRunStatus.outForDelivery:
        return ServiceOperationalPhase.inProgress;
      case MarketRunStatus.delivered:
        return ServiceOperationalPhase.completed;
      case MarketRunStatus.cancelled:
        return ServiceOperationalPhase.cancelled;
    }
  }

  @override
  bool get isActive =>
      status != MarketRunStatus.delivered && status != MarketRunStatus.cancelled;

  @override
  bool get canBeCancelled => status == MarketRunStatus.requested;
}
