import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/estate.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';
import '../../widgets/prototype_role_switcher.dart';

/// Management operations profile, terminal info, and prototype role switcher screen.
class ManagementAccountScreen extends StatelessWidget {
  final Estate? selectedEstate;

  const ManagementAccountScreen({
    super.key,
    this.selectedEstate,
  });

  @override
  Widget build(BuildContext context) {
    final estateName = selectedEstate?.name ?? 'Pinecrest Royal Estate';
    final estateCode = selectedEstate?.code ?? 'PRE-01';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(
        title: AppStrings.managementAccountTitle,
        subtitle: AppStrings.managementAccountSubtitle,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Operations Manager Profile Card ───────────────────────────
              AppCard(
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.black,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.admin_panel_settings_outlined,
                          color: AppColors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estate Operations Desk',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Facility & Services Management',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'ACTIVE',
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Assigned Estate Info ──────────────────────────────────────
              const Text(
                'ASSIGNED FACILITY',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              AppCard(
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_city_rounded,
                      size: 22,
                      color: AppColors.black,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            estateName,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Facility Code: $estateCode',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── System & Terminal Status ──────────────────────────────────
              const Text(
                'OPERATIONS TERMINAL',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              AppCard(
                child: Column(
                  children: [
                    _buildStatusItem(
                      icon: Icons.sync_rounded,
                      title: 'Shared State Sync',
                      statusText: 'Connected (Phase 7)',
                    ),
                    const Divider(height: 18),
                    _buildStatusItem(
                      icon: Icons.checklist_rounded,
                      title: 'Request Intake Engine',
                      statusText: 'All 6 Domains Active',
                    ),
                    const Divider(height: 18),
                    _buildStatusItem(
                      icon: Icons.terminal_rounded,
                      title: 'Terminal Build',
                      statusText: '1.0.0-mgmt',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Prototype Role Switcher ───────────────────────────────────
              PrototypeRoleSwitcher(
                currentRole: PrototypeRole.management,
                estate: selectedEstate,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String title,
    required String statusText,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.black),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          statusText,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
