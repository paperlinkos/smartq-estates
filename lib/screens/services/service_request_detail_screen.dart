import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/service_request_item.dart';
import '../../core/services/service_coordinator.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';

/// Screen displaying the full details and live status lifecycle of a service request.
class ServiceRequestDetailScreen extends StatefulWidget {
  final ServiceRequestItem request;
  final ServiceCoordinator? coordinator;

  const ServiceRequestDetailScreen({
    super.key,
    required this.request,
    this.coordinator,
  });

  @override
  State<ServiceRequestDetailScreen> createState() =>
      _ServiceRequestDetailScreenState();
}

class _ServiceRequestDetailScreenState
    extends State<ServiceRequestDetailScreen> {
  late ServiceRequestItem _request;

  ServiceCoordinator get _coordinator =>
      widget.coordinator ?? ServiceCoordinator.instance;

  @override
  void initState() {
    super.initState();
    _request = widget.request;
  }

  void _reloadRequest() {
    final refreshed = _coordinator.getRequestById(_request.id);
    if (refreshed != null) {
      setState(() => _request = refreshed);
    }
  }

  Future<void> _showCancelConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            AppStrings.cancelDialogTitle,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          content: const Text(
            AppStrings.cancelDialogContent,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                AppStrings.actionKeepRequest,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.black,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                AppStrings.actionConfirmCancel,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final success = _coordinator.cancelRequest(_request.id);
      if (success) {
        _reloadRequest();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: AppStrings.requestDetailTitle,
        subtitle: AppStrings.requestDetailSubtitle,
        showBackButton: true,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 3-Step Monochrome Timeline ────────────────────────────────
              _buildProgressTimeline(),

              const SizedBox(height: 20),

              // ── Request Summary Details Card ──────────────────────────────
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row: Service Title & Status Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _request.serviceTitle,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        _buildStatusBadge(),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _request.id,
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const Divider(height: 28),

                    // Service Payload / Summary
                    _buildSectionHeader('SERVICE DETAILS'),
                    const SizedBox(height: 6),
                    Text(
                      _request.summaryText,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),

                    const Divider(height: 28),

                    // When / Timing
                    _buildSectionHeader(AppStrings.labelWhen),
                    const SizedBox(height: 6),
                    Text(
                      _request.timingDisplay,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),

                    const Divider(height: 28),

                    // Delivery Location
                    _buildSectionHeader(AppStrings.labelDeliverTo),
                    const SizedBox(height: 6),
                    Text(
                      _request.deliveryLocation,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),

                    if (_request.notes != null &&
                        _request.notes!.trim().isNotEmpty) ...[
                      const Divider(height: 28),
                      _buildSectionHeader(AppStrings.labelNotes),
                      const SizedBox(height: 6),
                      Text(
                        _request.notes!,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Cancel Request Action (Only while in REQUESTED status) ─────
              if (_request.canBeCancelled)
                OutlinedButton(
                  onPressed: _showCancelConfirmation,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.black,
                    side: const BorderSide(color: AppColors.border, width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    AppStrings.actionCancelRequest,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

              if (_request.operationalPhase ==
                  ServiceOperationalPhase.cancelled)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      AppStrings.requestCancelledNotice,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressTimeline() {
    final phase = _request.operationalPhase;
    final isCancelled = phase == ServiceOperationalPhase.cancelled;

    int activeStep;
    if (isCancelled) {
      activeStep = 0;
    } else {
      switch (phase) {
        case ServiceOperationalPhase.requested:
          activeStep = 1;
          break;
        case ServiceOperationalPhase.inProgress:
          activeStep = 2;
          break;
        case ServiceOperationalPhase.completed:
          activeStep = 3;
          break;
        case ServiceOperationalPhase.cancelled:
          activeStep = 0;
          break;
      }
    }

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          Row(
            children: [
              _buildTimelineStepNode(
                stepNumber: 1,
                label: AppStrings.timelineStep1,
                isCompleted: activeStep > 1,
                isActive: activeStep == 1 && !isCancelled,
              ),
              _buildTimelineConnector(isCompleted: activeStep > 1),
              _buildTimelineStepNode(
                stepNumber: 2,
                label: AppStrings.timelineStep2,
                isCompleted: activeStep > 2,
                isActive: activeStep == 2,
              ),
              _buildTimelineConnector(isCompleted: activeStep > 2),
              _buildTimelineStepNode(
                stepNumber: 3,
                label: AppStrings.timelineStep3,
                isCompleted: activeStep == 3,
                isActive: activeStep == 3,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStepNode({
    required int stepNumber,
    required String label,
    required bool isCompleted,
    required bool isActive,
  }) {
    Color bg;
    Color border;
    Color contentColor;

    if (isCompleted) {
      bg = AppColors.black;
      border = AppColors.black;
      contentColor = AppColors.white;
    } else if (isActive) {
      bg = AppColors.surface;
      border = AppColors.black;
      contentColor = AppColors.black;
    } else {
      bg = AppColors.gray100;
      border = AppColors.border;
      contentColor = AppColors.gray400;
    }

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              border: Border.all(color: border, width: 1.5),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: AppColors.white,
                    )
                  : Text(
                      '$stepNumber',
                      style: TextStyle(
                        color: contentColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive || isCompleted
                  ? AppColors.textPrimary
                  : AppColors.textTertiary,
              fontSize: 10,
              fontWeight:
                  isActive || isCompleted ? FontWeight.w800 : FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineConnector({required bool isCompleted}) {
    return Container(
      width: 32,
      height: 2,
      margin: const EdgeInsets.only(bottom: 18),
      color: isCompleted ? AppColors.black : AppColors.border,
    );
  }

  Widget _buildStatusBadge() {
    final status = _request.statusDisplayName;
    final phase = _request.operationalPhase;

    Color bg;
    Color text;
    Border? border;

    switch (phase) {
      case ServiceOperationalPhase.requested:
        bg = AppColors.surface;
        text = AppColors.black;
        border = Border.all(color: AppColors.black, width: 1.2);
        break;
      case ServiceOperationalPhase.inProgress:
        bg = AppColors.black;
        text = AppColors.white;
        border = null;
        break;
      case ServiceOperationalPhase.completed:
        bg = AppColors.gray100;
        text = AppColors.textSecondary;
        border = Border.all(color: AppColors.border);
        break;
      case ServiceOperationalPhase.cancelled:
        bg = AppColors.gray50;
        text = AppColors.gray500;
        border = Border.all(color: AppColors.border);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: border,
      ),
      child: Text(
        status,
        style: TextStyle(
          color: text,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }
}
