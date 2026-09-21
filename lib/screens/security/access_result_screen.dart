import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/access_record.dart';
import '../../core/models/decoded_qr_payload.dart';
import '../../core/models/event_pass.dart';
import '../../core/models/pass_verification_result.dart';
import '../../core/models/visitor_pass.dart';
import '../../core/repositories/access_log_repository.dart';
import '../../core/services/pass_verification_service.dart';
import '../../navigation/app_router.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';

/// The definitive access decision screen for Phase 5C & 5D.
///
/// Receives a [DecodedQrPayload] from the scanner, runs it through
/// [PassVerificationService], and presents either ACCESS ALLOWED or ACCESS DENIED
/// to the security officer.
///
/// On ACCESS ALLOWED, the officer may tap [ALLOW ENTRY] to record entry in the
/// estate access log.
class AccessResultScreen extends StatefulWidget {
  final DecodedQrPayload payload;

  /// Allows injecting a custom service in tests (bypasses LocalPassRegistry).
  final PassVerificationService? verificationService;

  /// Allows injecting a custom access log repository in tests.
  final AccessLogRepository? accessLogRepository;

  const AccessResultScreen({
    super.key,
    required this.payload,
    this.verificationService,
    this.accessLogRepository,
  });

  @override
  State<AccessResultScreen> createState() => _AccessResultScreenState();
}

class _AccessResultScreenState extends State<AccessResultScreen> {
  late final PassVerificationResult _result;
  late final AccessLogRepository _accessLogRepo;
  bool _checkedIn = false;
  AccessRecord? _accessRecord;

  @override
  void initState() {
    super.initState();
    final service = widget.verificationService ?? LocalPassVerificationService();
    _result = service.verify(widget.payload);
    _accessLogRepo = widget.accessLogRepository ?? LocalAccessLogRepository.instance;
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

  String _formatDateTime(DateTime dt) {
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  Future<void> _confirmAllowEntry() async {
    final subjectName = _result.visitorPass?.invitation.visitorName ??
        _result.eventPass?.event.name ??
        _result.passId ??
        '';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        title: const Text(
          AppStrings.allowEntryConfirmTitle,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: 0.5,
          ),
        ),
        content: Text(
          subjectName,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              AppStrings.allowEntryConfirmCancel,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              AppStrings.allowEntryAction,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final record = _accessLogRepo.recordEntry(
        result: _result,
        gateId: 'GATE 1',
      );
      setState(() {
        _checkedIn = true;
        _accessRecord = record;
      });
    }
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

              const SizedBox(height: 24),

              // ── Phase 5D: ALLOW ENTRY or ENTRY RECORDED ─────────────────
              if (isAllowed) ...[
                if (!_checkedIn) ...[
                  AppButton(
                    text: AppStrings.allowEntryAction,
                    onPressed: _confirmAllowEntry,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    AppStrings.allowEntrySubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  _EntryRecordedCard(
                    record: _accessRecord!,
                    formatDateTime: _formatDateTime,
                  ),
                  const SizedBox(height: 20),
                ],

                // ── DONE (only on allowed) ──────────────────────────────────
                AppButton(
                  text: AppStrings.doneAction,
                  variant: _checkedIn
                      ? AppButtonVariant.primary
                      : AppButtonVariant.secondary,
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
                variant: AppButtonVariant.secondary,
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

// ─── Entry Recorded Card ─────────────────────────────────────────────────────

class _EntryRecordedCard extends StatelessWidget {
  final AccessRecord record;
  final String Function(DateTime) formatDateTime;

  const _EntryRecordedCard({
    required this.record,
    required this.formatDateTime,
  });

  @override
  Widget build(BuildContext context) {
    final isVisitor = record.passType == QrPayloadType.visitor;

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_rounded, color: AppColors.white, size: 14),
                    SizedBox(width: 5),
                    Text(
                      AppStrings.entryRecordedTitle,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DetailRow(
            label: isVisitor
                ? AppStrings.labelVisitorSection
                : AppStrings.labelEventAccess,
            value: record.subjectName,
            isPrimary: true,
          ),
          const Divider(height: 22),
          Row(
            children: [
              Expanded(
                child: _DetailRow(
                  label: AppStrings.labelEntry,
                  value: formatDateTime(record.enteredAt),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DetailRow(
                  label: AppStrings.labelGate,
                  value: record.gateId,
                ),
              ),
            ],
          ),
          const Divider(height: 22),
          _DetailRow(
            label: isVisitor ? AppStrings.labelPass : AppStrings.labelEventCode,
            value: record.passId,
            isMonospace: true,
          ),
        ],
      ),
    );
  }
}

