/// The timing preference specified by the resident for their generator service.
enum GeneratorTiming {
  asSoonAsPossible,
  laterToday,
  scheduled;

  String get displayName {
    switch (this) {
      case GeneratorTiming.asSoonAsPossible:
        return 'AS SOON AS POSSIBLE';
      case GeneratorTiming.laterToday:
        return 'LATER TODAY';
      case GeneratorTiming.scheduled:
        return 'SCHEDULED';
    }
  }
}

/// The operational status of a generator service request.
/// In Phase 6F, only [requested] is actively used. Other states are reserved for future phases.
enum GeneratorRequestStatus {
  requested,
  assigned,
  inProgress,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case GeneratorRequestStatus.requested:
        return 'REQUESTED';
      case GeneratorRequestStatus.assigned:
        return 'ASSIGNED';
      case GeneratorRequestStatus.inProgress:
        return 'IN PROGRESS';
      case GeneratorRequestStatus.completed:
        return 'COMPLETED';
      case GeneratorRequestStatus.cancelled:
        return 'CANCELLED';
    }
  }
}

/// A structured model representing a resident's request for generator service.
class GeneratorRequest {
  /// Unique request identifier (e.g. 'GEN-1710000000000').
  final String id;

  /// The service type (e.g. 'ROUTINE SERVICING' or custom described service).
  final String serviceType;

  /// Whether the service was custom-specified by the resident.
  final bool isCustom;

  /// Optional generator description (e.g. '5kVA Firman' or '20kVA Mikano Diesel').
  final String? generator;

  /// Timing preference selected by the resident.
  final GeneratorTiming timing;

  /// Specific date and time if [timing] is [GeneratorTiming.scheduled].
  final DateTime? scheduledFor;

  /// Delivery/service location identifier. Currently defaults to 'estateAddress'.
  final String deliveryLocation;

  /// Optional additional instructions provided by the resident.
  final String? notes;

  /// Current lifecycle status of the request.
  final GeneratorRequestStatus status;

  /// Timestamp when the request was submitted.
  final DateTime createdAt;

  const GeneratorRequest({
    required this.id,
    required this.serviceType,
    required this.isCustom,
    this.generator,
    required this.timing,
    this.scheduledFor,
    required this.deliveryLocation,
    this.notes,
    required this.status,
    required this.createdAt,
  });

  /// Factory helper to create a new [GeneratorRequest] with generated defaults.
  factory GeneratorRequest.create({
    required String serviceType,
    bool isCustom = false,
    String? generator,
    required GeneratorTiming timing,
    DateTime? scheduledFor,
    String deliveryLocation = 'estateAddress',
    String? notes,
    GeneratorRequestStatus status = GeneratorRequestStatus.requested,
    DateTime? createdAt,
  }) {
    final now = createdAt ?? DateTime.now();
    final cleanGenerator = generator?.trim();
    final cleanNotes = notes?.trim();

    return GeneratorRequest(
      id: 'GEN-${now.microsecondsSinceEpoch}',
      serviceType: serviceType.trim(),
      isCustom: isCustom,
      generator: cleanGenerator != null && cleanGenerator.isNotEmpty
          ? cleanGenerator
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
