import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/estate.dart';
import '../../core/models/service_request_item.dart';
import '../../core/services/service_coordinator.dart';
import '../../navigation/app_router.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';

/// The Management Home dashboard screen highlighting requests and operational status.
class ManagementHomeScreen extends StatelessWidget {
  final Estate? selectedEstate;
  final ServiceCoordinator? coordinator;
  final VoidCallback? onViewAllRequests;

  const ManagementHomeScreen({
    super.key,
    this.selectedEstate,
    this.coordinator,
    this.onViewAllRequests,
  });

  ServiceCoordinator get _coordinator =>
      coordinator ?? ServiceCoordinator.instance;

  IconData _getServiceIcon(String serviceType) {
    switch (serviceType) {
      case 'marketRun':
        return Icons.shopping_bag_outlined;
      case 'groceries':
        return Icons.shopping_basket_outlined;
      case 'gas':
        return Icons.propane_tank_outlined;
      case 'petrol':
        return Icons.local_gas_station_outlined;
      case 'generator':
        return Icons.electric_bolt_outlined;
      case 'maintenance':
      default:
        return Icons.build_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final estateName = selectedEstate?.name ?? 'Pinecrest Royal Estate';
    final estateCode = selectedEstate?.code ?? 'PRE-01';

    final allRequests = _coordinator.getAllRequests();
    final requestedCount = allRequests
        .where((r) => r.operationalPhase == ServiceOperationalPhase.requested)
        .length;
    final inProgressCount = allRequests
        .where((r) => r.operationalPhase == ServiceOperationalPhase.inProgress)
        .length;
    final completedCount = allRequests
        .where((r) => r.operationalPhase == ServiceOperationalPhase.completed)
        .length;

    final recentRequests = allRequests.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(
        title: AppStrings.managementDashboardTitle,
        subtitle: AppStrings.managementDashboardSubtitle,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Assigned Estate Card ──────────────────────────────────────
              AppCard(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.location_city_rounded,
                          color: AppColors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            estateName,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Facility Code: $estateCode • Operations Active',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
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
                        'LIVE',
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

              const SizedBox(height: 24),

              // ── Operational Metrics ───────────────────────────────────────
              const Text(
                'OPERATIONAL OVERVIEW',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      label: AppStrings.pendingRequests,
                      count: requestedCount,
                      isHighlighted: requestedCount > 0,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      label: AppStrings.inProgressRequests,
                      count: inProgressCount,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      label: AppStrings.completedRequests,
                      count: completedCount,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      label: AppStrings.totalRequests,
                      count: allRequests.length,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Live Queue Section ────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    AppStrings.liveOperationsQueue,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  if (onViewAllRequests != null)
                    GestureDetector(
                      onTap: onViewAllRequests,
                      child: const Text(
                        AppStrings.viewAllRequests,
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              if (recentRequests.isEmpty)
                _buildEmptyRecentQueue()
              else
                ...recentRequests.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildRecentCard(context, item),
                    )),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required int count,
    bool isHighlighted = false,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$count',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isHighlighted ? AppColors.black : AppColors.textSecondary,
              fontSize: 10.5,
              fontWeight:
                  isHighlighted ? FontWeight.w800 : FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRecentQueue() {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      child: const Center(
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 28, color: AppColors.gray400),
            SizedBox(height: 10),
            Text(
              'NO ACTIVE REQUESTS IN QUEUE',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCard(BuildContext context, ServiceRequestItem item) {
    return AppCard(
      onTap: () {
        Navigator.of(context).pushNamed(
          AppRouter.managementRequestDetail,
          arguments: item,
        );
      },
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getServiceIcon(item.serviceType),
              size: 18,
              color: AppColors.black,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.serviceTitle,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.summaryText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: item.operationalPhase == ServiceOperationalPhase.inProgress
                  ? AppColors.black
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.black, width: 1),
            ),
            child: Text(
              item.statusDisplayName,
              style: TextStyle(
                color:
                    item.operationalPhase == ServiceOperationalPhase.inProgress
                        ? AppColors.white
                        : AppColors.black,
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
