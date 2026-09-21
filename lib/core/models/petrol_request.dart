import 'service_request_item.dart';

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
class PetrolRequest implements ServiceRequestItem {
  /// Unique request identifier (e.g. 'PETROL-1710000000000').
  @override
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
  @override
  final String deliveryLocation;

  /// Optional instructions or notes for delivery.
  @override
  final String? notes;

  /// Operational status of the request.
  final PetrolRequestStatus status;

  /// Timestamp when the request was submitted.
  @override
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

  /// Creates a copy with modified values.
  PetrolRequest copyWith({
    String? quantity,
    bool? isCustom,
    String? vehicle,
    PetrolTiming? timing,
    DateTime? scheduledFor,
    String? deliveryLocation,
    String? notes,
    PetrolRequestStatus? status,
  }) {
    return PetrolRequest(
      id: id,
      quantity: quantity ?? this.quantity,
      isCustom: isCustom ?? this.isCustom,
      vehicle: vehicle ?? this.vehicle,
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
  String get serviceTitle => 'PETROL';

  @override
  String get serviceType => 'petrol';

  @override
  String get summaryText =>
      vehicle != null && vehicle!.isNotEmpty ? '$quantity · $vehicle' : quantity;

  @override
  String get timingDisplay {
    switch (timing) {
      case PetrolTiming.asSoonAsPossible:
        return 'AS SOON AS POSSIBLE';
      case PetrolTiming.laterToday:
        return 'LATER TODAY';
      case PetrolTiming.scheduled:
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
      case PetrolRequestStatus.requested:
        return ServiceOperationalPhase.requested;
      case PetrolRequestStatus.assigned:
      case PetrolRequestStatus.refuelling:
      case PetrolRequestStatus.outForDelivery:
        return ServiceOperationalPhase.inProgress;
      case PetrolRequestStatus.delivered:
        return ServiceOperationalPhase.completed;
      case PetrolRequestStatus.cancelled:
        return ServiceOperationalPhase.cancelled;
    }
  }

  @override
  bool get isActive =>
      status != PetrolRequestStatus.delivered &&
      status != PetrolRequestStatus.cancelled;

  @override
  bool get canBeCancelled => status == PetrolRequestStatus.requested;
}
