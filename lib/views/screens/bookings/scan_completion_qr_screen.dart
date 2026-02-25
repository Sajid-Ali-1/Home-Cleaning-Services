import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/booking_completion_controller.dart';
import 'package:home_cleaning_app/models/booking_model.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanCompletionQrScreen extends StatefulWidget {
  const ScanCompletionQrScreen({super.key, required this.booking});

  final BookingModel booking;

  @override
  State<ScanCompletionQrScreen> createState() => _ScanCompletionQrScreenState();
}

class _ScanCompletionQrScreenState extends State<ScanCompletionQrScreen> {
  final MobileScannerController controller = MobileScannerController();
  late final BookingCompletionController completionController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    completionController = Get.put(
      BookingCompletionController(booking: widget.booking),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    if (barcode.rawValue == null) return;

    setState(() => _isProcessing = true);

    try {
      // Parse QR code data
      final qrData = jsonDecode(barcode.rawValue!) as Map<String, dynamic>;
      final bookingId = qrData['bookingId'] as String?;
      final verificationToken = qrData['verificationToken'] as String?;

      if (bookingId == null || verificationToken == null) {
        _showError('Invalid QR code format');
        return;
      }

      // Verify booking ID matches
      if (bookingId != widget.booking.bookingId) {
        _showError('QR code does not match this booking');
        return;
      }

      // Complete booking
      final success = await completionController.completeBooking(verificationToken);

      if (success) {
        // Stop scanner
        await controller.stop();

        // Show success
        Get.back();
        Get.snackbar(
          'Success',
          'Booking marked as completed',
          backgroundColor: Get.find<AppTheme>().success.withOpacity(0.9),
          colorText: Colors.white,
        );
      } else {
        _showError(completionController.errorMessage.value);
      }
    } catch (e) {
      _showError('Failed to process QR code: ${e.toString()}');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Get.find<AppTheme>().error.withOpacity(0.9),
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        title: Text(
          'Scan QR Code',
          style: theme.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Camera View
          MobileScanner(
            controller: controller,
            onDetect: _handleBarcode,
          ),

          // Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
                stops: const [0.0, 0.2, 0.8, 1.0],
              ),
            ),
          ),

          // Instructions
          Positioned(
            top: 100.h,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  margin: EdgeInsets.symmetric(horizontal: 20.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'Scan the customer\'s completion QR code',
                    textAlign: TextAlign.center,
                    style: theme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
                // Scanning Frame
                Container(
                  width: 250.w,
                  height: 250.w,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _isProcessing ? Colors.green : Colors.white,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ],
            ),
          ),

          // Processing Indicator
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16.h),
                      Text(
                        'Processing...',
                        style: theme.bodyLarge.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Bottom Controls
          Positioned(
            bottom: 40.h,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Flashlight Toggle
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Obx(
                      () => Icon(
                        controller.torchEnabled ? Icons.flash_on : Icons.flash_off,
                        color: Colors.white,
                        size: 28.sp,
                      ),
                    ),
                    onPressed: () => controller.toggleTorch(),
                  ),
                ),
                SizedBox(width: 24.w),
                // Manual Entry Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  child: TextButton.icon(
                    icon: Icon(Icons.keyboard, color: Colors.white, size: 20.sp),
                    label: Text(
                      'Manual Entry',
                      style: theme.bodyMedium.copyWith(color: Colors.white),
                    ),
                    onPressed: () => _showManualEntryDialog(theme),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showManualEntryDialog(AppTheme theme) {
    final tokenController = TextEditingController();

    Get.dialog(
      Dialog(
        backgroundColor: theme.primaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Verification Token',
                style: theme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: tokenController,
                decoration: InputDecoration(
                  hintText: 'Paste verification token',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Cancel'),
                  ),
                  SizedBox(width: 12.w),
                  ElevatedButton(
                    onPressed: () async {
                      if (tokenController.text.isEmpty) return;
                      Get.back();
                      final success = await completionController
                          .completeBooking(tokenController.text.trim());
                      if (success) {
                        Get.back(); // Close scanner screen
                        Get.snackbar(
                          'Success',
                          'Booking marked as completed',
                          backgroundColor: theme.success.withOpacity(0.9),
                          colorText: Colors.white,
                        );
                      } else {
                        _showError(completionController.errorMessage.value);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.accent1,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Submit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
