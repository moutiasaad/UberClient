// ignore_for_file: must_be_immutable
// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tshl_tawsil/common_widgets/common_text_feild.dart';
import 'package:tshl_tawsil/controllers/language_controller.dart';
import 'package:tshl_tawsil/controllers/profile_controller.dart';
import 'package:tshl_tawsil/view/widget/delete_account_bottom_sheet.dart';
import '../../common_widgets/common_width_sized_box.dart';
import '../../config/app_colors.dart';
import '../../config/app_icons.dart';
import '../../config/app_size.dart';
import '../../config/app_strings.dart';
import '../../config/font_family.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);

  ProfileController profileController = Get.put(ProfileController());
  final LanguageController languageController = Get.put(LanguageController());

  @override
  Widget build(BuildContext context) {
    languageController.loadSelectedLanguage();

    // Fetch latest profile data when screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileController.fetchProfile();
    });

    return Center(
      child: Container(
        color: AppColors.backGroundColor,
        width: kIsWeb ? AppSize.size800 : null,
        child: Scaffold(
          backgroundColor: AppColors.backGroundColor,
          appBar: _appBar(),
          body: _profileContent(context),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: _bottomButtons(context),
        ),
      ),
    );
  }

  //Profile Content
  _appBar() {
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.backGroundColor,
      elevation: AppSize.size0,
      automaticallyImplyLeading: false,
      title: Padding(
        padding:
            const EdgeInsets.only(left: AppSize.size5, top: AppSize.size10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Image.asset(
                AppIcons.arrowBack,
                width: AppSize.size20,
              ),
            ),
            const Padding(
              padding:
                  EdgeInsets.only(left: AppSize.size12, right: AppSize.size12),
              child: Text(
                AppStrings.profile,
                style: TextStyle(
                  fontSize: AppSize.size20,
                  fontFamily: FontFamily.latoBold,
                  fontWeight: FontWeight.w700,
                  color: AppColors.blackTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _profileContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        top: AppSize.size40,
        left: AppSize.size20,
        right: AppSize.size20,
        bottom: AppSize.size10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSize.size50),
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      profileController.pickImage();
                    },
                    child: Obx(
                      () => CircleAvatar(
                        radius: AppSize.size39,
                        backgroundColor: AppColors.backGroundColor,
                        backgroundImage: profileController.imagePath.isNotEmpty
                            ? Image.file(
                                    File(profileController.imagePath.value))
                                .image
                            : Image.asset(AppIcons.profilePic).image,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  spreadRadius: AppSize.opacity10,
                  color:
                      AppColors.blackTextColor.withOpacity(AppSize.opacity10),
                  blurRadius: AppSize.size20,
                ),
              ],
            ),
            child: CustomTextField(
              controller: profileController.nameController,
              hintText: AppStrings.name,
              hintFontSize: AppSize.size14,
              hintColor: AppColors.smallTextColor,
              hintTextColor: AppColors.smallTextColor,
              fontFamily: FontFamily.latoRegular,
              height: AppSize.size54,
              fillColor: AppColors.backGroundColor,
              cursorColor: AppColors.smallTextColor,
              fillFontFamily: FontFamily.latoSemiBold,
              fillFontWeight: FontWeight.w600,
              fillFontSize: AppSize.size14,
              fontWeight: FontWeight.w400,
              fillTextColor: AppColors.blackTextColor,
              contentPadding: const EdgeInsets.only(
                  left: AppSize.size16,
                  right: AppSize.size16,
                  top: AppSize.size18,
                  bottom: AppSize.size18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: AppSize.size24),
            child: Container(
              height: AppSize.size54,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    spreadRadius: AppSize.opacity10,
                    color:
                        AppColors.blackTextColor.withOpacity(AppSize.opacity10),
                    blurRadius: AppSize.size20,
                  ),
                ],
              ),
              child: CustomTextField(
                contentPadding: const EdgeInsets.only(
                    bottom: AppSize.size16, top: AppSize.size16),
                onChanged: (p0) {
                  profileController.checkPhoneNumberValidity(p0);
                },
                inputFormatters: [
                  LengthLimitingTextInputFormatter(AppSize.ten),
                ],
                fillFontFamily: FontFamily.latoSemiBold,
                fillFontSize: AppSize.size14,
                colorText: AppColors.blackTextColor,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.number,
                prefixIcon: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: GestureDetector(
                    onTap: () async {
                      final code =
                          await profileController.countryPicker?.showPicker(
                        context: context,
                      );
                      if (code != null) {
                        profileController.countryCode = code;
                        profileController.countryTextController.text =
                            code.name;
                        profileController.isChanged.toggle();
                      }
                    },
                    child: Obx(() => profileController.isChanged.value
                        ? Padding(
                            padding: const EdgeInsets.only(
                                left: AppSize.size16, right: AppSize.size8),
                            child: Row(
                              children: [
                                SizedBox(
                                    height: AppSize.size19,
                                    width: AppSize.size19,
                                    child: profileController.countryCode
                                            ?.flagImage() ??
                                        Image.asset(AppIcons.india)),
                                const CommonWidthSizedBox(width: AppSize.size4),
                                SizedBox(
                                    height: AppSize.size12,
                                    width: AppSize.size12,
                                    child: Center(
                                        child:
                                            Image.asset(AppIcons.arrowDown))),
                                const CommonWidthSizedBox(
                                    width: AppSize.size10),
                                Container(
                                  height: AppSize.size12,
                                  width: AppSize.size1,
                                  decoration: const BoxDecoration(
                                      color: AppColors.smallTextColor),
                                ),
                                const CommonWidthSizedBox(
                                    width: AppSize.size10),
                                Text(
                                    profileController.countryCode?.dialCode ??
                                        AppStrings.indiaCode,
                                    style:
                                        const TextStyle(color: Colors.black)),
                              ],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(
                                left: AppSize.size16, right: AppSize.size8),
                            child: Row(
                              children: [
                                SizedBox(
                                    height: AppSize.size19,
                                    width: AppSize.size19,
                                    child: profileController.countryCode
                                            ?.flagImage() ??
                                        Image.asset(AppIcons.india)),
                                const CommonWidthSizedBox(width: AppSize.size4),
                                SizedBox(
                                    height: AppSize.size12,
                                    width: AppSize.size12,
                                    child: Center(
                                        child:
                                            Image.asset(AppIcons.arrowDown))),
                                const CommonWidthSizedBox(
                                    width: AppSize.size10),
                                Container(
                                  height: AppSize.size12,
                                  width: AppSize.size1,
                                  decoration: const BoxDecoration(
                                      color: AppColors.smallTextColor),
                                ),
                                const CommonWidthSizedBox(
                                    width: AppSize.size10),
                                Text(
                                    profileController.countryCode?.dialCode ??
                                        AppStrings.indiaCode,
                                    style: const TextStyle(
                                        fontFamily: FontFamily.latoSemiBold,
                                        fontSize: AppSize.size14,
                                        color: AppColors.blackTextColor)),
                              ],
                            ),
                          )),
                  ),
                ),
                fillColor: AppColors.backGroundColor,
                controller: profileController.mobileController,
                suffixIcon: Obx(
                  () => Padding(
                    padding: EdgeInsets.only(
                        right:
                            languageController.arb.value ? 0 : AppSize.size16,
                        left:
                            languageController.arb.value ? AppSize.size16 : 0),
                    child: const Text(
                      AppStrings.edit,
                      style: TextStyle(
                        fontSize: AppSize.size12,
                        fontFamily: FontFamily.latoRegular,
                        fontWeight: FontWeight.w400,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
                suffixIconConstraints: const BoxConstraints(
                  maxWidth: AppSize.size38,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: AppSize.size24),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    spreadRadius: AppSize.opacity10,
                    color:
                        AppColors.blackTextColor.withOpacity(AppSize.opacity10),
                    blurRadius: AppSize.size20,
                  ),
                ],
              ),
              child: CustomTextField(
                readOnly: true,
                controller: profileController.emailController,
                hintText: AppStrings.enterEmail,
                hintFontSize: AppSize.size14,
                hintColor: AppColors.smallTextColor,
                hintTextColor: AppColors.smallTextColor,
                fontFamily: FontFamily.latoRegular,
                height: AppSize.size54,
                fillColor: AppColors.backGroundColor,
                cursorColor: AppColors.smallTextColor,
                fillFontFamily: FontFamily.latoSemiBold,
                fillFontWeight: FontWeight.w600,
                fillFontSize: AppSize.size14,
                fontWeight: FontWeight.w400,
                fillTextColor: AppColors.blackTextColor,
                suffixIcon: Obx(
                  () => Padding(
                    padding: EdgeInsets.only(
                        right:
                        languageController.arb.value ? 0 : AppSize.size10,
                    ),
                    child: Image.asset(
                      AppIcons.emailIcon,
                    ),
                  ),
                ),
                suffixIconConstraints: const BoxConstraints(
                  maxWidth: AppSize.size30,
                ),
                contentPadding: const EdgeInsets.only(
                    left: AppSize.size16,
                    right: AppSize.size16,
                    top: AppSize.size18,
                    bottom: AppSize.size18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _bottomButtons(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: AppSize.size12,
        left: AppSize.size20,
        right: AppSize.size20,
        bottom: AppSize.size20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Save Button
          Obx(() => GestureDetector(
            onTap: profileController.isLoading.value
                ? null
                : () async {
                    await profileController.updateProfile();
                    if (!profileController.isLoading.value) {
                      // Show success notification from top
                      Get.snackbar(
                        'Success',
                        'Profile updated successfully',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.TOP,
                        margin: const EdgeInsets.all(AppSize.size16),
                        borderRadius: AppSize.size10,
                        duration: const Duration(seconds: 2),
                      );
                    }
                  },
            child: Container(
              height: AppSize.size54,
              decoration: BoxDecoration(
                color: profileController.isLoading.value
                    ? AppColors.smallTextColor
                    : AppColors.blackTextColor,
                borderRadius: BorderRadius.circular(AppSize.size10),
              ),
              child: Center(
                child: profileController.isLoading.value
                    ? const SizedBox(
                        height: AppSize.size20,
                        width: AppSize.size20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.backGroundColor,
                          ),
                        ),
                      )
                    : const Text(
                        AppStrings.save,
                        style: TextStyle(
                          fontSize: AppSize.size16,
                          fontWeight: FontWeight.w600,
                          fontFamily: FontFamily.latoSemiBold,
                          color: AppColors.backGroundColor,
                        ),
                      ),
              ),
            ),
          )),
          const SizedBox(height: AppSize.size16),
          // Delete Account Button
          GestureDetector(
            onTap: () {
              deleteAccountBottomSheet(context);
            },
            child: Container(
              height: AppSize.size54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSize.size10),
                border: Border.all(
                  color: Colors.red,
                  width: AppSize.size1,
                ),
              ),
              child: const Center(
                child: Text(
                  'Delete Account',
                  style: TextStyle(
                    fontSize: AppSize.size16,
                    fontWeight: FontWeight.w600,
                    fontFamily: FontFamily.latoSemiBold,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
