import 'dart:math';
import '../models/estate_event.dart';
import '../models/event_pass.dart';
import '../models/pass_type.dart';
import '../models/visitor_invitation.dart';
import '../models/visitor_pass.dart';

/// Architecture contract for QR code pass generation, representation,
/// and verification.
abstract class QrCodeService {
  /// Generates a structured payload token string for a given pass type.
  String generatePassToken({
    required String estateId,
    required String residentId,
    required PassType passType,
    required DateTime validFrom,
    required DateTime validUntil,
    Map<String, dynamic>? metadata,
  });

  /// Creates a full VisitorPass instance from a visitor invitation.
  VisitorPass createVisitorPass({
    required VisitorInvitation invitation,
    String estateId,
  });

  /// Creates a full EventPass instance from an estate event.
  EventPass createEventPass({
    required EstateEvent event,
    String estateId,
  });

  /// Verifies a scanned or retrieved pass token payload.
  bool verifyPassToken(String rawToken);

  /// Decodes payload contents without validation.
  Map<String, dynamic>? decodePassToken(String rawToken);
}

/// Concrete implementation for local token and pass generation.
class MockQrCodeService implements QrCodeService {
  final Random _random = Random();

  @override
  String generatePassToken({
    required String estateId,
    required String residentId,
    required PassType passType,
    required DateTime validFrom,
    required DateTime validUntil,
    Map<String, dynamic>? metadata,
  }) {
    return 'SMARTQ:$estateId:${passType.name}:$residentId:${validUntil.millisecondsSinceEpoch}';
  }

  @override
  VisitorPass createVisitorPass({
    required VisitorInvitation invitation,
    String estateId = 'est_001',
  }) {
    final now = DateTime.now();

    // Centralized expiration rule: scheduled arrival date + arrival time + 6 hours
    final scheduledArrival = DateTime(
      invitation.visitDate.year,
      invitation.visitDate.month,
      invitation.visitDate.day,
      invitation.arrivalTime.hour,
      invitation.arrivalTime.minute,
    );
    final expiresAt = scheduledArrival.add(const Duration(hours: 6));

    // Generate short human-readable pass ID (e.g. BT-8F42K)
    final passId = _generateShortPassId();

    // Generate unpredictable local verification token (never raw personal info)
    final tokenPart1 = _random.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase();
    final tokenPart2 = _random.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase();
    final verificationToken = 'VT-$tokenPart1-$tokenPart2';

    return VisitorPass(
      passId: passId,
      invitation: invitation,
      issuedAt: now,
      expiresAt: expiresAt,
      verificationToken: verificationToken,
      status: PassStatus.active,
    );
  }

  @override
  EventPass createEventPass({
    required EstateEvent event,
    String estateId = 'est_001',
  }) {
    final now = DateTime.now();

    // Centralized expiration rule: expiresAt = event end time on event date
    final expiresAt = DateTime(
      event.eventDate.year,
      event.eventDate.month,
      event.eventDate.day,
      event.endTime.hour,
      event.endTime.minute,
    );

    // Generate pass ID (e.g. EP-9K38B)
    final passId = _generateShortId(prefix: 'EP');

    // Generate human-readable event code (e.g. EV-7K4P9)
    final eventCode = _generateShortId(prefix: 'EV');

    // Generate unpredictable local verification token (never raw personal info)
    final tokenPart1 = _random.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase();
    final tokenPart2 = _random.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase();
    final verificationToken = 'VT-$tokenPart1-$tokenPart2';

    return EventPass(
      passId: passId,
      event: event,
      issuedAt: now,
      expiresAt: expiresAt,
      verificationToken: verificationToken,
      eventCode: eventCode,
      status: PassStatus.active,
    );
  }

  String _generateShortPassId() {
    return _generateShortId(prefix: 'BT');
  }

  String _generateShortId({required String prefix}) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final suffix = List.generate(5, (_) => chars[_random.nextInt(chars.length)]).join();
    return '$prefix-$suffix';
  }

  @override
  bool verifyPassToken(String rawToken) {
    return rawToken.startsWith('SMARTQ:') || rawToken.startsWith('{');
  }

  @override
  Map<String, dynamic>? decodePassToken(String rawToken) {
    if (!verifyPassToken(rawToken)) return null;
    if (rawToken.startsWith('SMARTQ:')) {
      final parts = rawToken.split(':');
      if (parts.length < 5) return null;
      return {
        'prefix': parts[0],
        'estateId': parts[1],
        'passType': parts[2],
        'residentId': parts[3],
        'expiresAt': int.tryParse(parts[4]),
      };
    }
    return null;
  }
}
