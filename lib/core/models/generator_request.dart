import 'service_request_item.dart';

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

/// A structured model representing a resident's request for generator maintenance or repair.
class GeneratorRequest implements ServiceRequestItem {
  /// Unique request identifier (e.g. 'GEN-1710000000000').
  @override
  final String id;

  /// Detailed description of the service, maintenance, or issue needed.
  final String serviceDescription;

  /// Optional generator type or model (e.g. '5kVA Firman' or '20kVA Mikano Soundproof Diesel').
  final String? generatorModel;

  /// Timing preference selected by the resident.
  final GeneratorTiming timing;

  /// Specific date and time if [timing] is [GeneratorTiming.scheduled].
  final DateTime? scheduledFor;

  /// Delivery/service location identifier. Currently defaults to 'estateAddress'.
  @override
  final String deliveryLocation;

  /// Optional additional instructions provided by the resident.
  @override
  final String? notes;

  /// Current lifecycle status of the request.
  final GeneratorRequestStatus status;

  /// Timestamp when the request was submitted.
  @override
  final DateTime createdAt;

  const GeneratorRequest({
    required this.id,
    required this.serviceDescription,
    this.generatorModel,
    required this.timing,
    this.scheduledFor,
    required this.deliveryLocation,
    this.notes,
    required this.status,
    required this.createdAt,
  });

  /// Factory helper to create a new [GeneratorRequest] with generated defaults.
  factory GeneratorRequest.create({
    required String serviceDescription,
    String? generatorModel,
    required GeneratorTiming timing,
    DateTime? scheduledFor,
    String deliveryLocation = 'estateAddress',
    String? notes,
    GeneratorRequestStatus status = GeneratorRequestStatus.requested,
    DateTime? createdAt,
  }) {
    final now = createdAt ?? DateTime.now();
    final cleanModel = generatorModel?.trim();
    final cleanNotes = notes?.trim();

    return GeneratorRequest(
      id: 'GEN-${now.microsecondsSinceEpoch}',
      serviceDescription: serviceDescription.trim(),
      generatorModel:
          cleanModel != null && cleanModel.isNotEmpty ? cleanModel : null,
      timing: timing,
      scheduledFor: scheduledFor,
      deliveryLocation: deliveryLocation,
      notes: cleanNotes != null && cleanNotes.isNotEmpty ? cleanNotes : null,
      status: status,
      createdAt: now,
    );
  }

  /// Creates a copy with modified values.
  GeneratorRequest copyWith({
    String? serviceDescription,
    String? generatorModel,
    GeneratorTiming? timing,
    DateTime? scheduledFor,
    String? deliveryLocation,
    String? notes,
    GeneratorRequestStatus? status,
  }) {
    return GeneratorRequest(
      id: id,
      serviceDescription: serviceDescription ?? this.serviceDescription,
      generatorModel: generatorModel ?? this.generatorModel,
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
  String get serviceTitle => 'GENERATOR';

  @override
  String get serviceType => 'generator';

  @override
  String get summaryText => generatorModel != null && generatorModel!.isNotEmpty
      ? '$generatorModel · $serviceDescription'
      : serviceDescription;

  @override
  String get timingDisplay {
    switch (timing) {
      case GeneratorTiming.asSoonAsPossible:
        return 'AS SOON AS POSSIBLE';
      case GeneratorTiming.laterToday:
        return 'LATER TODAY';
      case GeneratorTiming.scheduled:
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
      case GeneratorRequestStatus.requested:
        return ServiceOperationalPhase.requested;
      case GeneratorRequestStatus.assigned:
      case GeneratorRequestStatus.inProgress:
        return ServiceOperationalPhase.inProgress;
      case GeneratorRequestStatus.completed:
        return ServiceOperationalPhase.completed;
      case GeneratorRequestStatus.cancelled:
        return ServiceOperationalPhase.cancelled;
    }
  }

  @override
  bool get isActive =>
      status != GeneratorRequestStatus.completed &&
      status != GeneratorRequestStatus.cancelled;

  @override
  bool get canBeCancelled => status == GeneratorRequestStatus.requested;
}
