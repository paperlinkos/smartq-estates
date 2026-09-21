import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/decoded_qr_payload.dart';
import '../../core/models/estate.dart';
import '../../core/repositories/access_log_repository.dart';
import '../../navigation/app_router.dart';
import '../../widgets/app_card.dart';

/// The primary operational screen for security gate personnel.
///
/// Features:
/// - Dominant [VERIFY ACCESS] action to trigger QR scanning
/// - Dynamic TODAY summary showing real-time visitor and event check-in counts
/// - RECENT ACTIVITY log showing entries authorized during this session
class SecurityHomeScreen extends StatefulWidget {
  final Estate? selectedEstate;
  final AccessLogRepository? accessLogRepository;

  const SecurityHomeScreen({
    super.key,
    this.selectedEstate,
    this.accessLogRepository,
  });

  @override
  State<SecurityHomeScreen> createState() => _SecurityHomeScreenState();
}

class _SecurityHomeScreenState extends State<SecurityHomeScreen> {
  AccessLogRepository get _repo =>
      widget.accessLogRepository ?? LocalAccessLogRepository.instance;

  String _formatTime(DateTime dt) {
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final estateName = widget.selectedEstate?.name ?? 'Pinecrest Royal Estate';
    final todayEntries = _repo.getTodayEntries();
    final visitorCount =
        todayEntries.where((r) => r.passType == QrPayloadType.visitor).length;
    final eventCount =
        todayEntries.where((r) => r.passType == QrPayloadType.event).length;
    final recentEntries = _repo.getRecentEntries(limit: 10);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          AppStrings.securityTitle,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          estateName,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Gate indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.black,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'GATE 1',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // PRIMARY DOMINANT ACTION: VERIFY ACCESS
              AppCard(
                onTap: () async {
                  await Navigator.of(context).pushNamed(AppRouter.verifyAccess);
                  if (mounted) {
                    setState(() {});
                  }
                },
                padding: const EdgeInsets.all(22.0),
                backgroundColor: AppColors.black,
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.qr_code_scanner_rounded,
                          size: 28,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.verifyAccessAction,
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            AppStrings.verifyAccessSubtitle,
                            style: TextStyle(
                              color: AppColors.gray300,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: AppColors.white,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // SECTION: TODAY
              const Text(
                AppStrings.sectionToday,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  // Visitors Card
                  Expanded(
                    child: AppCard(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                AppStrings.labelSecurityVisitors,
                                style: TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              Icon(
                                Icons.person_pin_outlined,
                                size: 17,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            visitorCount == 0
                                ? AppStrings.noActivityStatus
                                : '$visitorCount ${AppStrings.checkedInSuffix}',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Events Card
                  Expanded(
                    child: AppCard(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                AppStrings.labelSecurityEvents,
                                style: TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              Icon(
                                Icons.celebration_outlined,
                                size: 17,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            eventCount == 0
                                ? AppStrings.noActivityStatus
                                : '$eventCount ${AppStrings.accessEventsSuffix}',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // SECTION: RECENT ACTIVITY
              const Text(
                AppStrings.sectionRecentActivity,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),

              const SizedBox(height: 12),

              if (recentEntries.isEmpty)
                AppCard(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 24.0),
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.history_toggle_off_rounded,
                            size: 22,
                            color: AppColors.gray600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        AppStrings.noRecentActivity,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        AppStrings.recentActivitySubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                )
              else
                AppCard(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    children: [
                      for (int i = 0; i < recentEntries.length; i++) ...[
                        if (i > 0)
                          const Divider(height: 1, color: AppColors.gray200),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.gray100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _formatTime(recentEntries[i].enteredAt),
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      recentEntries[i].subjectName,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${recentEntries[i].passType == QrPayloadType.visitor ? AppStrings.labelVisitorSection : AppStrings.labelEventSection} · ${recentEntries[i].gateId}',
                                      style: const TextStyle(
                                        color: AppColors.textTertiary,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.black,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  AppStrings.labelEntry,
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
