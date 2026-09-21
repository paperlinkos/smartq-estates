import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/decoded_qr_payload.dart';
import '../../navigation/app_router.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';

class VerifyAccessScannerScreen extends StatefulWidget {
  const VerifyAccessScannerScreen({super.key});

  @override
  State<VerifyAccessScannerScreen> createState() => _VerifyAccessScannerScreenState();
}

class _VerifyAccessScannerScreenState extends State<VerifyAccessScannerScreen> with WidgetsBindingObserver {
  late MobileScannerController _cameraController;
  bool _isDisposed = false;
  bool _hasNavigated = false;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isDisposed || !mounted) return;
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _cameraController.stop();
    } else if (state == AppLifecycleState.resumed) {
      _cameraController.start();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasNavigated || _isDisposed || !mounted) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    _handleDecodedString(rawValue);
  }

  void _handleDecodedString(String rawValue) {
    if (_hasNavigated || _isDisposed || !mounted) return;
    _hasNavigated = true;

    // Immediately stop scanning to prevent duplicate scans
    _cameraController.stop();

    final payload = DecodedQrPayload.parse(rawValue);

    // Phase 5C: Route to AccessResultScreen which runs full pass verification.
    Navigator.of(context).pushNamed(
      AppRouter.accessResult,
      arguments: payload,
    ).then((_) {
      // Upon returning to the scanner screen, reset navigation state and restart camera
      if (mounted && !_isDisposed) {
        setState(() {
          _hasNavigated = false;
        });
        _cameraController.start();
      }
    });
  }


  Future<void> _toggleTorch() async {
    try {
      await _cameraController.toggleTorch();
      if (mounted) {
        setState(() {
          _isTorchOn = !_isTorchOn;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppHeader(
        title: AppStrings.verifyAccessAction,
        subtitle: AppStrings.verifyAccessSubtitleScanner,
        showBackButton: true,
        actions: [
          IconButton(
            onPressed: _toggleTorch,
            icon: Icon(
              _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: AppColors.black,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Camera Preview Layer
            MobileScanner(
              controller: _cameraController,
              onDetect: _onDetect,
              errorBuilder: (context, error) {
                return _buildErrorState(error);
              },
            ),

            // Scanning Viewfinder Overlay
            _buildScannerOverlay(),

            // Web or Testing Fallback Trigger (Allows simulated test scan)
            if (kIsWeb)
              Positioned(
                bottom: 24,
                left: 20,
                right: 20,
                child: AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 20, color: AppColors.black),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Web Preview / Simulation Mode',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Allow quick simulated scan on web
                          _handleDecodedString(
                            '{"passId":"BT-SIM01","type":"visitor","issuedAt":"2026-09-20T10:00:00Z","expiresAt":"2026-09-20T16:00:00Z","verificationToken":"VT-SIM-789","status":"active"}',
                          );
                        },
                        child: const Text('SAMPLE SCAN'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Column(
      children: [
        const SizedBox(height: 36),

        // Scanning guidance label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            AppStrings.scanQrCodeGuide,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
        ),

        const Spacer(),

        // Rectangular Viewfinder Frame
        Center(
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.white,
                width: 2.5,
              ),
            ),
            child: Stack(
              children: [
                // Minimal corner accents for high readability
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppColors.white, width: 4),
                        left: BorderSide(color: AppColors.white, width: 4),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppColors.white, width: 4),
                        right: BorderSide(color: AppColors.white, width: 4),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.white, width: 4),
                        left: BorderSide(color: AppColors.white, width: 4),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.white, width: 4),
                        right: BorderSide(color: AppColors.white, width: 4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Subtitle instruction
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            AppStrings.scanQrCodeInstruction,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const Spacer(),
        const SizedBox(height: 60),
      ],
    );
  }

  Widget _buildErrorState(MobileScannerException error) {
    final isPermissionError = error.errorCode == MobileScannerErrorCode.permissionDenied;

    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(
                  Icons.camera_alt_outlined,
                  size: 32,
                  color: AppColors.black,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isPermissionError ? AppStrings.cameraAccessRequired : AppStrings.cameraError,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isPermissionError
                  ? AppStrings.cameraAccessRequiredSubtitle
                  : AppStrings.cameraUnavailableSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              text: isPermissionError ? AppStrings.grantPermissionAction : 'RETRY CAMERA',
              onPressed: () {
                _cameraController.start();
              },
            ),
          ],
        ),
      ),
    );
  }
}
