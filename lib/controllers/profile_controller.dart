// ignore_for_file: unrelated_type_equality_checks

import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tshl_tawsil/config/app_strings.dart';

import '../config/app_colors.dart';
import '../config/app_size.dart';
import '../config/font_family.dart';
import '../api/services/profile_service.dart';
import '../api/services/auth_service.dart';
import '../api/client/api_client.dart';
import '../models/user_model.dart';

class ProfileController extends GetxController {
  TextEditingController nameController =
      TextEditingController(text: AppStrings.albertRadhe);
  TextEditingController mobileController =
      TextEditingController(text: AppStrings.mobileNumber);
  TextEditingController birthController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  final countryTextController = TextEditingController();
  RxBool isValidPhoneNumber = false.obs;
  RxInt selectedIndex = 0.obs;
  RxString imagePath = ''.obs;
  Rx<DateTime?> selectedDate = DateTime.now().obs;

  // API services
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();

  // User data
  Rx<UserModel?> userData = Rx<UserModel?>(null);

  // Loading states
  RxBool isLoading = false.obs;
  RxBool isUploadingImage = false.obs;

  void setDate(DateTime? date) {
    selectedDate.value = date;
  }

  Future<void> pickImage() async {
    // Direct gallery selection only (no camera option)
    _getImage(ImageSource.gallery);
  }

  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      imagePath.value = pickedFile.path;
    }
  }


  void checkPhoneNumberValidity(String phoneNumber) {
    isValidPhoneNumber.value = phoneNumber.length == 10;
  }

  FlCountryCodePicker? countryPicker;
  RxBool isChanged = false.obs;
  CountryCode? countryCode;

  @override
  void onInit() {
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

    super.onInit();
  }

  void setSelectedIndex(int index) {
    selectedIndex.value = index;
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      keyboardType: TextInputType.datetime,
      builder: (BuildContext context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      selectedDate.value = picked;
      birthController.text = "${picked.toLocal()}".split(' ')[0];
    }
  }

  List<String> genderList = [
    AppStrings.male,
    AppStrings.female,
    AppStrings.other,
  ];

  @override
  void onReady() {
    super.onReady();
    // Fetch profile when controller is ready
    fetchProfile();
  }

  // Fetch profile data
  Future<void> fetchProfile() async {
    // Prevent multiple simultaneous fetches
    if (isLoading.value) return;

    try {
      isLoading.value = true;

      final profile = await _profileService.getProfile();
      userData.value = profile;

      // Update text controllers
      nameController.text = profile.name;
      emailController.text = profile.email ?? '';
      mobileController.text = profile.phone;

      if (profile.image != null && profile.image!.isNotEmpty) {
        imagePath.value = profile.image!;
      }

    } catch (e) {
      String errorMessage = 'Failed to load profile';
      if (e is ApiException) {
        errorMessage = e.message;
      }
      Fluttertoast.showToast(msg: errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  // Update profile with name, phone, and optional image
  Future<void> updateProfile() async {
    try {
      isLoading.value = true;

      // Build phone number with country code
      final fullPhone = '${countryCode?.dialCode ?? '+974'}${mobileController.text.trim()}';

      final updatedProfile = await _profileService.updateProfile(
        name: nameController.text.trim(),
        phone: fullPhone,
        imagePath: imagePath.value.isNotEmpty ? imagePath.value : null,
      );

      userData.value = updatedProfile;

      // Update text controllers with the response data
      nameController.text = updatedProfile.name;
      emailController.text = updatedProfile.email ?? '';

      // Parse phone number to extract just the number part (without country code)
      String phoneFromApi = updatedProfile.phone;
      if (phoneFromApi.startsWith('+')) {
        // Remove country code from phone number for display
        final dialCode = countryCode?.dialCode ?? '+974';
        if (phoneFromApi.startsWith(dialCode)) {
          mobileController.text = phoneFromApi.substring(dialCode.length);
        } else {
          mobileController.text = phoneFromApi;
        }
      } else {
        mobileController.text = phoneFromApi;
      }

      // Update image if available
      if (updatedProfile.image != null && updatedProfile.image!.isNotEmpty) {
        imagePath.value = updatedProfile.image!;
      }

      // Success notification is shown from UI

    } catch (e) {
      String errorMessage = 'Failed to update profile';
      if (e is ApiException) {
        errorMessage = e.message;
      }
      Fluttertoast.showToast(msg: errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  // Upload profile image
  Future<void> uploadProfileImage() async {
    if (imagePath.value.isEmpty) {
      Fluttertoast.showToast(msg: 'Please select an image');
      return;
    }

    try {
      isUploadingImage.value = true;

      final imageUrl = await _profileService.uploadProfileImage(imagePath.value);

      // Update local data
      if (userData.value != null) {
        userData.value = userData.value!.copyWith(image: imageUrl);
      }

      Fluttertoast.showToast(msg: 'Profile image updated successfully');

    } catch (e) {
      String errorMessage = 'Failed to upload image';
      if (e is ApiException) {
        errorMessage = e.message;
      }
      Fluttertoast.showToast(msg: errorMessage);
    } finally {
      isUploadingImage.value = false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _authService.logout();
      Fluttertoast.showToast(msg: 'Logged out successfully');

      // Navigate to login screen
      Get.offAllNamed('/welcome');

    } catch (e) {
      String errorMessage = 'Failed to logout';
      if (e is ApiException) {
        errorMessage = e.message;
      }
      Fluttertoast.showToast(msg: errorMessage);
    }
  }

  // Delete Account
  Future<void> deleteAccount() async {
    try {
      isLoading.value = true;

      // Call delete account API
      await _profileService.deleteAccount();

      // Logout and navigate to welcome screen
      await _authService.logout();

      Fluttertoast.showToast(msg: 'Account has been deleted');

      // Navigate to welcome screen
      Get.offAllNamed('/welcome');

    } catch (e) {
      String errorMessage = 'Failed to delete account';
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
    nameController.dispose();
    mobileController.dispose();
    birthController.dispose();
    emailController.dispose();
    countryTextController.dispose();
    super.onClose();
  }
}
