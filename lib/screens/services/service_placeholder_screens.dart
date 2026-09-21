import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';

/// Reusable base for temporary service placeholder screens in Phase 6A.
class _ServicePlaceholderBase extends StatelessWidget {
  final String title;
  final IconData icon;

  const _ServicePlaceholderBase({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: title,
        showBackButton: true,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            children: [
              AppCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Icon(
                            icon,
                            size: 26,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        AppStrings.servicePlaceholderNotice,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MarketRunPlaceholderScreen extends StatelessWidget {
  const MarketRunPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ServicePlaceholderBase(
      title: AppStrings.marketRunTitle,
      icon: Icons.shopping_bag_outlined,
    );
  }
}

class GroceriesPlaceholderScreen extends StatelessWidget {
  const GroceriesPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ServicePlaceholderBase(
      title: AppStrings.groceriesTitle,
      icon: Icons.shopping_basket_outlined,
    );
  }
}

class GasPlaceholderScreen extends StatelessWidget {
  const GasPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ServicePlaceholderBase(
      title: AppStrings.gasTitle,
      icon: Icons.propane_tank_outlined,
    );
  }
}

class PetrolPlaceholderScreen extends StatelessWidget {
  const PetrolPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ServicePlaceholderBase(
      title: AppStrings.petrolTitle,
      icon: Icons.local_gas_station_outlined,
    );
  }
}

class GeneratorPlaceholderScreen extends StatelessWidget {
  const GeneratorPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ServicePlaceholderBase(
      title: AppStrings.generatorTitle,
      icon: Icons.electric_bolt_outlined,
    );
  }
}

class MaintenancePlaceholderScreen extends StatelessWidget {
  const MaintenancePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ServicePlaceholderBase(
      title: AppStrings.maintenanceTitle,
      icon: Icons.build_outlined,
    );
  }
}
