import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/service_request_item.dart';
import '../../core/services/service_coordinator.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';

/// Management operational inspection and status control screen for a resident service request.
class ManagementRequestDetailScreen extends StatefulWidget {
  final ServiceRequestItem request;
  final ServiceCoordinator? coordinator;

  const ManagementRequestDetailScreen({
    super.key,
    required this.request,
    this.coordinator,
  });

  @override
  State<ManagementRequestDetailScreen> createState() =>
      _ManagementRequestDetailScreenState();
}

class _ManagementRequestDetailScreenState
    extends State<ManagementRequestDetailScreen> {
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

  void _handleStartRequest() {
    final success = _coordinator.startRequest(_request.id);
    if (success) {
      _reloadRequest();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request accepted and moved to IN PROGRESS.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleCompleteRequest() {
    final success = _coordinator.completeRequest(_request.id);
    if (success) {
      _reloadRequest();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request marked as COMPLETED.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final phase = _request.operationalPhase;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: AppStrings.managementRequestDetailTitle,
        subtitle: AppStrings.managementRequestDetailSubtitle,
        showBackButton: true,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 3-Step Lifecycle Timeline ─────────────────────────────────
              _buildProgressTimeline(),

              const SizedBox(height: 20),

              // ── Requester Information Card ────────────────────────────────
              _buildSectionTitle(AppStrings.requesterInfoTitle),
              const SizedBox(height: 8),
              AppCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _buildInfoRow(
                      icon: Icons.person_outline_rounded,
                      label: AppStrings.labelRequesterName,
                      value: _request.residentName,
                    ),
                    const Divider(height: 22),
                    _buildInfoRow(
                      icon: Icons.home_work_outlined,
                      label: AppStrings.labelUnitEstate,
                      value: _request.unitOrEstate,
                    ),
                    const Divider(height: 22),
                    _buildInfoRow(
                      icon: Icons.access_time_rounded,
                      label: AppStrings.labelSubmittedAt,
                      value: _formatDate(_request.createdAt),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Request Details Card ──────────────────────────────────────
              _buildSectionTitle('SERVICE SPECIFICATIONS'),
              const SizedBox(height: 8),
              AppCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    const Divider(height: 24),
                    _buildLabel('SERVICE DETAILS'),
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
                    const Divider(height: 24),
                    _buildLabel(AppStrings.labelWhen),
                    const SizedBox(height: 6),
                    Text(
                      _request.timingDisplay,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Divider(height: 24),
                    _buildLabel(AppStrings.labelDeliverTo),
                    const SizedBox(height: 6),
                    Text(
                      _request.deliveryLocation,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (_request.notes != null &&
                        _request.notes!.trim().isNotEmpty) ...[
                      const Divider(height: 24),
                      _buildLabel(AppStrings.labelNotes),
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

              const SizedBox(height: 28),

              // ── Management Action Buttons ─────────────────────────────────
              if (phase == ServiceOperationalPhase.requested) ...[
                ElevatedButton(
                  onPressed: _handleStartRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.black,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow_rounded, size: 20),
                      SizedBox(width: 8),
                      Text(
                        AppStrings.actionAcceptAndStart,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (phase == ServiceOperationalPhase.inProgress) ...[
                ElevatedButton(
                  onPressed: _handleCompleteRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.black,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 20),
                      SizedBox(width: 8),
                      Text(
                        AppStrings.actionMarkCompleted,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (phase == ServiceOperationalPhase.completed) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Text(
                      AppStrings.statusCompletedNotice,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ] else if (phase == ServiceOperationalPhase.cancelled) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Text(
                      AppStrings.requestCancelledNotice,
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.black),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
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

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
