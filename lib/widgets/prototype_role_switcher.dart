import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/models/estate.dart';
import '../navigation/app_router.dart';
import 'app_card.dart';

enum PrototypeRole {
  resident,
  management,
  security,
}

/// A clean, minimalist prototype card allowing instant role switching between
/// Resident, Management, and Security portals on the same device.
class PrototypeRoleSwitcher extends StatelessWidget {
  final PrototypeRole currentRole;
  final Estate? estate;

  const PrototypeRoleSwitcher({
    super.key,
    required this.currentRole,
    this.estate,
  });

  void _switchTo(BuildContext context, PrototypeRole targetRole) {
    if (targetRole == currentRole) return;

    switch (targetRole) {
      case PrototypeRole.resident:
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRouter.mainShell,
          (route) => false,
          arguments: estate,
        );
        break;
      case PrototypeRole.management:
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRouter.management,
          (route) => false,
          arguments: estate,
        );
        break;
      case PrototypeRole.security:
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRouter.security,
          (route) => false,
          arguments: estate,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.prototypeRoleSwitcherTitle,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          AppStrings.prototypeRoleSwitcherSubtitle,
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 10),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildRoleButton(
                      context: context,
                      role: PrototypeRole.resident,
                      label: AppStrings.roleResident,
                      icon: Icons.home_outlined,
                      isActive: currentRole == PrototypeRole.resident,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildRoleButton(
                      context: context,
                      role: PrototypeRole.management,
                      label: AppStrings.roleManagement,
                      icon: Icons.admin_panel_settings_outlined,
                      isActive: currentRole == PrototypeRole.management,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildRoleButton(
                      context: context,
                      role: PrototypeRole.security,
                      label: AppStrings.roleSecurity,
                      icon: Icons.shield_outlined,
                      isActive: currentRole == PrototypeRole.security,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleButton({
    required BuildContext context,
    required PrototypeRole role,
    required String label,
    required IconData icon,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => _switchTo(context, role),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: isActive ? AppColors.black : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? AppColors.black : AppColors.border,
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? AppColors.white : AppColors.textPrimary,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isActive ? AppColors.white : AppColors.textPrimary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.white.withValues(alpha: 0.2)
                    : AppColors.gray100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isActive ? 'ACTIVE' : 'SWITCH',
                style: TextStyle(
                  color: isActive ? AppColors.white : AppColors.textTertiary,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
