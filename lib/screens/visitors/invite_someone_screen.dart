import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/visitor_invitation.dart';
import '../../core/repositories/pass_registry.dart';
import '../../core/services/qr_code_service.dart';
import '../../navigation/app_router.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_text_field.dart';

class InviteSomeoneScreen extends StatefulWidget {
  const InviteSomeoneScreen({super.key});

  @override
  State<InviteSomeoneScreen> createState() => _InviteSomeoneScreenState();
}

class _InviteSomeoneScreenState extends State<InviteSomeoneScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _vehicleDescController = TextEditingController();

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  String? _nameError;
  String? _phoneError;
  String? _dateError;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _selectedTime = TimeOfDay(hour: (now.hour + 1) % 24, minute: 0);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _plateController.dispose();
    _vehicleDescController.dispose();
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
          _dateError = AppStrings.errorDatePast;
        } else {
          _dateError = null;
        }
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
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
        _selectedTime = picked;
      });
    }
  }

  bool _validateInputs() {
    bool isValid = true;
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    setState(() {
      if (name.isEmpty) {
        _nameError = AppStrings.errorFullNameRequired;
        isValid = false;
      } else {
        _nameError = null;
      }

      if (phone.isEmpty) {
        _phoneError = AppStrings.errorPhoneRequired;
        isValid = false;
      } else {
        // Clean digits and optional plus
        final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
        if (digitsOnly.length < 9) {
          _phoneError = AppStrings.errorPhoneInvalid;
          isValid = false;
        } else {
          _phoneError = null;
        }
      }

      if (_selectedDate.isBefore(today)) {
        _dateError = AppStrings.errorDatePast;
        isValid = false;
      } else {
        _dateError = null;
      }
    });

    return isValid;
  }

  void _onCreatePass() {
    if (!_validateInputs()) return;

    final invitation = VisitorInvitation(
      id: 'inv_${DateTime.now().millisecondsSinceEpoch}',
      visitorName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      visitDate: _selectedDate,
      arrivalTime: _selectedTime,
      vehiclePlate: _plateController.text.trim().isEmpty ? null : _plateController.text.trim(),
      vehicleDescription:
          _vehicleDescController.text.trim().isEmpty ? null : _vehicleDescController.text.trim(),
      createdAt: DateTime.now(),
    );

    final qrService = MockQrCodeService();
    final pass = qrService.createVisitorPass(invitation: invitation);

    // Register the pass with the local registry so Security can verify it.
    LocalPassRegistry.instance.registerVisitorPass(pass);

    Navigator.of(context).pushReplacementNamed(
      AppRouter.visitorPass,
      arguments: pass,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(
        title: AppStrings.inviteSomeoneHeader,
        subtitle: AppStrings.inviteSomeoneHeaderSubtitle,
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
                    // SECTION 1: WHO IS COMING?
                    _buildSectionHeader(title: AppStrings.sectionWhoIsComing),
                    const SizedBox(height: 12),
                    _buildFieldLabel(AppStrings.labelFullName),
                    const SizedBox(height: 6),
                    AppTextField(
                      controller: _nameController,
                      hintText: AppStrings.placeholderFullName,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      errorText: _nameError,
                      prefixIcon: const Icon(
                        Icons.person_outline_rounded,
                        size: 20,
                        color: AppColors.gray400,
                      ),
                      onChanged: (_) {
                        if (_nameError != null) {
                          setState(() => _nameError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildFieldLabel(AppStrings.labelPhoneNumber),
                    const SizedBox(height: 6),
                    AppTextField(
                      controller: _phoneController,
                      hintText: AppStrings.placeholderPhoneNumber,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      errorText: _phoneError,
                      prefixIcon: const Icon(
                        Icons.phone_outlined,
                        size: 20,
                        color: AppColors.gray400,
                      ),
                      onChanged: (_) {
                        if (_phoneError != null) {
                          setState(() => _phoneError = null);
                        }
                      },
                    ),

                    const SizedBox(height: 28),

                    // SECTION 2: WHEN ARE THEY COMING?
                    _buildSectionHeader(title: AppStrings.sectionWhenComing),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel(AppStrings.labelDate),
                              const SizedBox(height: 6),
                              AppCard(
                                onTap: _selectDate,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 13,
                                ),
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
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel(AppStrings.labelArrivalTime),
                              const SizedBox(height: 6),
                              AppCard(
                                onTap: _selectTime,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 13,
                                ),
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
                                        _formatTime(_selectedTime),
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

                    const SizedBox(height: 28),

                    // SECTION 3: VEHICLE (OPTIONAL)
                    Row(
                      children: [
                        _buildSectionHeader(title: AppStrings.sectionVehicle),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: AppColors.gray100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            AppStrings.optionalBadge,
                            style: TextStyle(
                              color: AppColors.gray600,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildFieldLabel(AppStrings.labelPlateNumber),
                    const SizedBox(height: 6),
                    AppTextField(
                      controller: _plateController,
                      hintText: AppStrings.placeholderPlateNumber,
                      textCapitalization: TextCapitalization.characters,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(
                        Icons.directions_car_outlined,
                        size: 20,
                        color: AppColors.gray400,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildFieldLabel(AppStrings.labelVehicleDescription),
                    const SizedBox(height: 6),
                    AppTextField(
                      controller: _vehicleDescController,
                      hintText: AppStrings.placeholderVehicleDescription,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      prefixIcon: const Icon(
                        Icons.info_outline_rounded,
                        size: 20,
                        color: AppColors.gray400,
                      ),
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
                text: AppStrings.createPassAction,
                onPressed: _onCreatePass,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required String title}) {
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
