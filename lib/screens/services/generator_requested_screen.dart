import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/generator_request.dart';
import '../../navigation/app_router.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';

/// The confirmation screen displayed after a resident submits a Generator service request.
class GeneratorRequestedScreen extends StatelessWidget {
  final GeneratorRequest request;

  const GeneratorRequestedScreen({
    super.key,
    required this.request,
  });

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]}, ${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  String get _timingDisplay {
    switch (request.timing) {
      case GeneratorTiming.asSoonAsPossible:
        return AppStrings.timingAsap;
      case GeneratorTiming.laterToday:
        return AppStrings.timingLaterToday;
      case GeneratorTiming.scheduled:
        if (request.scheduledFor != null) {
          return '${_formatDate(request.scheduledFor!)} · ${_formatTime(request.scheduledFor!)}';
        }
        return AppStrings.timingSchedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasGenerator =
        request.generator != null && request.generator!.trim().isNotEmpty;
    final hasNotes = request.notes != null && request.notes!.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(
        title: AppStrings.requestReceivedTitle,
        subtitle: AppStrings.generatorRequestReceivedSubtitle,
        showBackButton: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Confirmation Card Mark
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_rounded,
                      color: AppColors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Request Summary Details Card
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SERVICE REQUESTED
                    _buildSectionHeader(AppStrings.labelServiceRequested),
                    const SizedBox(height: 6),
                    Text(
                      request.serviceType,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),

                    if (hasGenerator) ...[
                      const Divider(height: 28),
                      // GENERATOR
                      _buildSectionHeader(AppStrings.labelGenerator),
                      const SizedBox(height: 6),
                      Text(
                        request.generator!,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],

                    const Divider(height: 28),

                    // WHEN
                    _buildSectionHeader(AppStrings.labelWhen),
                    const SizedBox(height: 6),
                    Text(
                      _timingDisplay,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),

                    const Divider(height: 28),

                    // DELIVER TO
                    _buildSectionHeader(AppStrings.labelDeliverTo),
                    const SizedBox(height: 6),
                    const Text(
                      AppStrings.myEstateAddress,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),

                    if (hasNotes) ...[
                      const Divider(height: 28),
                      // NOTES
                      _buildSectionHeader(AppStrings.labelNotes),
                      const SizedBox(height: 6),
                      Text(
                        request.notes!,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Done Button returns to Services Home
              AppButton(
                text: AppStrings.doneAction,
                onPressed: () {
                  Navigator.of(context).popUntil((route) =>
                      route.settings.name == AppRouter.services ||
                      route.isFirst);
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }
}
