import 'dart:convert';
import 'estate_event.dart';
import 'visitor_pass.dart'; // Reusing PassStatus (active, cancelled, expired)

/// Model representing an authorized multi-guest Event Access Pass.
///
/// Distinct from VisitorPass (which represents ONE PERSON -> ONE PASS).
/// EventPass represents ONE EVENT -> MANY GUESTS -> ONE EVENT ACCESS PASS.
class EventPass {
  final String passId;
  final EstateEvent event;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final String verificationToken;
  final String eventCode;
  final PassStatus status;

  const EventPass({
    required this.passId,
    required this.event,
    required this.issuedAt,
    required this.expiresAt,
    required this.verificationToken,
    required this.eventCode,
    this.status = PassStatus.active,
  });

  bool get isActive => status == PassStatus.active && DateTime.now().isBefore(expiresAt);

  EventPass copyWith({
    PassStatus? status,
  }) {
    return EventPass(
      passId: passId,
      event: event,
      issuedAt: issuedAt,
      expiresAt: expiresAt,
      verificationToken: verificationToken,
      eventCode: eventCode,
      status: status ?? this.status,
    );
  }

  /// Encodes a structured temporary verification token payload as JSON string.
  /// IMPORTANT: Does NOT encode phone number, resident private details, or personal guest data.
  String toQrPayload() {
    final payload = {
      'passId': passId,
      'type': 'event',
      'issuedAt': issuedAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'verificationToken': verificationToken,
      'status': status.name,
    };
    return jsonEncode(payload);
  }

  /// Formats concise, share-ready invitation text for guests (e.g. WhatsApp, SMS).
  String toShareText({String estateName = 'Pinecrest Royal Estate'}) {
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    final weekday = weekdays[event.eventDate.weekday - 1];
    final dateStr = '$weekday, ${event.eventDate.day} ${months[event.eventDate.month - 1]} ${event.eventDate.year}';

    String formatTime(int hour, int minute) {
      final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final p = hour >= 12 ? 'PM' : 'AM';
      final m = minute.toString().padLeft(2, '0');
      return '$h:$m $p';
    }

    final startStr = formatTime(event.startTime.hour, event.startTime.minute);
    final endStr = formatTime(event.endTime.hour, event.endTime.minute);

    final buffer = StringBuffer();
    buffer.writeln("You're invited to ${event.name}.");
    buffer.writeln();
    buffer.writeln(dateStr);
    buffer.writeln('$startStr – $endStr');
    buffer.writeln();
    buffer.writeln('Event code: $eventCode');
    if (estateName.isNotEmpty) {
      buffer.writeln('Location: $estateName');
    }
    buffer.writeln();
    buffer.writeln('Please show the event QR/code at the estate entrance.');
    return buffer.toString();
  }
}
