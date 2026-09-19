import 'package:flutter/material.dart';
import '../../core/models/estate.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../account/account_placeholder_screen.dart';
import '../activity/activity_placeholder_screen.dart';
import '../home/home_screen.dart';

class MainShellScreen extends StatefulWidget {
  final Estate? initialEstate;

  const MainShellScreen({
    super.key,
    this.initialEstate,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

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
          HomeScreen(selectedEstate: widget.initialEstate),
          const ActivityPlaceholderScreen(),
          AccountPlaceholderScreen(selectedEstate: widget.initialEstate),
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
