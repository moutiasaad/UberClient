import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../api/services/profile_service.dart';
import '../api/client/api_client.dart';
import '../view/home/home_screen.dart';

class CreateProfileController extends GetxController {
  RxBool male = false.obs;
  RxBool female = false.obs;
  RxBool other = false.obs;
  RxBool check = true.obs;

  // Text controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController referralCodeController = TextEditingController();

  // API service
  final ProfileService _profileService = ProfileService();

  // Arguments from previous screen
  String email = '';

  // Loading state
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    print('=== CREATE PROFILE INIT ===');

    // Get arguments passed from OTP screen
    final args = Get.arguments;
    if (args != null) {
      email = args['email'] ?? '';
      print('Email from args: $email');

      // Pre-fill email field if available
      if (email.isNotEmpty) {
        emailController.text = email;
      }
    }

    print('=== END INIT ===');
  }

  String getGender() {
    if (male.value) return 'male';
    if (female.value) return 'female';
    if (other.value) return 'other';
    return '';
  }

  // Complete profile (user is already authenticated after OTP)
  Future<void> completeRegistration() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();

    print('=== COMPLETE PROFILE CALLED ===');
    print('Name: $name');
    print('Email: $email');
    print('Phone: $phone');
    print('Check: ${check.value}');
    print('====================');

    // Validation
    if (name.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter your name');
      print('Validation failed: Name is empty');
      return;
    }

    if (!check.value) {
      Fluttertoast.showToast(msg: 'Please accept terms and conditions');
      print('Validation failed: Terms not accepted');
      return;
    }

    try {
      isLoading.value = true;

      print('=== UPDATING PROFILE ===');
      print('Endpoint: PUT /customer/profile');
      print('Data: name=$name, email=$email');
      print('====================');

      // User is already authenticated after OTP verification
      // Just update their profile information
      final updatedUser = await _profileService.updateProfile(
        name: name,
        email: email.isNotEmpty ? email : null,
      );

      print('=== PROFILE UPDATE SUCCESS ===');
      print('User: ${updatedUser.toJson()}');
      print('====================');

      Fluttertoast.showToast(
        msg: 'Profile updated successfully!',
        toastLength: Toast.LENGTH_LONG,
      );

      // Small delay to show success message
      await Future.delayed(const Duration(seconds: 1));

      // Navigate to home screen
      Get.offAll(() => HomeScreen());

    } catch (e) {
      String errorMessage = 'Failed to update profile';
      if (e is ApiException) {
        errorMessage = e.message;
        print('=== API EXCEPTION ===');
        print('Message: ${e.message}');
        print('Status Code: ${e.statusCode}');
        print('====================');
      } else {
        print('=== GENERIC ERROR ===');
        print('Error: $e');
        print('Type: ${e.runtimeType}');
        print('====================');
      }

      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_LONG,
      );

      print('=== PROFILE UPDATE ERROR ===');
      print(errorMessage);
      print('====================');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    referralCodeController.dispose();
    super.onClose();
  }
}
