import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/maintenance_request.dart';
import '../../core/repositories/maintenance_repository.dart';
import '../../navigation/app_router.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_text_field.dart';

/// The screen allowing residents to submit a general property/household maintenance request.
class MaintenanceScreen extends StatefulWidget {
  final MaintenanceRepository? repository;

  const MaintenanceScreen({
    super.key,
    this.repository,
  });

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  static const List<String> _categories = [
    'PLUMBING',
    'ELECTRICAL',
    'CARPENTRY',
    'AC / COOLING',
    'PAINTING',
    'OTHER',
  ];

  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedCategory;
  MaintenanceTiming _selectedTiming = MaintenanceTiming.asSoonAsPossible;
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;

  String? _descriptionError;
  String? _scheduleError;

  MaintenanceRepository get _repo =>
      widget.repository ?? LocalMaintenanceRepository.instance;

  @override
  void dispose() {
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]}, ${dt.year}';
  }

  String _formatTimeOfDay(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    final minute = t.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  Future<void> _pickScheduleDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.black,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _scheduledDate = picked;
        _scheduleError = null;
      });
    }
  }

  Future<void> _pickScheduleTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: _scheduledTime ?? now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.black,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _scheduledTime = picked;
        _scheduleError = null;
      });
    }
  }

  void _submit() {
    final description = _descriptionController.text.trim();

    if (description.isEmpty) {
      setState(() {
        _descriptionError = AppStrings.errorMaintenanceDescriptionRequired;
      });
      return;
    } else {
      setState(() {
        _descriptionError = null;
      });
    }

    DateTime? scheduledDateTime;
    if (_selectedTiming == MaintenanceTiming.scheduled) {
      if (_scheduledDate == null || _scheduledTime == null) {
        setState(() {
          _scheduleError = AppStrings.errorScheduledRequired;
        });
        return;
      }

      scheduledDateTime = DateTime(
        _scheduledDate!.year,
        _scheduledDate!.month,
        _scheduledDate!.day,
        _scheduledTime!.hour,
        _scheduledTime!.minute,
      );

      if (scheduledDateTime.isBefore(DateTime.now())) {
        setState(() {
          _scheduleError = AppStrings.errorScheduledPast;
        });
        return;
      }

      setState(() {
        _scheduleError = null;
      });
    }

    final request = MaintenanceRequest.create(
      description: description,
      category: _selectedCategory,
      timing: _selectedTiming,
      scheduledFor: scheduledDateTime,
      deliveryLocation: 'estateAddress',
      notes: _notesController.text,
    );

    _repo.createRequest(request);

    Navigator.of(context).pushReplacementNamed(
      AppRouter.serviceMaintenanceRequested,
      arguments: request,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: AppStrings.maintenanceTitle,
        subtitle: AppStrings.maintenanceHeaderSubtitle,
        showBackButton: true,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Main Section Heading ──────────────────────────────────
              const Text(
                AppStrings.maintenanceQuestion,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                AppStrings.maintenanceQuestionSubtitle,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 20),

              // ── Problem Description (Required) ────────────────────────
              _buildSectionLabel(AppStrings.labelMaintenanceDescription),
              const SizedBox(height: 8),
              AppTextField(
                controller: _descriptionController,
                hintText: AppStrings.hintMaintenanceDescription,
                errorText: _descriptionError,
                minLines: 4,
                maxLines: 8,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (val) {
                  if (_descriptionError != null && val.trim().isNotEmpty) {
                    setState(() => _descriptionError = null);
                  }
                },
              ),

              const SizedBox(height: 24),

              // ── Category Selection (Optional) ─────────────────────────
              _buildSectionLabel(AppStrings.labelCategoryOptional),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = isSelected ? null : cat;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppColors.black : AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              isSelected ? AppColors.black : AppColors.border,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.white
                              : AppColors.textPrimary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // ── Timing Section ────────────────────────────────────────
              _buildSectionLabel(AppStrings.timingHeading),
              const SizedBox(height: 8),

              // ASAP
              _buildTimingOption(
                timing: MaintenanceTiming.asSoonAsPossible,
                title: AppStrings.timingAsap,
              ),
              const SizedBox(height: 8),

              // Later Today
              _buildTimingOption(
                timing: MaintenanceTiming.laterToday,
                title: AppStrings.timingLaterToday,
              ),
              const SizedBox(height: 8),

              // Schedule
              _buildTimingOption(
                timing: MaintenanceTiming.scheduled,
                title: AppStrings.timingSchedule,
              ),

              // Schedule date & time pickers (when SCHEDULE is active)
              if (_selectedTiming == MaintenanceTiming.scheduled) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickScheduleDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.gray50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded,
                                  size: 16, color: AppColors.black),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _scheduledDate != null
                                      ? _formatDate(_scheduledDate!)
                                      : 'Select Date',
                                  style: TextStyle(
                                    color: _scheduledDate != null
                                        ? AppColors.textPrimary
                                        : AppColors.textTertiary,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickScheduleTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.gray50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time_rounded,
                                  size: 16, color: AppColors.black),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _scheduledTime != null
                                      ? _formatTimeOfDay(_scheduledTime!)
                                      : 'Select Time',
                                  style: TextStyle(
                                    color: _scheduledTime != null
                                        ? AppColors.textPrimary
                                        : AppColors.textTertiary,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_scheduleError != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _scheduleError!,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],

              const SizedBox(height: 24),

              // ── Deliver / Service Location ────────────────────────────
              _buildSectionLabel(AppStrings.labelDeliverTo),
              const SizedBox(height: 8),
              AppCard(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 14.0),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.home_outlined,
                          size: 20,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        AppStrings.myEstateAddress,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Notes (Optional) ──────────────────────────────────────
              _buildSectionLabel(AppStrings.labelNotesOptional),
              const SizedBox(height: 8),
              AppTextField(
                controller: _notesController,
                hintText: AppStrings.hintMaintenanceNotes,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),

              const SizedBox(height: 32),

              // ── Submit Button ─────────────────────────────────────────
              AppButton(
                text: AppStrings.actionRequestMaintenance,
                onPressed: _submit,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textTertiary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.7,
      ),
    );
  }

  Widget _buildTimingOption({
    required MaintenanceTiming timing,
    required String title,
  }) {
    final isSelected = _selectedTiming == timing;

    return AppCard(
      onTap: () {
        setState(() {
          _selectedTiming = timing;
          _scheduleError = null;
        });
      },
      backgroundColor: isSelected ? AppColors.black : AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected ? AppColors.white : AppColors.textPrimary,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          if (isSelected)
            const Icon(
              Icons.check_circle_rounded,
              size: 18,
              color: AppColors.white,
            )
          else
            const Icon(
              Icons.radio_button_unchecked_rounded,
              size: 18,
              color: AppColors.gray400,
            ),
        ],
      ),
    );
  }
}
