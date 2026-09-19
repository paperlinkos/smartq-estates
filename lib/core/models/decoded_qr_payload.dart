import 'dart:convert';

enum QrPayloadType {
  visitor,
  event,
  unrecognized;

  String get displayName {
    switch (this) {
      case QrPayloadType.visitor:
        return 'VISITOR PASS';
      case QrPayloadType.event:
        return 'EVENT PASS';
      case QrPayloadType.unrecognized:
        return 'UNRECOGNIZED';
    }
  }
}

/// Decoded QR payload model representing raw unverified fields extracted from a QR code.
/// 
/// IMPORTANT: This model does NOT represent a validated pass and does not imply
/// entry permission. Pass verification and access decisions are handled strictly in Phase 5C.
class DecodedQrPayload {
  final String rawData;
  final QrPayloadType type;
  final String? passId;
  final DateTime? issuedAt;
  final DateTime? expiresAt;
  final String? verificationToken;
  final String? rawStatus;
  final bool isValidFormat;

  const DecodedQrPayload({
    required this.rawData,
    required this.type,
    this.passId,
    this.issuedAt,
    this.expiresAt,
    this.verificationToken,
    this.rawStatus,
    required this.isValidFormat,
  });

  /// Factory for unrecognized/invalid QR codes
  factory DecodedQrPayload.unrecognized(String rawData) {
    return DecodedQrPayload(
      rawData: rawData,
      type: QrPayloadType.unrecognized,
      isValidFormat: false,
    );
  }

  /// Parses a raw scanned string into a [DecodedQrPayload].
  /// Handles JSON parsing, validation of required pass structure, and extracts only basic fields.
  /// Does NOT extract private resident info, phone numbers, or guest lists.
  static DecodedQrPayload parse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return DecodedQrPayload.unrecognized(raw);
    }

    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is! Map<String, dynamic>) {
        return DecodedQrPayload.unrecognized(raw);
      }

      final typeStr = decoded['type']?.toString().toLowerCase();
      final passId = decoded['passId']?.toString();
      final issuedAtStr = decoded['issuedAt']?.toString();
      final expiresAtStr = decoded['expiresAt']?.toString();
      final verificationToken = decoded['verificationToken']?.toString();
      final statusStr = decoded['status']?.toString();

      // Must have passId, verificationToken, and recognized type ('visitor' or 'event')
      if (passId == null ||
          passId.isEmpty ||
          verificationToken == null ||
          verificationToken.isEmpty) {
        return DecodedQrPayload.unrecognized(raw);
      }

      QrPayloadType payloadType;
      if (typeStr == 'visitor') {
        payloadType = QrPayloadType.visitor;
      } else if (typeStr == 'event') {
        payloadType = QrPayloadType.event;
      } else {
        return DecodedQrPayload.unrecognized(raw);
      }

      DateTime? issuedAt;
      if (issuedAtStr != null) {
        issuedAt = DateTime.tryParse(issuedAtStr);
      }

      DateTime? expiresAt;
      if (expiresAtStr != null) {
        expiresAt = DateTime.tryParse(expiresAtStr);
      }

      return DecodedQrPayload(
        rawData: raw,
        type: payloadType,
        passId: passId,
        issuedAt: issuedAt,
        expiresAt: expiresAt,
        verificationToken: verificationToken,
        rawStatus: statusStr,
        isValidFormat: true,
      );
    } catch (_) {
      // Any parsing or format error treats the QR code safely as unrecognized
      return DecodedQrPayload.unrecognized(raw);
    }
  }
}
