import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/service_request_item.dart';
import '../../core/services/service_coordinator.dart';
import '../../navigation/app_router.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';

/// The Management Requests screen displaying live resident service requests.
class ManagementRequestsScreen extends StatefulWidget {
  final ServiceCoordinator? coordinator;
  final String? initialFilter;

  const ManagementRequestsScreen({
    super.key,
    this.coordinator,
    this.initialFilter,
  });

  @override
  State<ManagementRequestsScreen> createState() =>
      _ManagementRequestsScreenState();
}

class _ManagementRequestsScreenState extends State<ManagementRequestsScreen> {
  late String _selectedFilter;

  ServiceCoordinator get _coordinator =>
      widget.coordinator ?? ServiceCoordinator.instance;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter ?? AppStrings.filterAll;
  }

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
    final allRequests = _coordinator.getAllRequests();
    final filteredList = allRequests.where((r) {
      if (_selectedFilter == AppStrings.filterAll) return true;
      if (_selectedFilter == AppStrings.filterNew ||
          _selectedFilter == 'REQUESTED') {
        return r.operationalPhase == ServiceOperationalPhase.requested;
      }
      if (_selectedFilter == AppStrings.filterInProgress) {
        return r.operationalPhase == ServiceOperationalPhase.inProgress;
      }
      if (_selectedFilter == AppStrings.filterCompleted) {
        return r.operationalPhase == ServiceOperationalPhase.completed;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(
        title: AppStrings.managementRequestsTitle,
        subtitle: AppStrings.managementRequestsSubtitle,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Filter Chips ───────────────────────────────────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                children: [
                  _buildFilterChip(AppStrings.filterAll),
                  const SizedBox(width: 8),
                  _buildFilterChip(AppStrings.filterNew),
                  const SizedBox(width: 8),
                  _buildFilterChip(AppStrings.filterInProgress),
                  const SizedBox(width: 8),
                  _buildFilterChip(AppStrings.filterCompleted),
                ],
              ),
            ),

            // ── Requests List ──────────────────────────────────────────────
            Expanded(
              child: filteredList.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 8.0,
                      ),
                      itemCount: filteredList.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        return _buildRequestCard(item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.black : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.black : AppColors.border,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.textPrimary,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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
              child: const Icon(
                Icons.inbox_outlined,
                size: 24,
                color: AppColors.gray600,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              AppStrings.noManagementRequests,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              AppStrings.noManagementRequestsSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
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
          AppRouter.managementRequestDetail,
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
                      '${item.residentName} • ${item.unitOrEstate}',
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
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.id,
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                item.timingDisplay,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
