import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../navigation/app_router.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';

/// The Resident Services Home screen for Phase 6A.
///
/// Gives residents a simple, uncluttered hub to request estate-related services.
/// Adheres to the "WHAT DO YOU NEED?" aesthetic with 6 focused single-column service cards.
class ServicesHomeScreen extends StatelessWidget {
  const ServicesHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: AppStrings.servicesTitle,
        subtitle: AppStrings.servicesSubtitle,
        showBackButton: true,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Section Heading ─────────────────────────────────────────
              const Text(
                AppStrings.servicesQuestion,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                AppStrings.servicesQuestionSubtitle,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 20),

              // ── 1. MARKET RUN ───────────────────────────────────────────
              _ServiceCategoryCard(
                title: AppStrings.marketRunTitle,
                subtitle: AppStrings.marketRunSubtitle,
                icon: Icons.shopping_bag_outlined,
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRouter.marketRun),
              ),

              const SizedBox(height: 12),

              // ── 2. GROCERIES ────────────────────────────────────────────
              _ServiceCategoryCard(
                title: AppStrings.groceriesTitle,
                subtitle: AppStrings.groceriesSubtitle,
                icon: Icons.shopping_basket_outlined,
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRouter.groceries),
              ),

              const SizedBox(height: 12),

              // ── 3. GAS ──────────────────────────────────────────────────
              _ServiceCategoryCard(
                title: AppStrings.gasTitle,
                subtitle: AppStrings.gasSubtitle,
                icon: Icons.propane_tank_outlined,
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRouter.gas),
              ),

              const SizedBox(height: 12),

              // ── 4. PETROL ───────────────────────────────────────────────
              _ServiceCategoryCard(
                title: AppStrings.petrolTitle,
                subtitle: AppStrings.petrolSubtitle,
                icon: Icons.local_gas_station_outlined,
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRouter.petrol),
              ),

              const SizedBox(height: 12),

              // ── 5. GENERATOR ────────────────────────────────────────────
              _ServiceCategoryCard(
                title: AppStrings.generatorTitle,
                subtitle: AppStrings.generatorSubtitle,
                icon: Icons.electric_bolt_outlined,
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRouter.generator),
              ),

              const SizedBox(height: 12),

              // ── 6. MAINTENANCE ──────────────────────────────────────────
              _ServiceCategoryCard(
                title: AppStrings.maintenanceTitle,
                subtitle: AppStrings.maintenanceSubtitle,
                icon: Icons.build_outlined,
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRouter.serviceMaintenance),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceCategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ServiceCategoryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 24,
                color: AppColors.black,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: AppColors.gray400,
          ),
        ],
      ),
    );
  }
}
