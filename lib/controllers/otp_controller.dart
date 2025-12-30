import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:prime_taxi_flutter_ui_kit/config/app_strings.dart';
import 'package:prime_taxi_flutter_ui_kit/view/home/home_screen.dart';

import '../config/app_size.dart';
import '../api/services/auth_service.dart';
import '../api/client/api_client.dart';
import '../view/create_profile/create_profile_screen.dart';

class OtpController extends GetxController {
  TextEditingController pinPutController = TextEditingController();
  final AuthService _authService = AuthService();

  // Arguments from previous screen
  String email = '';

  // Loading state
  RxBool isLoading = false.obs;

  // Store OTP for display (for testing)
  RxString displayOtp = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // Get arguments passed from GetStarted screen
    final args = Get.arguments;
    if (args != null) {
      email = args['email'] ?? '';
    }

    // Start timer for resend OTP
    startTimer();
  }

  var otp = "".obs;
  var timer = AppStrings.zero.obs;
  final RxBool isTimerExpired = false.obs;
  Timer? _timerInstance;

  void startTimer() {
    const oneSec = Duration(seconds: AppSize.one);
    _timerInstance = Timer.periodic(oneSec, (Timer timer) {
      if (timer.tick == AppSize.time60) {
        timer.cancel();

        isTimerExpired.value = true;
      } else {
        int seconds = (AppSize.time60 - timer.tick) % AppSize.time60;
        this.timer.value = seconds.toString().padLeft(AppSize.two);
      }
    });
  }

  void resetTimer() {
    timer.value = AppStrings.sixteen;
    _timerInstance?.cancel();
    isTimerExpired.value = false;
  }

  // Resend OTP using new email auth API
  Future<void> resendOTP() async {
    if (email.isEmpty) return;

    resetTimer();
    startTimer();

    try {
      // Call new email auth API to resend OTP
      final response = await _authService.sendEmailOtp(email: email);

      final message = response['message'] ?? 'OTP resent to your email';
      Fluttertoast.showToast(msg: message);

      // Log response for debugging
      print('=== OTP RESENT ===');
      print('Response: $response');
      print('=== END RESPONSE ===');

    } catch (e) {
      String errorMessage = 'Failed to resend OTP';
      if (e is ApiException) {
        errorMessage = e.message;
      }
      Fluttertoast.showToast(msg: errorMessage);
    }
  }

  // Verify OTP using new email auth API
  Future<void> verifyOtp() async {
    final otpCode = pinPutController.text.trim();

    if (otpCode.isEmpty || otpCode.length != 4) {
      Fluttertoast.showToast(msg: 'Please enter a valid 4-digit OTP');
      return;
    }

    if (email.isEmpty) {
      Fluttertoast.showToast(msg: 'Email is missing');
      return;
    }

    try {
      isLoading.value = true;

      final response = await _authService.verifyEmailOtp(
        email: email,
        otp: otpCode,
      );

      Fluttertoast.showToast(
        msg: response.message ?? 'Authentication successful',
        toastLength: Toast.LENGTH_LONG,
      );

      // Small delay for UX
      await Future.delayed(const Duration(milliseconds: 800));

      final user = response.user;

      // ✅ CORRECT NAVIGATION LOGIC
      if (user != null && user.name != null && user.name!.trim().isNotEmpty) {
        // Profile already completed → HOME
        Get.offAll(() => HomeScreen());
      } else {
        // Profile incomplete → CREATE PROFILE
        Get.offAll(
              () => CreateProfileScreen(),
          arguments: {'email': email},
        );
      }

    } catch (e) {
      String errorMessage = 'Failed to verify OTP';

      if (e is ApiException) {
        errorMessage = e.message;
      }

      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      isLoading.value = false;
    }
  }


  @override
  void onClose() {
    _timerInstance?.cancel();
    pinPutController.dispose();
    super.onClose();
  }
}
