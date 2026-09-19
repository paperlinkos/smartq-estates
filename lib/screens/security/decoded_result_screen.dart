import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/decoded_qr_payload.dart';
import '../../navigation/app_router.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';

class DecodedResultScreen extends StatelessWidget {
  final DecodedQrPayload payload;

  const DecodedResultScreen({
    super.key,
    required this.payload,
  });

  @override
  Widget build(BuildContext context) {
    final isRecognized = payload.isValidFormat;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: isRecognized ? AppStrings.qrCodeScannedTitle : AppStrings.unrecognizedQrTitle,
        subtitle: isRecognized ? AppStrings.scanReceivedNotice : AppStrings.unrecognizedQrSubtitle,
        showBackButton: true,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isRecognized) ...[
                // Scan Received Status Card
                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check_rounded,
                            color: AppColors.white,
                            size: 26,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.qrCodeScannedTitle,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              AppStrings.scanReceivedNotice,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Decoded Basic Metadata
                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMetaRow(
                        label: AppStrings.labelPassType,
                        value: payload.type.displayName,
                        isHighlight: true,
                      ),
                      const Divider(height: 24),
                      _buildMetaRow(
                        label: AppStrings.labelPassId,
                        value: payload.passId ?? '—',
                        isMonospace: true,
                      ),
                      const Divider(height: 24),
                      _buildMetaRow(
                        label: AppStrings.labelVerificationToken,
                        value: payload.verificationToken ?? '—',
                        isMonospace: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Phase 5B architecture disclaimer notice
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 20,
                        color: AppColors.gray500,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppStrings.pendingVerificationNotice,
                          style: TextStyle(
                            color: AppColors.gray600,
                            fontSize: 12.5,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Unrecognized QR Card
                AppCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.error_outline_rounded,
                            color: AppColors.black,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        AppStrings.unrecognizedQrTitle,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        AppStrings.unrecognizedQrSubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Action: SCAN AGAIN
              AppButton(
                text: AppStrings.scanAgainAction,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 10),
              AppButton(
                text: 'BACK TO SECURITY HOME',
                variant: AppButtonVariant.secondary,
                onPressed: () {
                  Navigator.of(context).popUntil(
                    ModalRoute.withName(AppRouter.security),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaRow({
    required String label,
    required String value,
    bool isHighlight = false,
    bool isMonospace = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13.5,
            fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
            letterSpacing: isMonospace ? 0.8 : 0.2,
          ),
        ),
      ],
    );
  }
}
