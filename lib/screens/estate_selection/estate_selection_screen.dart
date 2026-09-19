import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/estate.dart';
import '../../core/services/estate_service.dart';
import '../../navigation/app_router.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_text_field.dart';

class EstateSelectionScreen extends StatefulWidget {
  final EstateService? estateService;

  const EstateSelectionScreen({
    super.key,
    this.estateService,
  });

  @override
  State<EstateSelectionScreen> createState() => _EstateSelectionScreenState();
}

class _EstateSelectionScreenState extends State<EstateSelectionScreen> {
  late final EstateService _estateService;
  late final TextEditingController _searchController;
  List<Estate> _displayedEstates = [];
  Estate? _selectedEstate;

  @override
  void initState() {
    super.initState();
    _estateService = widget.estateService ?? EstateService();
    _searchController = TextEditingController();
    _displayedEstates = _estateService.getAllEstates();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _displayedEstates = _estateService.searchEstates(query);
      if (_selectedEstate != null &&
          !_displayedEstates.any((e) => e.id == _selectedEstate!.id)) {
        _selectedEstate = null;
      }
    });
  }

  void _onSelectEstate(Estate estate) {
    setState(() {
      _selectedEstate = estate;
    });
  }

  void _onContinue() {
    if (_selectedEstate == null) return;
    Navigator.of(context).pushReplacementNamed(
      AppRouter.mainShell,
      arguments: _selectedEstate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(
        title: AppStrings.selectYourEstate,
        subtitle: AppStrings.selectEstateSubtitle,
        showBackButton: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              AppTextField(
                controller: _searchController,
                hintText: AppStrings.searchEstatePlaceholder,
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.gray400,
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18, color: AppColors.gray400),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                onChanged: _onSearchChanged,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _displayedEstates.isEmpty
                    ? const Center(
                        child: Text(
                          AppStrings.noEstatesFound,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _displayedEstates.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final estate = _displayedEstates[index];
                          final isSelected = _selectedEstate?.id == estate.id;

                          return AppCard(
                            isSelected: isSelected,
                            onTap: () => _onSelectEstate(estate),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.black
                                        : AppColors.gray100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.apartment_rounded,
                                      size: 20,
                                      color: isSelected
                                          ? AppColors.white
                                          : AppColors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        estate.name,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        estate.location,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.black
                                        : AppColors.gray100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    estate.code,
                                    style: TextStyle(
                                      color: isSelected
                                          ? AppColors.white
                                          : AppColors.textPrimary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),
              AppButton(
                text: AppStrings.continueText,
                onPressed: _selectedEstate != null ? _onContinue : null,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
