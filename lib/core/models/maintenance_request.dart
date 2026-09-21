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
/// In Phase 6G, only [requested] is actively used. Other states are reserved for future phases.
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
class MaintenanceRequest {
  /// Unique request identifier (e.g. 'MAINT-1710000000000').
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
  final String deliveryLocation;

  /// Optional additional instructions provided by the resident.
  final String? notes;

  /// Current lifecycle status of the request.
  final MaintenanceRequestStatus status;

  /// Timestamp when the request was submitted.
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
}
