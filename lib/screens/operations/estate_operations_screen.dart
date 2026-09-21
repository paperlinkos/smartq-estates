import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/service_request_item.dart';
import '../../core/services/service_coordinator.dart';
import '../../navigation/app_router.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';

/// The Estate Facility Operations Desk screen for managing resident service requests.
///
/// Allows estate personnel to view requests across all six service categories,
/// filter by status (`ALL`, `REQUESTED`, `IN PROGRESS`, `COMPLETED`), and advance
/// their operational handling until completion.
class EstateOperationsScreen extends StatefulWidget {
  final ServiceCoordinator? coordinator;

  const EstateOperationsScreen({
    super.key,
    this.coordinator,
  });

  @override
  State<EstateOperationsScreen> createState() => _EstateOperationsScreenState();
}

class _EstateOperationsScreenState extends State<EstateOperationsScreen> {
  String _selectedFilter = 'ALL';

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

  void _advanceRequest(ServiceRequestItem item) {
    final success = _coordinator.advanceStatus(item.id);
    if (success) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.statusUpdatedNotice),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final allRequests = _coordinator.getAllRequests();
    final filteredList = allRequests.where((r) {
      if (_selectedFilter == 'ALL') return true;
      if (_selectedFilter == 'REQUESTED') {
        return r.operationalPhase == ServiceOperationalPhase.requested;
      }
      if (_selectedFilter == 'IN PROGRESS') {
        return r.operationalPhase == ServiceOperationalPhase.inProgress;
      }
      if (_selectedFilter == 'COMPLETED') {
        return r.operationalPhase == ServiceOperationalPhase.completed;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: AppStrings.operationsDeskTitle,
        subtitle: AppStrings.operationsDeskSubtitle,
        showBackButton: true,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Filters Row ───────────────────────────────────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                children: [
                  _buildFilterChip(AppStrings.filterAll),
                  const SizedBox(width: 8),
                  _buildFilterChip('REQUESTED'),
                  const SizedBox(width: 8),
                  _buildFilterChip('IN PROGRESS'),
                  const SizedBox(width: 8),
                  _buildFilterChip('COMPLETED'),
                ],
              ),
            ),

            // ── Queue List ────────────────────────────────────────────────
            Expanded(
              child: filteredList.isEmpty
                  ? _buildEmptyQueue()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 8.0),
                      itemCount: filteredList.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        return _buildOperationalCard(item);
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

  Widget _buildEmptyQueue() {
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
                Icons.assignment_turned_in_outlined,
                size: 24,
                color: AppColors.gray600,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'QUEUE IS EMPTY',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'No requests found matching the current filter.',
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

  Widget _buildOperationalCard(ServiceRequestItem item) {
    final canAdvance = item.isActive;

    return AppCard(
      onTap: () async {
        await Navigator.of(context).pushNamed(
          AppRouter.serviceRequestDetail,
          arguments: item,
        );
        setState(() {});
      },
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
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
                      '${item.id} · ${item.timingDisplay}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
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

          if (canAdvance) ...[
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => _advanceRequest(item),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.black,
                    foregroundColor: AppColors.white,
                    side: const BorderSide(color: AppColors.black),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.actionAdvanceStatus,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ],
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
