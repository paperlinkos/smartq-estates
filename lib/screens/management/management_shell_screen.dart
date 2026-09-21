import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/estate.dart';
import 'management_account_screen.dart';
import 'management_home_screen.dart';
import 'management_requests_screen.dart';

/// The primary shell screen for Estate Management operations with bottom navigation.
class ManagementShellScreen extends StatefulWidget {
  final Estate? initialEstate;
  final int initialTabIndex;

  const ManagementShellScreen({
    super.key,
    this.initialEstate,
    this.initialTabIndex = 0,
  });

  @override
  State<ManagementShellScreen> createState() => _ManagementShellScreenState();
}

class _ManagementShellScreenState extends State<ManagementShellScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
  }

  void _onTabSelected(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          ManagementHomeScreen(
            selectedEstate: widget.initialEstate,
            onViewAllRequests: () => _onTabSelected(1),
          ),
          ManagementRequestsScreen(
            key: ValueKey('mgmt_req_$_currentIndex'),
          ),
          ManagementAccountScreen(
            selectedEstate: widget.initialEstate,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1.0),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  label: AppStrings.tabManagement,
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                ),
                _buildNavItem(
                  index: 1,
                  label: AppStrings.tabManagementRequests,
                  icon: Icons.assignment_outlined,
                  activeIcon: Icons.assignment,
                ),
                _buildNavItem(
                  index: 2,
                  label: AppStrings.tabManagementAccount,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.black : AppColors.gray400;

    return Expanded(
      child: InkWell(
        onTap: () => _onTabSelected(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: color,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
