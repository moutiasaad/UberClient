// ignore_for_file: unrelated_type_equality_checks

import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prime_taxi_flutter_ui_kit/config/app_strings.dart';

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
    Get.bottomSheet(
      Container(
        margin: const EdgeInsets.only(bottom: AppSize.size35),
        padding: const EdgeInsets.all(AppSize.size16),
        decoration: const BoxDecoration(
          color: AppColors.backGroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSize.size16)),
        ),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text(AppStrings.camera),
              onTap: () {
                _getImage(ImageSource.camera);
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text(AppStrings.gallery),
              onTap: () {
                _getImage(ImageSource.gallery);
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
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

  // Update profile
  Future<void> updateProfile() async {
    try {
      isLoading.value = true;

      final updatedProfile = await _profileService.updateProfile(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
      );

      userData.value = updatedProfile;
      Fluttertoast.showToast(msg: 'Profile updated successfully');

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
