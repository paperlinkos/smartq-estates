import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/estate.dart';
import '../../navigation/app_router.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';

class AccountPlaceholderScreen extends StatelessWidget {
  final Estate? selectedEstate;

  const AccountPlaceholderScreen({
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
        title: AppStrings.tabAccount,
        subtitle: 'Resident profile and preferences',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resident Profile Card
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
                        child: Text(
                          'JD',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'John Doe',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Unit 4B • Primary Resident',
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

              // Estate Association Info
              const Text(
                'ASSIGNED COMMUNITY',
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
                    const Icon(Icons.location_city_rounded, size: 22, color: AppColors.black),
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
                            'Code: $estateCode',
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

              // Architecture Placeholder
              const Text(
                'PREFERENCES & SYSTEM',
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
                    _buildSettingsItem(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications',
                      trailingText: 'Configured in Phase 2',
                    ),
                    const Divider(height: 18),
                    _buildSettingsItem(
                      icon: Icons.qr_code_rounded,
                      title: 'QR Access Pass Architecture',
                      trailingText: 'Ready',
                    ),
                    const Divider(height: 18),
                    _buildSettingsItem(
                      icon: Icons.shield_outlined,
                      title: AppStrings.switchSecurityPortal,
                      trailingText: 'Gate View',
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          AppRouter.security,
                          arguments: selectedEstate,
                        );
                      },
                    ),
                    const Divider(height: 18),
                    _buildSettingsItem(
                      icon: Icons.info_outline_rounded,
                      title: 'Version',
                      trailingText: '1.0.0 (Phase 1 Foundation)',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String trailingText,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Row(
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
            trailingText,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.gray400),
          ],
        ],
      ),
    );
  }
}
