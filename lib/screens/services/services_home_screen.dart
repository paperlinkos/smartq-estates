import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/service_coordinator.dart';
import '../../navigation/app_router.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';

/// The Resident Services Home screen.
///
/// Gives residents a simple, uncluttered hub to request estate-related services
/// and track active/historical requests.
class ServicesHomeScreen extends StatefulWidget {
  final ServiceCoordinator? coordinator;

  const ServicesHomeScreen({
    super.key,
    this.coordinator,
  });

  @override
  State<ServicesHomeScreen> createState() => _ServicesHomeScreenState();
}

class _ServicesHomeScreenState extends State<ServicesHomeScreen> {
  ServiceCoordinator get _coordinator =>
      widget.coordinator ?? ServiceCoordinator.instance;

  @override
  Widget build(BuildContext context) {
    final activeRequests = _coordinator.getActiveRequests();

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
              // ── Active Requests Banner (If Any) ─────────────────────────
              if (activeRequests.isNotEmpty) ...[
                AppCard(
                  onTap: () async {
                    await Navigator.of(context)
                        .pushNamed(AppRouter.myServiceRequests);
                    setState(() {});
                  },
                  backgroundColor: AppColors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.schedule_rounded,
                            size: 20,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${AppStrings.activeRequestsSection} (${activeRequests.length})',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${activeRequests.first.serviceTitle} · ${activeRequests.first.statusDisplayName}',
                              style: TextStyle(
                                color: AppColors.white.withValues(alpha: 0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: AppColors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

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
                onTap: () async {
                  await Navigator.of(context).pushNamed(AppRouter.marketRun);
                  setState(() {});
                },
              ),

              const SizedBox(height: 12),

              // ── 2. GROCERIES ────────────────────────────────────────────
              _ServiceCategoryCard(
                title: AppStrings.groceriesTitle,
                subtitle: AppStrings.groceriesSubtitle,
                icon: Icons.shopping_basket_outlined,
                onTap: () async {
                  await Navigator.of(context).pushNamed(AppRouter.groceries);
                  setState(() {});
                },
              ),

              const SizedBox(height: 12),

              // ── 3. GAS ──────────────────────────────────────────────────
              _ServiceCategoryCard(
                title: AppStrings.gasTitle,
                subtitle: AppStrings.gasSubtitle,
                icon: Icons.propane_tank_outlined,
                onTap: () async {
                  await Navigator.of(context).pushNamed(AppRouter.gas);
                  setState(() {});
                },
              ),

              const SizedBox(height: 12),

              // ── 4. PETROL ───────────────────────────────────────────────
              _ServiceCategoryCard(
                title: AppStrings.petrolTitle,
                subtitle: AppStrings.petrolSubtitle,
                icon: Icons.local_gas_station_outlined,
                onTap: () async {
                  await Navigator.of(context).pushNamed(AppRouter.petrol);
                  setState(() {});
                },
              ),

              const SizedBox(height: 12),

              // ── 5. GENERATOR ────────────────────────────────────────────
              _ServiceCategoryCard(
                title: AppStrings.generatorTitle,
                subtitle: AppStrings.generatorSubtitle,
                icon: Icons.electric_bolt_outlined,
                onTap: () async {
                  await Navigator.of(context).pushNamed(AppRouter.generator);
                  setState(() {});
                },
              ),

              const SizedBox(height: 12),

              // ── 6. MAINTENANCE ──────────────────────────────────────────
              _ServiceCategoryCard(
                title: AppStrings.maintenanceTitle,
                subtitle: AppStrings.maintenanceSubtitle,
                icon: Icons.build_outlined,
                onTap: () async {
                  await Navigator.of(context)
                      .pushNamed(AppRouter.serviceMaintenance);
                  setState(() {});
                },
              ),

              const SizedBox(height: 20),

              // ── MY REQUESTS LINK ────────────────────────────────────────
              AppCard(
                onTap: () async {
                  await Navigator.of(context)
                      .pushNamed(AppRouter.myServiceRequests);
                  setState(() {});
                },
                padding: const EdgeInsets.symmetric(
                    horizontal: 18.0, vertical: 16.0),
                child: Row(
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
                          Icons.receipt_long_outlined,
                          size: 22,
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
                            AppStrings.myRequestsTitle,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            AppStrings.myRequestsSubtitle,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12.5,
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
