import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/decoded_qr_payload.dart';
import '../../core/models/event_pass.dart';
import '../../core/models/pass_verification_result.dart';
import '../../core/models/visitor_pass.dart';
import '../../core/services/pass_verification_service.dart';
import '../../navigation/app_router.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';

/// The definitive access decision screen for Phase 5C.
///
/// Receives a [DecodedQrPayload] from the scanner, runs it through
/// [PassVerificationService], and presents either ACCESS ALLOWED or ACCESS DENIED
/// to the security officer.
///
/// This screen runs verification in [initState] — it does not expose
/// the payload's own status fields to make any decisions. The service
/// is the sole decision-maker.
class AccessResultScreen extends StatefulWidget {
  final DecodedQrPayload payload;

  /// Allows injecting a custom service in tests (bypasses LocalPassRegistry).
  final PassVerificationService? verificationService;

  const AccessResultScreen({
    super.key,
    required this.payload,
    this.verificationService,
  });

  @override
  State<AccessResultScreen> createState() => _AccessResultScreenState();
}

class _AccessResultScreenState extends State<AccessResultScreen> {
  late final PassVerificationResult _result;

  @override
  void initState() {
    super.initState();
    final service = widget.verificationService ?? LocalPassVerificationService();
    _result = service.verify(widget.payload);
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]}, ${dt.year}';
  }

  String _formatTimeOfDay(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    final minute = t.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final isAllowed = _result.isAllowed;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: isAllowed ? AppStrings.accessAllowed : AppStrings.accessDenied,
        subtitle: isAllowed
            ? (_result.passType == QrPayloadType.visitor
                ? 'VISITOR PASS VERIFIED'
                : 'EVENT PASS VERIFIED')
            : _result.outcome.denialLabel,
        showBackButton: true,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Primary decision badge ──────────────────────────────────
              _DecisionBadge(result: _result),

              const SizedBox(height: 16),

              // ── Pass detail content ─────────────────────────────────────
              if (isAllowed && _result.visitorPass != null)
                _VisitorPassDetail(
                  visitorPass: _result.visitorPass!,
                  formatDate: _formatDate,
                  formatTime: _formatTimeOfDay,
                ),

              if (isAllowed && _result.eventPass != null)
                _EventPassDetail(
                  eventPass: _result.eventPass!,
                  formatDate: _formatDate,
                  formatTime: _formatTimeOfDay,
                ),

              if (!isAllowed) _DenialDetail(result: _result),

              const SizedBox(height: 28),

              // ── DONE (only on allowed) ──────────────────────────────────
              if (isAllowed) ...[
                AppButton(
                  text: AppStrings.doneAction,
                  onPressed: () {
                    Navigator.of(context).popUntil(
                      ModalRoute.withName(AppRouter.security),
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],

              // ── SCAN AGAIN (always present) ─────────────────────────────
              AppButton(
                text: AppStrings.scanAgainAction,
                variant: isAllowed ? AppButtonVariant.secondary : AppButtonVariant.primary,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Decision Badge ──────────────────────────────────────────────────────────

class _DecisionBadge extends StatelessWidget {
  final PassVerificationResult result;

  const _DecisionBadge({required this.result});

  @override
  Widget build(BuildContext context) {
    final isAllowed = result.isAllowed;

    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon mark
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isAllowed ? AppColors.black : AppColors.gray100,
              borderRadius: BorderRadius.circular(18),
              border: isAllowed ? null : Border.all(color: AppColors.gray300, width: 1.5),
            ),
            child: Center(
              child: Icon(
                isAllowed ? Icons.check_rounded : Icons.block_rounded,
                color: isAllowed ? AppColors.white : AppColors.black,
                size: 34,
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Primary decision headline
          Text(
            isAllowed ? AppStrings.accessAllowed : AppStrings.accessDenied,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),

          // Denial reason sub-headline
          if (!isAllowed) ...[
            const SizedBox(height: 8),
            Text(
              result.outcome.denialLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Visitor Pass Detail ─────────────────────────────────────────────────────

class _VisitorPassDetail extends StatelessWidget {
  final VisitorPass visitorPass;
  final String Function(DateTime) formatDate;
  final String Function(TimeOfDay) formatTime;

  const _VisitorPassDetail({
    required this.visitorPass,
    required this.formatDate,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    final invitation = visitorPass.invitation;
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailRow(
            label: AppStrings.labelVisitorSection,
            value: invitation.visitorName,
            isPrimary: true,
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: _DetailRow(
                  label: AppStrings.labelDate,
                  value: formatDate(invitation.visitDate),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DetailRow(
                  label: AppStrings.labelArrival,
                  value: formatTime(invitation.arrivalTime),
                ),
              ),
            ],
          ),
          if (invitation.hasVehicle) ...[
            const Divider(height: 24),
            _DetailRow(
              label: AppStrings.labelVehicleSection,
              value: [
                if (invitation.vehiclePlate != null &&
                    invitation.vehiclePlate!.trim().isNotEmpty)
                  invitation.vehiclePlate!.trim(),
                if (invitation.vehicleDescription != null &&
                    invitation.vehicleDescription!.trim().isNotEmpty)
                  invitation.vehicleDescription!.trim(),
              ].join(' · '),
            ),
          ],
          const Divider(height: 24),
          _DetailRow(
            label: AppStrings.labelPass,
            value: visitorPass.passId,
            isMonospace: true,
          ),
        ],
      ),
    );
  }
}

// ─── Event Pass Detail ───────────────────────────────────────────────────────

class _EventPassDetail extends StatelessWidget {
  final EventPass eventPass;
  final String Function(DateTime) formatDate;
  final String Function(TimeOfDay) formatTime;

  const _EventPassDetail({
    required this.eventPass,
    required this.formatDate,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    final event = eventPass.event;
    final timeRange =
        '${formatTime(event.startTime)} – ${formatTime(event.endTime)}';
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailRow(
            label: AppStrings.labelEventSection,
            value: event.name,
            isPrimary: true,
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: _DetailRow(
                  label: AppStrings.labelDate,
                  value: formatDate(event.eventDate),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DetailRow(
                  label: AppStrings.labelArrival,
                  value: timeRange,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _DetailRow(
            label: AppStrings.labelEventCode,
            value: eventPass.eventCode,
            isMonospace: true,
          ),
          const Divider(height: 24),
          _DetailRow(
            label: AppStrings.labelGuests,
            value: '${event.expectedGuests}',
          ),
        ],
      ),
    );
  }
}

// ─── Denial Detail ───────────────────────────────────────────────────────────

class _DenialDetail extends StatelessWidget {
  final PassVerificationResult result;

  const _DenialDetail({required this.result});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (result.passId != null) ...[
            _DetailRow(
              label: AppStrings.labelPassId,
              value: result.passId!,
              isMonospace: true,
            ),
            const Divider(height: 20),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: AppColors.gray500,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  result.outcome.denialBody,
                  style: const TextStyle(
                    color: AppColors.gray600,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Shared helper widget ────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isPrimary;
  final bool isMonospace;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isPrimary = false,
    this.isMonospace = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textTertiary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: isPrimary ? 18 : 14.5,
            fontWeight: isPrimary ? FontWeight.w800 : FontWeight.w600,
            letterSpacing: isMonospace ? 0.8 : 0.0,
          ),
        ),
      ],
    );
  }
}
