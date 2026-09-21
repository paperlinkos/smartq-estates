import 'service_request_item.dart';

/// The timing preference specified by the resident for their maintenance service.
enum MaintenanceTiming {
  asSoonAsPossible,
  laterToday,
  scheduled;

  String get displayName {
    switch (this) {
      case MaintenanceTiming.asSoonAsPossible:
        return 'AS SOON AS POSSIBLE';
      case MaintenanceTiming.laterToday:
        return 'LATER TODAY';
      case MaintenanceTiming.scheduled:
        return 'SCHEDULED';
    }
  }
}

/// The operational status of a maintenance request.
enum MaintenanceRequestStatus {
  requested,
  assigned,
  inProgress,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case MaintenanceRequestStatus.requested:
        return 'REQUESTED';
      case MaintenanceRequestStatus.assigned:
        return 'ASSIGNED';
      case MaintenanceRequestStatus.inProgress:
        return 'IN PROGRESS';
      case MaintenanceRequestStatus.completed:
        return 'COMPLETED';
      case MaintenanceRequestStatus.cancelled:
        return 'CANCELLED';
    }
  }
}

/// A structured model representing a resident's request for household or property repairs.
class MaintenanceRequest implements ServiceRequestItem {
  /// Unique request identifier (e.g. 'MAINT-1710000000000').
  @override
  final String id;

  /// Detailed description of the maintenance issue or item needing attention.
  final String description;

  /// Optional category classification (e.g. 'PLUMBING', 'ELECTRICAL', 'CARPENTRY').
  final String? category;

  /// Timing preference selected by the resident.
  final MaintenanceTiming timing;

  /// Specific date and time if [timing] is [MaintenanceTiming.scheduled].
  final DateTime? scheduledFor;

  /// Delivery/service location identifier. Currently defaults to 'estateAddress'.
  @override
  final String deliveryLocation;

  /// Optional additional instructions provided by the resident.
  @override
  final String? notes;

  /// Current lifecycle status of the request.
  final MaintenanceRequestStatus status;

  /// Timestamp when the request was submitted.
  @override
  final DateTime createdAt;

  const MaintenanceRequest({
    required this.id,
    required this.description,
    this.category,
    required this.timing,
    this.scheduledFor,
    required this.deliveryLocation,
    this.notes,
    required this.status,
    required this.createdAt,
  });

  /// Factory helper to create a new [MaintenanceRequest] with generated defaults.
  factory MaintenanceRequest.create({
    required String description,
    String? category,
    required MaintenanceTiming timing,
    DateTime? scheduledFor,
    String deliveryLocation = 'estateAddress',
    String? notes,
    MaintenanceRequestStatus status = MaintenanceRequestStatus.requested,
    DateTime? createdAt,
  }) {
    final now = createdAt ?? DateTime.now();
    final cleanCategory = category?.trim();
    final cleanNotes = notes?.trim();

    return MaintenanceRequest(
      id: 'MAINT-${now.microsecondsSinceEpoch}',
      description: description.trim(),
      category: cleanCategory != null && cleanCategory.isNotEmpty
          ? cleanCategory
          : null,
      timing: timing,
      scheduledFor: scheduledFor,
      deliveryLocation: deliveryLocation,
      notes: cleanNotes != null && cleanNotes.isNotEmpty ? cleanNotes : null,
      status: status,
      createdAt: now,
    );
  }

  /// Creates a copy with modified values.
  MaintenanceRequest copyWith({
    String? description,
    String? category,
    MaintenanceTiming? timing,
    DateTime? scheduledFor,
    String? deliveryLocation,
    String? notes,
    MaintenanceRequestStatus? status,
  }) {
    return MaintenanceRequest(
      id: id,
      description: description ?? this.description,
      category: category ?? this.category,
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
  String get serviceTitle => 'MAINTENANCE';

  @override
  String get serviceType => 'maintenance';

  @override
  String get summaryText => category != null && category!.isNotEmpty
      ? '$category · $description'
      : description;

  @override
  String get timingDisplay {
    switch (timing) {
      case MaintenanceTiming.asSoonAsPossible:
        return 'AS SOON AS POSSIBLE';
      case MaintenanceTiming.laterToday:
        return 'LATER TODAY';
      case MaintenanceTiming.scheduled:
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
      case MaintenanceRequestStatus.requested:
        return ServiceOperationalPhase.requested;
      case MaintenanceRequestStatus.assigned:
      case MaintenanceRequestStatus.inProgress:
        return ServiceOperationalPhase.inProgress;
      case MaintenanceRequestStatus.completed:
        return ServiceOperationalPhase.completed;
      case MaintenanceRequestStatus.cancelled:
        return ServiceOperationalPhase.cancelled;
    }
  }

  @override
  bool get isActive =>
      status != MaintenanceRequestStatus.completed &&
      status != MaintenanceRequestStatus.cancelled;

  @override
  bool get canBeCancelled => status == MaintenanceRequestStatus.requested;
}
