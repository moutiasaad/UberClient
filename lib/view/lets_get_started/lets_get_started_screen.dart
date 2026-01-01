import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tshl_tawsil/common_widgets/common_button.dart';
import 'package:tshl_tawsil/common_widgets/common_height_sized_box.dart';
import 'package:tshl_tawsil/common_widgets/common_text_feild.dart';
import 'package:tshl_tawsil/config/app_colors.dart';
import 'package:tshl_tawsil/config/app_icons.dart';
import 'package:tshl_tawsil/config/app_images.dart';
import 'package:tshl_tawsil/config/app_size.dart';
import 'package:tshl_tawsil/config/app_strings.dart';
import 'package:tshl_tawsil/config/font_family.dart';
import 'package:tshl_tawsil/controllers/get_started_controller.dart';

class GetStartedScreen extends StatelessWidget {
  GetStartedScreen({super.key});

  final GetStartedController getStartedController =
      Get.put(GetStartedController());

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Center(
        child: Container(
          color: AppColors.backGroundColor,
          width: kIsWeb ? AppSize.size800 : null,
          child: Scaffold(
            appBar: PreferredSize(
                preferredSize: const Size.fromHeight(AppSize.size0),
                child: AppBar(
                  backgroundColor: AppColors.lightTheme,
                  elevation: AppSize.size0,
                )),
            resizeToAvoidBottomInset: false,
            backgroundColor: AppColors.backGroundColor,
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  bgImage(context, height, width),
                  const CommonHeightSizedBox(height: AppSize.size50),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSize.size20),
                    child: Text(
                      AppStrings.letsGetStarted,
                      style: TextStyle(
                        color: AppColors.blackTextColor,
                        fontFamily: FontFamily.latoBold,
                        fontSize: AppSize.size20,
                      ),
                    ),
                  ),
                  const CommonHeightSizedBox(height: AppSize.size12),
                  const Padding(
                    padding: EdgeInsets.only(
                        left: AppSize.size20, right: AppSize.size50),
                    child: Text(
                      'Enter your email to receive a verification code',
                      style: TextStyle(
                        color: AppColors.smallTextColor,
                        fontFamily: FontFamily.latoRegular,
                        fontSize: AppSize.size12,
                      ),
                    ),
                  ),
                  const CommonHeightSizedBox(height: AppSize.size40),
                  // Email Field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSize.size20),
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
                        contentPadding: const EdgeInsets.only(
                            bottom: AppSize.size6, top: AppSize.size6, left: AppSize.size16),
                        onChanged: (value) {
                          getStartedController.checkEmailValidity(value);
                        },
                        fillFontFamily: FontFamily.latoSemiBold,
                        fillFontSize: AppSize.size14,
                        colorText: AppColors.blackTextColor,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        hintText: 'Enter Email Address',
                        hintColor: AppColors.smallTextColor,
                        fontFamily: FontFamily.latoRegular,
                        fontSize: AppSize.size14,
                        fillColor: AppColors.backGroundColor,
                        controller: getStartedController.emailController,
                      ),
                    ),
                  ),
                  const CommonHeightSizedBox(height: AppSize.size60),
                ],
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(
                left: AppSize.size20,
                right: AppSize.size20,
                bottom: AppSize.size10),
              child: Obx(() => getStartedController.isLoading.value
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    )
                  : ButtonCommon(
                      onTap: () {
                        if (getStartedController.isValidEmail.value) {
                          getStartedController.sendOtpToEmail();
                        }
                      },
                      text: AppStrings.proceed,
                      height: AppSize.size54,
                      buttonColor: getStartedController.isValidEmail.value
                          ? AppColors.blackTextColor
                          : AppColors.smallTextColor,
                    )),
            ),
          ),
        ),
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
      height: height / 3.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: AppSize.size20, bottom: AppSize.size20),
            child: Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child:
                      Image.asset(AppIcons.arrowBack, height: AppSize.size20)),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Image.asset(
                  AppImages.getStartedImage,
                  height: height / AppSize.size4_8,
                ),
                Positioned(
                    bottom: -AppSize.size7,
                    right: AppSize.size30,
                    child: Image.asset(
                      AppImages.starContainer,
                      width:
                          kIsWeb ? AppSize.size90 : (width / AppSize.size4_5),
                    ))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
