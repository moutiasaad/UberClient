import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:prime_taxi_flutter_ui_kit/config/app_strings.dart';

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

    print('=== VERIFY OTP CALLED ===');
    print('Email: $email');
    print('OTP Code: $otpCode');
    print('OTP Length: ${otpCode.length}');
    print('===================');

    if (otpCode.isEmpty || otpCode.length != 4) {
      Fluttertoast.showToast(msg: 'Please enter a valid 4-digit OTP');
      print('Validation failed: OTP must be 4 digits');
      return;
    }

    if (email.isEmpty) {
      Fluttertoast.showToast(msg: 'Email is missing');
      print('Validation failed: Email is empty');
      return;
    }

    try {
      isLoading.value = true;

      print('=== CALLING VERIFY API ===');
      print('Endpoint: /auth/customer/verify-otp');
      print('Email: $email');
      print('OTP: $otpCode');
      print('===================');

      // Call new email OTP verification API
      final response = await _authService.verifyEmailOtp(
        email: email,
        otp: otpCode,
      );

      print('=== VERIFICATION SUCCESS ===');
      print('Token: ${response.token}');
      print('User: ${response.user?.toJson()}');
      print('Message: ${response.message}');
      print('=== END VERIFICATION ===');

      Fluttertoast.showToast(
        msg: 'Authentication successful!',
        toastLength: Toast.LENGTH_LONG,
      );

      // Small delay to let user see the success message
      await Future.delayed(const Duration(seconds: 1));

      // Navigate to create profile or home screen
      // Check if user already has a profile
      if (response.user?.name != null && response.user!.name.isNotEmpty) {
        // User already has profile, go to home
        Get.offAll(() => CreateProfileScreen());
      } else {
        // Need to complete profile
        Get.offAll(() => CreateProfileScreen(), arguments: {
          'email': email,
        });
      }

    } catch (e) {
      String errorMessage = 'Failed to verify OTP';
      if (e is ApiException) {
        errorMessage = e.message;
        print('=== API EXCEPTION ===');
        print('Message: ${e.message}');
        print('Status Code: ${e.statusCode}');
        print('===================');
      } else {
        print('=== GENERIC ERROR ===');
        print('Error: $e');
        print('Type: ${e.runtimeType}');
        print('===================');
      }

      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_LONG,
      );

      print('=== VERIFICATION ERROR ===');
      print(errorMessage);
      print('=== END ERROR ===');
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
