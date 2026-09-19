import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/estate_event.dart';
import '../../core/services/qr_code_service.dart';
import '../../navigation/app_router.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_text_field.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _guestsController = TextEditingController();

  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  String? _nameError;
  String? _dateError;
  String? _timeError;
  String? _guestsError;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _startTime = TimeOfDay(hour: (now.hour + 1) % 24, minute: 0);
    // End time default: 3 hours after start time (clamped within same day for simplicity)
    final endHour = (_startTime.hour + 3) % 24;
    _endTime = TimeOfDay(
      hour: endHour <= _startTime.hour ? 23 : endHour,
      minute: 0,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _guestsController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(today) ? today : _selectedDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
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
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
        if (_selectedDate.isBefore(today)) {
          _dateError = AppStrings.errorEventDatePast;
        } else {
          _dateError = null;
        }
      });
    }
  }

  Future<void> _selectStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
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
        _startTime = picked;
        _validateTimeOrder();
      });
    }
  }

  Future<void> _selectEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
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
        _endTime = picked;
        _validateTimeOrder();
      });
    }
  }

  bool _validateTimeOrder() {
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;

    if (endMinutes <= startMinutes) {
      setState(() {
        _timeError = AppStrings.errorEndTimeInvalid;
      });
      return false;
    } else {
      setState(() {
        _timeError = null;
      });
      return true;
    }
  }

  bool _validateInputs() {
    bool isValid = true;
    final name = _nameController.text.trim();
    final guestsText = _guestsController.text.trim();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    setState(() {
      if (name.isEmpty) {
        _nameError = AppStrings.errorEventNameRequired;
        isValid = false;
      } else {
        _nameError = null;
      }

      if (_selectedDate.isBefore(today)) {
        _dateError = AppStrings.errorEventDatePast;
        isValid = false;
      } else {
        _dateError = null;
      }

      final timeOk = _validateTimeOrder();
      if (!timeOk) isValid = false;

      final guests = int.tryParse(guestsText);
      if (guests == null || guests < 1 || guests > 500) {
        _guestsError = AppStrings.errorGuestsInvalid;
        isValid = false;
      } else {
        _guestsError = null;
      }
    });

    return isValid;
  }

  void _onCreateEvent() {
    if (!_validateInputs()) return;

    final event = EstateEvent(
      id: 'evt_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      eventDate: _selectedDate,
      startTime: _startTime,
      endTime: _endTime,
      expectedGuests: int.parse(_guestsController.text.trim()),
      createdAt: DateTime.now(),
      status: EventStatus.upcoming,
    );

    final eventPass = MockQrCodeService().createEventPass(event: event);

    Navigator.of(context).pushReplacementNamed(
      AppRouter.eventPass,
      arguments: eventPass,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(
        title: AppStrings.createEventHeader,
        subtitle: AppStrings.createEventHeaderSubtitle,
        showBackButton: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SECTION 1: WHAT ARE YOU HOSTING?
                    _buildSectionHeader(AppStrings.sectionWhatHosting),
                    const SizedBox(height: 12),
                    _buildFieldLabel(AppStrings.labelEventName),
                    const SizedBox(height: 6),
                    AppTextField(
                      controller: _nameController,
                      hintText: AppStrings.placeholderEventName,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      errorText: _nameError,
                      prefixIcon: const Icon(
                        Icons.celebration_outlined,
                        size: 20,
                        color: AppColors.gray400,
                      ),
                      onChanged: (_) {
                        if (_nameError != null) setState(() => _nameError = null);
                      },
                    ),

                    const SizedBox(height: 28),

                    // SECTION 2: WHEN IS IT?
                    _buildSectionHeader(AppStrings.sectionWhenIsIt),
                    const SizedBox(height: 12),
                    _buildFieldLabel(AppStrings.labelDate),
                    const SizedBox(height: 6),
                    AppCard(
                      onTap: _selectDate,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 17,
                            color: AppColors.black,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _formatDate(_selectedDate),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_dateError != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _dateError!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),

                    // Start Time & End Time
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel(AppStrings.labelStartTime),
                              const SizedBox(height: 6),
                              AppCard(
                                onTap: _selectStartTime,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time_rounded,
                                      size: 18,
                                      color: AppColors.black,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _formatTime(_startTime),
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel(AppStrings.labelEndTime),
                              const SizedBox(height: 6),
                              AppCard(
                                onTap: _selectEndTime,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time_rounded,
                                      size: 18,
                                      color: AppColors.black,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _formatTime(_endTime),
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_timeError != null) ...[
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 2.0),
                        child: Text(
                          _timeError!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),

                    // SECTION 3: HOW MANY GUESTS?
                    _buildSectionHeader(AppStrings.sectionHowManyGuests),
                    const SizedBox(height: 12),
                    _buildFieldLabel(AppStrings.labelExpectedGuests),
                    const SizedBox(height: 6),
                    AppTextField(
                      controller: _guestsController,
                      hintText: AppStrings.placeholderExpectedGuests,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      errorText: _guestsError,
                      prefixIcon: const Icon(
                        Icons.groups_outlined,
                        size: 20,
                        color: AppColors.gray400,
                      ),
                      onChanged: (_) {
                        if (_guestsError != null) setState(() => _guestsError = null);
                      },
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Action Container
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 1.0),
                ),
              ),
              child: AppButton(
                text: AppStrings.createEventAction,
                onPressed: _onCreateEvent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }
}
