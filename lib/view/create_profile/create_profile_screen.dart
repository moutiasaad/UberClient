import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:tshl_tawsil/common_widgets/common_button.dart';
import 'package:tshl_tawsil/common_widgets/common_height_sized_box.dart';
import 'package:tshl_tawsil/common_widgets/common_text_feild.dart';
import 'package:tshl_tawsil/common_widgets/common_width_sized_box.dart';
import 'package:tshl_tawsil/config/app_colors.dart';
import 'package:tshl_tawsil/config/app_icons.dart';
import 'package:tshl_tawsil/config/app_images.dart';
import 'package:tshl_tawsil/config/app_size.dart';
import 'package:tshl_tawsil/config/app_strings.dart';
import 'package:tshl_tawsil/config/font_family.dart';
import 'package:tshl_tawsil/controllers/create_profile_controller.dart';
import 'package:tshl_tawsil/controllers/home_controller.dart';

class CreateProfileScreen extends StatelessWidget {
  CreateProfileScreen({super.key});
  final HomeController homeController = Get.put(HomeController());
  final CreateProfileController createProfileController =
      Get.put(CreateProfileController());

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Center(
      child: Container(
        color: AppColors.backGroundColor,
        width: kIsWeb ? AppSize.size800 : null,
        child: Scaffold(
          backgroundColor: AppColors.backGroundColor,
            appBar: PreferredSize(
                preferredSize: const Size.fromHeight(AppSize.size0),
                child: AppBar(
                  backgroundColor: AppColors.lightTheme,
                  elevation: AppSize.size0,
                )),
            body: SingleChildScrollView(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          bgImage(context, height, width),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CommonHeightSizedBox(
                                      height: height / AppSize.fifteen),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: AppSize.size20),
                                    child: Text(
                                      AppStrings.createYourProfile,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppColors.blackTextColor,
                                        fontFamily: FontFamily.latoBold,
                                        fontSize: AppSize.size20,
                                      ),
                                    ),
                                  ),
                                  CommonHeightSizedBox(
                                      height: height / AppSize.seventy),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: AppSize.size20),
                                    child: Text(
                                      AppStrings.pleaseCreateYourAccount,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppColors.smallTextColor,
                                        fontFamily: FontFamily.latoRegular,
                                        fontSize: AppSize.size12,
                                      ),
                                    ),
                                  ),
                                  CommonHeightSizedBox(
                                      height: height / AppSize.size20),
                                  // Name Field
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: AppSize.size20),
                                    child: Container(
                                      height: AppSize.size54,
                                      decoration: BoxDecoration(boxShadow: [
                                        BoxShadow(
                                          color: AppColors.shadow,
                                          blurRadius: AppSize.size66,
                                          spreadRadius: AppSize.size0,
                                        )
                                      ]),
                                      child: CustomTextField(
                                        prefixIcon: const SizedBox(
                                          width: AppSize.size16,
                                        ),
                                        prefixIconConstraints:
                                            const BoxConstraints(
                                          minWidth: AppSize.size16,
                                        ),
                                        hintColor: AppColors.smallTextColor,
                                        fontFamily: FontFamily.latoRegular,
                                        fontSize: AppSize.size14,
                                        hintText: AppStrings.enterFullName,
                                        fillFontFamily: FontFamily.latoSemiBold,
                                        fillFontSize: AppSize.size14,
                                        colorText: AppColors.blackTextColor,
                                        textInputAction: TextInputAction.next,
                                        fillColor: AppColors.backGroundColor,
                                        controller: createProfileController.nameController,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          CommonHeightSizedBox(height: height / AppSize.size60),
                          // Email Field (Read-only)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSize.size20),
                            child: Container(
                              height: AppSize.size54,
                              decoration: BoxDecoration(boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadow,
                                  blurRadius: AppSize.size66,
                                  spreadRadius: AppSize.size0,
                                )
                              ]),
                              child: CustomTextField(
                                readOnly: true,
                                prefixIcon: const SizedBox(
                                  width: AppSize.size16,
                                ),
                                prefixIconConstraints: const BoxConstraints(
                                  minWidth: AppSize.size16,
                                ),
                                hintColor: AppColors.smallTextColor,
                                fontFamily: FontFamily.latoRegular,
                                fontSize: AppSize.size14,
                                hintText: 'Enter Email Address',
                                fillFontFamily: FontFamily.latoSemiBold,
                                fillFontSize: AppSize.size14,
                                colorText: AppColors.smallTextColor,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.emailAddress,
                                fillColor: AppColors.backGroundColor,
                                controller: createProfileController.emailController,
                              ),
                            ),
                          ),
                          CommonHeightSizedBox(height: height / AppSize.size60),
                          // Phone Number Field with Country Picker
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSize.size20),
                            child: Container(
                              height: AppSize.size54,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.shadow,
                                    blurRadius: AppSize.size66,
                                    spreadRadius: AppSize.size0,
                                  ),
                                ],
                              ),
                              child: CustomTextField(
                                contentPadding: const EdgeInsets.only(
                                    bottom: AppSize.size16, top: AppSize.size16),
                                onChanged: (p0) {
                                  createProfileController.checkPhoneNumberValidity(p0);
                                },
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(AppSize.ten.toInt()),
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
                                          await createProfileController.countryPicker?.showPicker(
                                        context: context,
                                      );
                                      if (code != null) {
                                        createProfileController.countryCode = code;
                                        createProfileController.countryTextController.text =
                                            code.name;
                                        createProfileController.isChanged.toggle();
                                      }
                                    },
                                    child: Obx(() => createProfileController.isChanged.value
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                left: AppSize.size16, right: AppSize.size8),
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                    height: AppSize.size19,
                                                    width: AppSize.size19,
                                                    child: createProfileController.countryCode
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
                                                    createProfileController.countryCode?.dialCode ??
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
                                                    child: createProfileController.countryCode
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
                                                    createProfileController.countryCode?.dialCode ??
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
                                controller: createProfileController.mobileController,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height /
                                AppSize.size15,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: AppSize.size20,
                                right: AppSize.size20,
                                bottom: AppSize.size20),
                            child: Obx(() => createProfileController.isLoading.value
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.primaryColor,
                                    ),
                                  )
                                : ButtonCommon(
                                    onTap: () {
                                      createProfileController.completeRegistration();
                                    },
                                    text: AppStrings.proceed,
                                    height: AppSize.size54,
                                    buttonColor: AppColors.blackTextColor,
                                  )),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            )),
      ),
    );
  }

  Widget bgImage(
    BuildContext context,
    double height,
    double width,
  ) {
    return Container(
      color: AppColors.lightTheme,
      height: height / AppSize.size3And5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: AppSize.size20, bottom: AppSize.size30),
            child: Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child:
                      Image.asset(AppIcons.arrowBack, height: AppSize.size20)),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              AppImages.createProfileImage,
              height: height / AppSize.size5and2,
            ),
          ),
        ],
      ),
    );
  }
}
