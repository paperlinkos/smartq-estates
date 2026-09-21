import 'service_request_item.dart';

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
class GasRequest implements ServiceRequestItem {
  /// Unique request identifier (e.g. 'GAS-1710000000000').
  @override
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
  @override
  final String deliveryLocation;

  /// Optional instructions or notes for delivery.
  @override
  final String? notes;

  /// Operational status of the request.
  final GasRequestStatus status;

  /// Timestamp when the request was submitted.
  @override
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

  /// Creates a copy with modified values.
  GasRequest copyWith({
    String? cylinderSize,
    bool? isCustom,
    GasTiming? timing,
    DateTime? scheduledFor,
    String? deliveryLocation,
    String? notes,
    GasRequestStatus? status,
  }) {
    return GasRequest(
      id: id,
      cylinderSize: cylinderSize ?? this.cylinderSize,
      isCustom: isCustom ?? this.isCustom,
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
  String get serviceTitle => 'COOKING GAS';

  @override
  String get serviceType => 'gas';

  @override
  String get summaryText => cylinderSize;

  @override
  String get timingDisplay {
    switch (timing) {
      case GasTiming.asSoonAsPossible:
        return 'AS SOON AS POSSIBLE';
      case GasTiming.laterToday:
        return 'LATER TODAY';
      case GasTiming.scheduled:
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
      case GasRequestStatus.requested:
        return ServiceOperationalPhase.requested;
      case GasRequestStatus.assigned:
      case GasRequestStatus.refilling:
      case GasRequestStatus.outForDelivery:
        return ServiceOperationalPhase.inProgress;
      case GasRequestStatus.delivered:
        return ServiceOperationalPhase.completed;
      case GasRequestStatus.cancelled:
        return ServiceOperationalPhase.cancelled;
    }
  }

  @override
  bool get isActive =>
      status != GasRequestStatus.delivered && status != GasRequestStatus.cancelled;

  @override
  bool get canBeCancelled => status == GasRequestStatus.requested;

  @override
  String get residentId => 'res-01';

  @override
  String get residentName => 'John Doe';

  @override
  String get unitOrEstate => 'Unit 4B • Pinecrest Royal Estate';
}
