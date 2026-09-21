import '../models/decoded_qr_payload.dart';
import '../models/pass_verification_result.dart';
import '../models/visitor_pass.dart';
import '../repositories/pass_registry.dart';

/// Architecture contract for pass verification.
///
/// Accepts a decoded (but untrusted) QR payload and returns a structured
/// [PassVerificationResult]. The caller should never inspect the payload
/// directly to make an access decision.
///
/// This interface allows [LocalPassVerificationService] to be replaced with a
/// network-backed implementation that calls a real server endpoint.
abstract class PassVerificationService {
  /// Verifies a decoded QR payload against the known pass records.
  ///
  /// The scanned [payload] is treated as untrusted input. The verification
  /// service reads authoritative status and expiry from the registry record,
  /// not from any field in the payload.
  PassVerificationResult verify(DecodedQrPayload payload);
}

/// Local (in-memory) implementation of [PassVerificationService].
///
/// Looks up pass records in [PassRegistry] and applies the following rules:
///
/// For VISITOR passes:
///   1. Unrecognized QR format → [VerificationOutcome.unrecognized]
///   2. Pass not found in registry → [VerificationOutcome.invalid]
///   3. Token mismatch → [VerificationOutcome.invalid]
///   4. Pass status is cancelled → [VerificationOutcome.cancelled]
///   5. Current time >= expiresAt → [VerificationOutcome.expired]
///   6. All checks pass → [VerificationOutcome.valid]
///
/// For EVENT passes, the same rules apply.
///
/// SECURITY INVARIANT: Status and expiry are ALWAYS read from the registry
/// record. The QR payload's own `status` and `expiresAt` fields are ignored
/// for all access decisions.
class LocalPassVerificationService implements PassVerificationService {
  final PassRegistry _registry;

  LocalPassVerificationService({
    PassRegistry? registry,
  }) : _registry = registry ?? LocalPassRegistry.instance;

  /// Returns the current time. Centralized so it can be overridden in tests.
  DateTime _now() => DateTime.now();

  @override
  PassVerificationResult verify(DecodedQrPayload payload) {
    final now = _now();

    // Step 1: Reject unrecognized QR codes immediately.
    if (!payload.isValidFormat || payload.type == QrPayloadType.unrecognized) {
      return PassVerificationResult(
        outcome: VerificationOutcome.unrecognized,
        passType: QrPayloadType.unrecognized,
        passId: payload.passId,
        verifiedAt: now,
      );
    }

    // Step 2: Ensure the payload has the required identifiers.
    final passId = payload.passId;
    final scannedToken = payload.verificationToken;
    if (passId == null || passId.isEmpty || scannedToken == null || scannedToken.isEmpty) {
      return PassVerificationResult(
        outcome: VerificationOutcome.invalid,
        passType: payload.type,
        passId: passId,
        verifiedAt: now,
      );
    }

    if (payload.type == QrPayloadType.visitor) {
      return _verifyVisitor(passId: passId, scannedToken: scannedToken, now: now);
    } else if (payload.type == QrPayloadType.event) {
      return _verifyEvent(passId: passId, scannedToken: scannedToken, now: now);
    }

    // Should not be reachable given prior format checks, but treat as invalid.
    return PassVerificationResult(
      outcome: VerificationOutcome.invalid,
      passType: payload.type,
      passId: passId,
      verifiedAt: now,
    );
  }

  PassVerificationResult _verifyVisitor({
    required String passId,
    required String scannedToken,
    required DateTime now,
  }) {
    // Step 3: Look up in registry.
    final record = _registry.findVisitorPass(passId);
    if (record == null) {
      return PassVerificationResult(
        outcome: VerificationOutcome.invalid,
        passType: QrPayloadType.visitor,
        passId: passId,
        verifiedAt: now,
      );
    }

    // Step 4: Token must match the registry record (never the QR payload value alone).
    if (record.verificationToken != scannedToken) {
      return PassVerificationResult(
        outcome: VerificationOutcome.invalid,
        passType: QrPayloadType.visitor,
        passId: passId,
        verifiedAt: now,
      );
    }

    // Step 5: Check cancellation from registry record (not from QR payload).
    if (record.status == PassStatus.cancelled) {
      return PassVerificationResult(
        outcome: VerificationOutcome.cancelled,
        passType: QrPayloadType.visitor,
        passId: passId,
        verifiedAt: now,
      );
    }

    // Step 6: Check expiry using registry record's expiresAt and a single clock source.
    if (!now.isBefore(record.expiresAt)) {
      return PassVerificationResult(
        outcome: VerificationOutcome.expired,
        passType: QrPayloadType.visitor,
        passId: passId,
        verifiedAt: now,
      );
    }

    // Step 7: All checks passed — access is allowed.
    return PassVerificationResult(
      outcome: VerificationOutcome.valid,
      passType: QrPayloadType.visitor,
      passId: passId,
      verifiedAt: now,
      visitorPass: record,
    );
  }

  PassVerificationResult _verifyEvent({
    required String passId,
    required String scannedToken,
    required DateTime now,
  }) {
    // Step 3: Look up in registry.
    final record = _registry.findEventPass(passId);
    if (record == null) {
      return PassVerificationResult(
        outcome: VerificationOutcome.invalid,
        passType: QrPayloadType.event,
        passId: passId,
        verifiedAt: now,
      );
    }

    // Step 4: Token must match the registry record.
    if (record.verificationToken != scannedToken) {
      return PassVerificationResult(
        outcome: VerificationOutcome.invalid,
        passType: QrPayloadType.event,
        passId: passId,
        verifiedAt: now,
      );
    }

    // Step 5: Check cancellation from registry record.
    if (record.status == PassStatus.cancelled) {
      return PassVerificationResult(
        outcome: VerificationOutcome.cancelled,
        passType: QrPayloadType.event,
        passId: passId,
        verifiedAt: now,
      );
    }

    // Step 6: Check expiry using registry record.
    if (!now.isBefore(record.expiresAt)) {
      return PassVerificationResult(
        outcome: VerificationOutcome.expired,
        passType: QrPayloadType.event,
        passId: passId,
        verifiedAt: now,
      );
    }

    // Step 7: All checks passed.
    return PassVerificationResult(
      outcome: VerificationOutcome.valid,
      passType: QrPayloadType.event,
      passId: passId,
      verifiedAt: now,
      eventPass: record,
    );
  }
}
