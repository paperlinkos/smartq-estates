import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/service_request_item.dart';
import '../../core/services/service_coordinator.dart';
import '../../navigation/app_router.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';

/// The screen where residents track all their submitted estate service requests.
///
/// Features an `ACTIVE` tab for current ongoing requests and a `HISTORY` tab
/// for completed or cancelled requests.
class MyServiceRequestsScreen extends StatefulWidget {
  final ServiceCoordinator? coordinator;

  const MyServiceRequestsScreen({
    super.key,
    this.coordinator,
  });

  @override
  State<MyServiceRequestsScreen> createState() =>
      _MyServiceRequestsScreenState();
}

class _MyServiceRequestsScreenState extends State<MyServiceRequestsScreen> {
  int _selectedTabIndex = 0; // 0 = Active, 1 = History

  ServiceCoordinator get _coordinator =>
      widget.coordinator ?? ServiceCoordinator.instance;

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
    final activeRequests = _coordinator.getActiveRequests();
    final completedRequests = _coordinator.getCompletedRequests();
    final displayedList =
        _selectedTabIndex == 0 ? activeRequests : completedRequests;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: AppStrings.myRequestsTitle,
        subtitle: AppStrings.myRequestsSubtitle,
        showBackButton: true,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Tabs (ACTIVE vs HISTORY) ──────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton(
                      title: '${AppStrings.tabActive} (${activeRequests.length})',
                      isSelected: _selectedTabIndex == 0,
                      onTap: () => setState(() => _selectedTabIndex = 0),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTabButton(
                      title: '${AppStrings.tabHistory} (${completedRequests.length})',
                      isSelected: _selectedTabIndex == 1,
                      onTap: () => setState(() => _selectedTabIndex = 1),
                    ),
                  ),
                ],
              ),
            ),

            // ── Request List or Empty Placeholder ─────────────────────────
            Expanded(
              child: displayedList.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 8.0),
                      itemCount: displayedList.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = displayedList[index];
                        return _buildRequestCard(item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.black : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.black : AppColors.border,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? AppColors.white : AppColors.textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isHistory = _selectedTabIndex == 1;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 32.0),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 36.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isHistory ? Icons.history_rounded : Icons.inbox_outlined,
                size: 24,
                color: AppColors.gray600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isHistory
                  ? AppStrings.noPastRequests
                  : AppStrings.noActiveRequests,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isHistory
                  ? AppStrings.noPastRequestsSubtitle
                  : AppStrings.noActiveRequestsSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(ServiceRequestItem item) {
    return AppCard(
      onTap: () async {
        await Navigator.of(context).pushNamed(
          AppRouter.serviceRequestDetail,
          arguments: item,
        );
        setState(() {}); // Refresh list upon returning from detail
      },
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getServiceIcon(item.serviceType),
                  size: 20,
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
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.timingDisplay,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(item),
            ],
          ),
          const Divider(height: 22),
          Text(
            item.summaryText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ServiceRequestItem item) {
    final status = item.statusDisplayName;
    final phase = item.operationalPhase;

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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: border,
      ),
      child: Text(
        status,
        style: TextStyle(
          color: text,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
