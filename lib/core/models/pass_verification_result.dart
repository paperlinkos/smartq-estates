import 'decoded_qr_payload.dart';
import 'event_pass.dart';
import 'visitor_pass.dart';

/// The possible outcomes of a pass verification attempt.
enum VerificationOutcome {
  /// Pass exists, token matches, is active, and is not expired.
  valid,

  /// Pass was found but its expiry time has passed.
  expired,

  /// Pass was found but the resident cancelled it.
  cancelled,

  /// Pass could not be found, or the token does not match the registry record.
  invalid,

  /// The scanned QR code is not a SmartQ pass at all.
  unrecognized;

  /// Returns true if the outcome permits entry.
  bool get isAllowed => this == VerificationOutcome.valid;

  /// Returns a human-readable denial reason for display on the result screen.
  /// Only meaningful when [isAllowed] is false.
  String get denialLabel {
    switch (this) {
      case VerificationOutcome.expired:
        return 'PASS EXPIRED';
      case VerificationOutcome.cancelled:
        return 'PASS CANCELLED';
      case VerificationOutcome.invalid:
        return 'PASS COULD NOT BE VERIFIED';
      case VerificationOutcome.unrecognized:
        return 'UNRECOGNIZED QR CODE';
      case VerificationOutcome.valid:
        return '';
    }
  }

  /// Returns supporting explanatory text for the denial reason.
  String get denialBody {
    switch (this) {
      case VerificationOutcome.expired:
        return 'This pass is no longer active.';
      case VerificationOutcome.cancelled:
        return 'This pass has been cancelled by the resident.';
      case VerificationOutcome.invalid:
        return 'The pass is not recognized by this estate.';
      case VerificationOutcome.unrecognized:
        return 'This QR code is not a SmartQ access pass.';
      case VerificationOutcome.valid:
        return '';
    }
  }
}

/// The structured result returned by [PassVerificationService.verify].
///
/// Contains the outcome, the matched pass object (if found), and metadata.
/// The UI layer should only read [outcome] to make the access decision — it
/// must never attempt to re-verify or override the outcome.
class PassVerificationResult {
  /// The authoritative access decision.
  final VerificationOutcome outcome;

  /// The type of pass that was scanned (visitor, event, or unrecognized).
  final QrPayloadType passType;

  /// The pass ID extracted from the QR payload, if available.
  final String? passId;

  /// Timestamp at which the verification was performed.
  final DateTime verifiedAt;

  /// Populated when outcome is [VerificationOutcome.valid] and type is visitor.
  /// Contains the full pass record from the registry — do NOT expose phone number
  /// or resident private info in the UI.
  final VisitorPass? visitorPass;

  /// Populated when outcome is [VerificationOutcome.valid] and type is event.
  final EventPass? eventPass;

  const PassVerificationResult({
    required this.outcome,
    required this.passType,
    this.passId,
    required this.verifiedAt,
    this.visitorPass,
    this.eventPass,
  });

  /// Convenience: true when access should be granted.
  bool get isAllowed => outcome.isAllowed;
}
