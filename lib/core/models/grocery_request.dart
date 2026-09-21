import 'service_request_item.dart';

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
class GroceryRequest implements ServiceRequestItem {
  /// Unique request identifier (e.g. 'GR-1710000000000').
  @override
  final String id;

  /// The raw multiline text of grocery items requested by the resident.
  final String items;

  /// The delivery timing preference.
  final GroceryTiming timing;

  /// Specific scheduled date and time when [timing] is [GroceryTiming.scheduled].
  final DateTime? scheduledFor;

  /// Delivery location identifier or structured key.
  @override
  final String deliveryLocation;

  /// Optional instructions or notes for delivery.
  @override
  final String? notes;

  /// Operational status of the request.
  final GroceryRequestStatus status;

  /// Timestamp when the request was submitted.
  @override
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

  /// Creates a copy with modified values.
  GroceryRequest copyWith({
    String? items,
    GroceryTiming? timing,
    DateTime? scheduledFor,
    String? deliveryLocation,
    String? notes,
    GroceryRequestStatus? status,
  }) {
    return GroceryRequest(
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
  String get serviceTitle => 'GROCERIES';

  @override
  String get serviceType => 'groceries';

  @override
  String get summaryText => items;

  @override
  String get timingDisplay {
    switch (timing) {
      case GroceryTiming.asSoonAsPossible:
        return 'AS SOON AS POSSIBLE';
      case GroceryTiming.laterToday:
        return 'LATER TODAY';
      case GroceryTiming.scheduled:
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
      case GroceryRequestStatus.requested:
        return ServiceOperationalPhase.requested;
      case GroceryRequestStatus.assigned:
      case GroceryRequestStatus.shopping:
      case GroceryRequestStatus.outForDelivery:
        return ServiceOperationalPhase.inProgress;
      case GroceryRequestStatus.delivered:
        return ServiceOperationalPhase.completed;
      case GroceryRequestStatus.cancelled:
        return ServiceOperationalPhase.cancelled;
    }
  }

  @override
  bool get isActive =>
      status != GroceryRequestStatus.delivered &&
      status != GroceryRequestStatus.cancelled;

  @override
  bool get canBeCancelled => status == GroceryRequestStatus.requested;
}
