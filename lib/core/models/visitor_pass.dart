import 'dart:convert';
import 'visitor_invitation.dart';

enum PassStatus {
  active,
  cancelled,
  expired;

  String get displayName {
    switch (this) {
      case PassStatus.active:
        return 'ACTIVE';
      case PassStatus.cancelled:
        return 'CANCELLED';
      case PassStatus.expired:
        return 'EXPIRED';
    }
  }
}

class VisitorPass {
  final String passId;
  final VisitorInvitation invitation;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final String verificationToken;
  final PassStatus status;

  const VisitorPass({
    required this.passId,
    required this.invitation,
    required this.issuedAt,
    required this.expiresAt,
    required this.verificationToken,
    this.status = PassStatus.active,
  });

  bool get isActive => status == PassStatus.active && DateTime.now().isBefore(expiresAt);

  VisitorPass copyWith({
    PassStatus? status,
  }) {
    return VisitorPass(
      passId: passId,
      invitation: invitation,
      issuedAt: issuedAt,
      expiresAt: expiresAt,
      verificationToken: verificationToken,
      status: status ?? this.status,
    );
  }

  /// Encodes a structured temporary verification token payload as JSON string.
  /// IMPORTANT: Does NOT encode phone number, resident private details, or raw database info.
  String toQrPayload() {
    final payload = {
      'passId': passId,
      'type': 'visitor',
      'issuedAt': issuedAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'verificationToken': verificationToken,
      'status': status.name,
    };
    return jsonEncode(payload);
  }

  /// Formats clean share-ready text for messaging apps (WhatsApp, SMS, etc.)
  String toShareText({String estateName = 'Pinecrest Royal Estate'}) {
    final dateStr =
        '${invitation.visitDate.day}/${invitation.visitDate.month}/${invitation.visitDate.year}';
    final hour = invitation.arrivalTime.hourOfPeriod == 0 ? 12 : invitation.arrivalTime.hourOfPeriod;
    final period = invitation.arrivalTime.period.name.toUpperCase();
    final minute = invitation.arrivalTime.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$minute $period';

    final buffer = StringBuffer();
    buffer.writeln('SMARTQ VISITOR PASS');
    buffer.writeln('Estate: $estateName');
    buffer.writeln('Visitor: ${invitation.visitorName}');
    buffer.writeln('Date: $dateStr');
    buffer.writeln('Arrival: $timeStr');
    buffer.writeln('Pass ID: $passId');
    buffer.writeln('Status: ${status.displayName}');
    if (invitation.hasVehicle) {
      if (invitation.vehiclePlate != null) {
        buffer.writeln('Vehicle Plate: ${invitation.vehiclePlate}');
      }
      if (invitation.vehicleDescription != null) {
        buffer.writeln('Vehicle: ${invitation.vehicleDescription}');
      }
    }
    buffer.writeln('\nPlease show this pass at the security gate upon arrival.');
    return buffer.toString();
  }
}
