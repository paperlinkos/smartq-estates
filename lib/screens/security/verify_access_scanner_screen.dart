import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/decoded_qr_payload.dart';
import '../../core/models/visitor_invitation.dart';
import '../../core/models/visitor_pass.dart';
import '../../core/repositories/pass_registry.dart';
import '../../navigation/app_router.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_text_field.dart';

class VerifyAccessScannerScreen extends StatefulWidget {
  const VerifyAccessScannerScreen({super.key});

  @override
  State<VerifyAccessScannerScreen> createState() =>
      _VerifyAccessScannerScreenState();
}

class _VerifyAccessScannerScreenState extends State<VerifyAccessScannerScreen>
    with WidgetsBindingObserver {
  late MobileScannerController _cameraController;
  late TextEditingController _manualCodeController;
  bool _isDisposed = false;
  bool _hasNavigated = false;
  bool _isTorchOn = false;
  MobileScannerException? _cameraError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _manualCodeController = TextEditingController();
    _cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isDisposed || !mounted) return;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _cameraController.stop();
    } else if (state == AppLifecycleState.resumed) {
      if (_cameraError == null) {
        _cameraController.start();
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _manualCodeController.dispose();
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

    // Stop scanning to prevent duplicate scans
    _cameraController.stop();

    final payload = DecodedQrPayload.parse(rawValue);

    // Phase 5C: Route to AccessResultScreen which runs pass verification
    Navigator.of(context)
        .pushNamed(
      AppRouter.accessResult,
      arguments: payload,
    )
        .then((_) {
      if (mounted && !_isDisposed) {
        setState(() {
          _hasNavigated = false;
        });
        if (_cameraError == null) {
          _cameraController.start();
        }
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

  void _retryCamera() {
    setState(() {
      _cameraError = null;
    });
    _cameraController.start();
  }

  void _simulateScan({required bool isValid}) {
    final now = DateTime.now();
    final passId = isValid ? 'VP-DEMO-VALID' : 'VP-DEMO-EXPIRED';
    final token = isValid ? 'VT-DEMO-VALID-789' : 'VT-DEMO-EXPIRED-000';

    final pass = VisitorPass(
      passId: passId,
      invitation: VisitorInvitation(
        id: isValid ? 'INV-DEMO-VALID' : 'INV-DEMO-EXPIRED',
        visitorName: isValid ? 'Sarah Jenkins' : 'Marcus Vance',
        phoneNumber: '08012345678',
        visitDate: now,
        arrivalTime: TimeOfDay.now(),
        vehiclePlate: 'ABC-123XY',
        vehicleDescription: 'Silver Sedan',
        createdAt: isValid
            ? now.subtract(const Duration(hours: 1))
            : now.subtract(const Duration(days: 2)),
      ),
      issuedAt: isValid
          ? now.subtract(const Duration(hours: 1))
          : now.subtract(const Duration(days: 2)),
      expiresAt: isValid
          ? now.add(const Duration(hours: 6))
          : now.subtract(const Duration(hours: 1)),
      verificationToken: token,
      status: PassStatus.active,
    );

    LocalPassRegistry.instance.registerVisitorPass(pass);
    _handleDecodedString(pass.toQrPayload());
  }

  void _verifyManualCode(String input) {
    final code = input.trim();
    if (code.isEmpty) return;

    // Check if code matches a visitor pass ID in registry
    final visitorPass =
        LocalPassRegistry.instance.findVisitorPass(code.toUpperCase());
    if (visitorPass != null) {
      _handleDecodedString(visitorPass.toQrPayload());
      return;
    }

    // Check if code matches an event pass ID in registry
    final eventPass =
        LocalPassRegistry.instance.findEventPass(code.toUpperCase());
    if (eventPass != null) {
      _handleDecodedString(eventPass.toQrPayload());
      return;
    }

    // If input is raw JSON or formatted string, try parsing directly
    if (code.startsWith('{')) {
      _handleDecodedString(code);
      return;
    }

    // Otherwise pass unrecognized payload with entered passId so verification properly rejects it
    _handleDecodedString(jsonEncode({
      'passId': code.toUpperCase(),
      'type': 'unrecognized',
    }));
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _cameraError != null;

    return Scaffold(
      backgroundColor: hasError ? AppColors.background : AppColors.black,
      appBar: AppHeader(
        title: AppStrings.verifyAccessAction,
        subtitle: AppStrings.verifyAccessSubtitleScanner,
        showBackButton: true,
        actions: [
          if (!hasError) ...[
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
        ],
      ),
      body: SafeArea(
        child: hasError
            ? _buildErrorState(_cameraError!)
            : Stack(
                fit: StackFit.expand,
                children: [
                  // Camera Preview Layer
                  MobileScanner(
                    controller: _cameraController,
                    onDetect: _onDetect,
                    errorBuilder: (context, error) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && _cameraError != error) {
                          setState(() {
                            _cameraError = error;
                          });
                        }
                      });
                      return const SizedBox.shrink();
                    },
                  ),

                  // Scanning Viewfinder Overlay (ONLY shown when camera is active)
                  _buildScannerOverlay(),
                ],
              ),
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Column(
      children: [
        const SizedBox(height: 24),

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
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.white,
                width: 2.5,
              ),
            ),
            child: Stack(
              children: [
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

        // Demo test trigger for physical camera view
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _simulateScan(isValid: true),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.white,
                    side: const BorderSide(color: AppColors.white, width: 1.2),
                    backgroundColor: Colors.black.withValues(alpha: 0.6),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'TEST VALID PASS',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _simulateScan(isValid: false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.white,
                    side: BorderSide(
                      color: AppColors.white.withValues(alpha: 0.6),
                      width: 1.2,
                    ),
                    backgroundColor: Colors.black.withValues(alpha: 0.6),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'TEST EXPIRED PASS',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(MobileScannerException error) {
    final isPermissionError =
        error.errorCode == MobileScannerErrorCode.permissionDenied;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          // Camera icon badge
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(18),
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

          // Error title
          Text(
            isPermissionError
                ? AppStrings.cameraAccessRequired
                : AppStrings.cameraError,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle explanation
          Text(
            isPermissionError
                ? AppStrings.cameraAccessRequiredSubtitle
                : 'Camera is unavailable on this device (e.g. iOS Simulator). Use the simulation tools below to test the pass verification engine.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.5,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 24),

          // Retry camera button
          AppButton(
            text: isPermissionError
                ? AppStrings.grantPermissionAction
                : 'RETRY CAMERA',
            onPressed: _retryCamera,
          ),

          const SizedBox(height: 32),

          // Simulator / Showcase Demo Section
          AppCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.tune_rounded, size: 18, color: AppColors.black),
                    SizedBox(width: 8),
                    Text(
                      'SHOWCASE PASS SIMULATION',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Verify pass verification, security check-in, and access logging without physical camera hardware.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _simulateScan(isValid: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.black,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: Colors.greenAccent, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'SIMULATE VALID PASS (ALLOWED)',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _simulateScan(isValid: false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.black,
                      side: const BorderSide(
                          color: AppColors.border, width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cancel_rounded,
                            color: Colors.redAccent, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'SIMULATE EXPIRED PASS (DENIED)',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 16),

                // Manual Pass ID Lookup
                const Row(
                  children: [
                    Icon(Icons.pin_outlined, size: 16, color: AppColors.black),
                    SizedBox(width: 8),
                    Text(
                      'OR ENTER PASS ID MANUALLY',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                AppTextField(
                  hintText: 'Enter Pass ID (e.g. VP-12345 or EP-12345)',
                  controller: _manualCodeController,
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () =>
                        _verifyManualCode(_manualCodeController.text),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.black,
                      side:
                          const BorderSide(color: AppColors.black, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'VERIFY ENTERED CODE',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                // Session pass quick chips if any created by resident in this session
                if (LocalPassRegistry.instance.allVisitorPasses.isNotEmpty ||
                    LocalPassRegistry.instance.allEventPasses.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'PASSES CREATED IN THIS SESSION:',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final p in LocalPassRegistry.instance.allVisitorPasses)
                        ActionChip(
                          avatar: const Icon(Icons.person,
                              size: 14, color: AppColors.black),
                          label:
                              Text('${p.passId} (${p.invitation.visitorName})'),
                          labelStyle: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700),
                          backgroundColor: AppColors.gray100,
                          side: const BorderSide(color: AppColors.border),
                          onPressed: () =>
                              _handleDecodedString(p.toQrPayload()),
                        ),
                      for (final ep in LocalPassRegistry.instance.allEventPasses)
                        ActionChip(
                          avatar: const Icon(Icons.event,
                              size: 14, color: AppColors.black),
                          label: Text('${ep.passId} (${ep.event.name})'),
                          labelStyle: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700),
                          backgroundColor: AppColors.gray100,
                          side: const BorderSide(color: AppColors.border),
                          onPressed: () =>
                              _handleDecodedString(ep.toQrPayload()),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
