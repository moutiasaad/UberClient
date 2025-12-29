import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../api/client/api_client.dart';
import '../api/services/auth_service.dart';
import '../view/otp/otp_screen.dart';

class GetStartedController extends GetxController {
  final AuthService _authService = AuthService();

  final TextEditingController emailController = TextEditingController();
  RxBool isValidEmail = false.obs;

  // Loading state
  RxBool isLoading = false.obs;

  void checkEmailValidity(String email) {
    isValidEmail.value = GetUtils.isEmail(email);
  }

  // Send OTP to email (Step 1 of new email-based auth)
  Future<void> sendOtpToEmail() async {
    final email = emailController.text.trim();

    if (!isValidEmail.value) {
      Fluttertoast.showToast(msg: 'Please enter a valid email address');
      return;
    }

    try {
      isLoading.value = true;

      // Call new email auth API - Step 1: Send OTP
      final response = await _authService.sendEmailOtp(email: email);

      // Show success message
      final message = response['message'] ?? 'OTP sent to your email';
      Fluttertoast.showToast(msg: message);

      // Navigate to OTP screen with email
      Get.to(() => OtpScreen(), arguments: {'email': email});

    } catch (e) {
      String errorMessage = 'Failed to send OTP';
      if (e is ApiException) {
        errorMessage = e.message;
      }
      Fluttertoast.showToast(msg: errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
