import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import '../api/services/profile_service.dart';
import '../api/client/api_client.dart';
import '../view/home/home_screen.dart';
import '../config/app_colors.dart';
import '../config/app_size.dart';
import '../config/font_family.dart';

class CreateProfileController extends GetxController {
  // Text controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();

  // Country picker
  final countryTextController = TextEditingController();
  FlCountryCodePicker? countryPicker;
  CountryCode? countryCode;
  RxBool isChanged = false.obs;
  RxBool isValidPhoneNumber = false.obs;

  // API service
  final ProfileService _profileService = ProfileService();

  // Arguments from previous screen
  String email = '';

  // Loading state
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Initialize country picker with Qatar as default
    countryPicker = const FlCountryCodePicker(
      countryTextStyle: TextStyle(
        color: AppColors.blackTextColor,
        fontFamily: FontFamily.latoMedium,
        fontSize: AppSize.size16,
      ),
      dialCodeTextStyle: TextStyle(
          color: AppColors.smallTextColor,
          fontSize: AppSize.size14,
          fontFamily: FontFamily.latoRegular),
    );

    // Set default country code to Qatar (+974)
    countryCode = CountryCode(name: 'Qatar', code: 'QA', dialCode: '+974');
    countryTextController.text = 'Qatar';
    isChanged.value = true;

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

  void checkPhoneNumberValidity(String phoneNumber) {
    isValidPhoneNumber.value = phoneNumber.length == 10;
  }

  // Complete profile (user is already authenticated after OTP)
  Future<void> completeRegistration() async {
    final name = nameController.text.trim();
    final phone = mobileController.text.trim();

    print('=== COMPLETE PROFILE CALLED ===');
    print('Name: $name');
    print('Phone: $phone');
    print('====================');

    // Validation
    if (name.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter your name');
      print('Validation failed: Name is empty');
      return;
    }

    if (phone.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter your phone number');
      print('Validation failed: Phone is empty');
      return;
    }

    try {
      isLoading.value = true;

      // Build phone number with country code
      final fullPhone = '${countryCode?.dialCode ?? '+974'}$phone';

      print('=== UPDATING PROFILE ===');
      print('Endpoint: PUT /customer/profile');
      print('Data: name=$name, phone=$fullPhone');
      print('====================');

      // User is already authenticated after OTP verification
      // Just update their profile information
      final updatedUser = await _profileService.updateProfile(
        name: name,
        phone: fullPhone,
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
    mobileController.dispose();
    countryTextController.dispose();
    super.onClose();
  }
}
