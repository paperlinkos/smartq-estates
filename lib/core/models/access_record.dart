import 'decoded_qr_payload.dart';

/// The nature of the access movement.
/// In Phase 5D, only [entry] is supported. [exit] is explicitly reserved for future phases.
enum AccessType {
  entry,
}

/// An immutable operational record of an access event at an estate gate.
///
/// Created ONLY when a security officer explicitly confirms entry for a valid pass.
/// A successful scan or verification does NOT automatically create an [AccessRecord].
class AccessRecord {
  /// Unique identifier for this log entry (e.g. 'AR-1710000000000').
  final String id;

  /// Identifier of the pass that authorized this entry.
  final String passId;

  /// Whether the pass was for an individual visitor or an estate event.
  final QrPayloadType passType;

  /// The movement type (always [AccessType.entry] in Phase 5D).
  final AccessType accessType;

  /// Name of the person or event granted entry.
  /// Sourced from the authoritative registry, never from unverified QR data.
  final String subjectName;

  /// Timestamp when entry was authorized by the security officer.
  final DateTime enteredAt;

  /// Identifier of the gate terminal where access was granted (e.g. 'GATE 1').
  final String gateId;

  /// Optional officer identifier who recorded the entry.
  final String? recordedBy;

  /// Record creation timestamp.
  final DateTime createdAt;

  const AccessRecord({
    required this.id,
    required this.passId,
    required this.passType,
    required this.accessType,
    required this.subjectName,
    required this.enteredAt,
    required this.gateId,
    this.recordedBy,
    required this.createdAt,
  });

  /// Convenience factory for generating an [AccessRecord] from verified entry parameters.
  factory AccessRecord.create({
    required String passId,
    required QrPayloadType passType,
    required String subjectName,
    required String gateId,
    String? recordedBy,
    DateTime? enteredAt,
  }) {
    final now = enteredAt ?? DateTime.now();
    return AccessRecord(
      id: 'AR-${now.microsecondsSinceEpoch}',
      passId: passId,
      passType: passType,
      accessType: AccessType.entry,
      subjectName: subjectName,
      enteredAt: now,
      gateId: gateId,
      recordedBy: recordedBy,
      createdAt: now,
    );
  }
}
