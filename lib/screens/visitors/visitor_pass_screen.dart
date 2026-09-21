import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/visitor_pass.dart';
import '../../core/repositories/pass_registry.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';

class VisitorPassScreen extends StatefulWidget {
  final VisitorPass pass;

  const VisitorPassScreen({
    super.key,
    required this.pass,
  });

  @override
  State<VisitorPassScreen> createState() => _VisitorPassScreenState();
}

class _VisitorPassScreenState extends State<VisitorPassScreen> {
  late VisitorPass _pass;

  @override
  void initState() {
    super.initState();
    _pass = widget.pass;
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  String _formatDateTime(DateTime dt) {
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${_formatDate(dt)} at $hour:$minute $period';
  }

  void _onSharePass() {
    final text = _pass.toShareText();
    SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: 'SmartQ Visitor Pass - ${_pass.invitation.visitorName}',
      ),
    );
  }

  Future<void> _onCancelPass() async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            AppStrings.cancelPassDialogTitle,
            style: TextStyle(
              color: AppColors.black,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          content: const Text(
            AppStrings.cancelPassDialogContent,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                AppStrings.keepPassAction,
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                AppStrings.confirmCancelAction,
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldCancel == true && mounted) {
      final cancelled = _pass.copyWith(status: PassStatus.cancelled);
      // Sync cancellation to the registry so Security reflects the change.
      LocalPassRegistry.instance.updateVisitorPass(cancelled);
      setState(() {
        _pass = cancelled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final invitation = _pass.invitation;
    final isCancelled = _pass.status == PassStatus.cancelled;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(
        title: AppStrings.visitorPassHeader,
        subtitle: AppStrings.visitorPassExpected,
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Pass Card
              AppCard(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Bar: Pass ID & Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              AppStrings.labelPass,
                              style: TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _pass.passId,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isCancelled ? AppColors.gray100 : AppColors.black,
                            borderRadius: BorderRadius.circular(100),
                            border: isCancelled
                                ? Border.all(color: Colors.red.shade700, width: 1.2)
                                : null,
                          ),
                          child: Text(
                            _pass.status.displayName,
                            style: TextStyle(
                              color: isCancelled ? Colors.red.shade700 : AppColors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 28),

                    // Visitor Name
                    _buildField(
                      label: AppStrings.labelVisitor,
                      value: invitation.visitorName,
                      isPrimary: true,
                    ),

                    const SizedBox(height: 16),

                    // Date and Arrival Time in Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            label: AppStrings.labelDate,
                            value: _formatDate(invitation.visitDate),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            label: AppStrings.labelArrival,
                            value: _formatTimeOfDay(invitation.arrivalTime),
                          ),
                        ),
                      ],
                    ),

                    // Vehicle Section (Only shown if information exists)
                    if (invitation.hasVehicle) ...[
                      const SizedBox(height: 16),
                      _buildField(
                        label: AppStrings.sectionVehicle,
                        value: [
                          if (invitation.vehiclePlate != null &&
                              invitation.vehiclePlate!.trim().isNotEmpty)
                            invitation.vehiclePlate!.trim(),
                          if (invitation.vehicleDescription != null &&
                              invitation.vehicleDescription!.trim().isNotEmpty)
                            invitation.vehicleDescription!.trim(),
                        ].join(' • '),
                      ),
                    ],

                    const Divider(height: 32),

                    // QR Code Container
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border, width: 1.2),
                            ),
                            child: isCancelled
                                ? Container(
                                    width: 190,
                                    height: 190,
                                    decoration: BoxDecoration(
                                      color: AppColors.gray50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.block_rounded,
                                            size: 44,
                                            color: Colors.red.shade700,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'PASS CANCELLED',
                                            style: TextStyle(
                                              color: Colors.red.shade700,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.6,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : QrImageView(
                                    data: _pass.toQrPayload(),
                                    version: QrVersions.auto,
                                    size: 190.0,
                                    eyeStyle: const QrEyeStyle(
                                      eyeShape: QrEyeShape.square,
                                      color: AppColors.black,
                                    ),
                                    dataModuleStyle: const QrDataModuleStyle(
                                      dataModuleShape: QrDataModuleShape.square,
                                      color: AppColors.black,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            AppStrings.showCodeAtEntrance,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${AppStrings.labelExpires}: ${_formatDateTime(_pass.expiresAt)}',
                            style: const TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action 1: SHARE PASS
              AppButton(
                text: AppStrings.sharePassAction,
                icon: Icons.share_outlined,
                onPressed: isCancelled ? null : _onSharePass,
              ),

              const SizedBox(height: 12),

              // Action 2: CANCEL PASS
              if (!isCancelled)
                AppButton(
                  text: AppStrings.cancelPassAction,
                  variant: AppButtonVariant.outline,
                  onPressed: _onCancelPass,
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String value,
    bool isPrimary = false,
  }) {
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
            fontSize: isPrimary ? 17 : 14.5,
            fontWeight: isPrimary ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
