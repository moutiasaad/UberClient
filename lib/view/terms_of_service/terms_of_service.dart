import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tshl_tawsil/common_widgets/common_height_sized_box.dart';
import 'package:tshl_tawsil/common_widgets/common_short_button.dart';
import 'package:tshl_tawsil/common_widgets/common_width_sized_box.dart';
import 'package:tshl_tawsil/config/app_colors.dart';
import 'package:tshl_tawsil/config/app_icons.dart';
import 'package:tshl_tawsil/config/app_size.dart';
import 'package:tshl_tawsil/config/app_strings.dart';
import 'package:tshl_tawsil/config/font_family.dart';
import 'package:tshl_tawsil/controllers/language_controller.dart';
import 'package:tshl_tawsil/controllers/terms_of_service_controller.dart';
import 'package:tshl_tawsil/view/home/home_screen.dart';

class TermsOfService extends StatelessWidget {
  TermsOfService({super.key});

  final TermsOfServiceController termsOfServiceController =
      Get.put(TermsOfServiceController());

  final LanguageController languageController = Get.put(LanguageController());

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: AppColors.backGroundColor,
        width: kIsWeb ? AppSize.size800 : null,
        child: Scaffold(
          backgroundColor: AppColors.backGroundColor,
          appBar: AppBar(
            backgroundColor: AppColors.backGroundColor,
            elevation: AppSize.size0,
            leadingWidth: AppSize.size40,
            leading: Obx(
              () => Padding(
                padding: EdgeInsets.only(
                    left: languageController.arb.value ? 0 : AppSize.size20,
                    right: languageController.arb.value
                        ? AppSize.size20
                        : AppSize.size0),
                child: GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Image.asset(
                    AppIcons.arrowBack,
                    height: AppSize.size20,
                    width: AppSize.size20,
                  ),
                ),
              ),
            ),
            title: const Text(
              AppStrings.termsOfService,
              style: TextStyle(
                color: AppColors.blackTextColor,
                fontFamily: FontFamily.latoBold,
                fontSize: AppSize.size20,
              ),
            ),
          ),
          body: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonHeightSizedBox(height: AppSize.size20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSize.size20),
                  child: Text(
                    AppStrings.terms,
                    style: TextStyle(
                      color: AppColors.blackTextColor,
                      fontFamily: FontFamily.latoBold,
                      fontSize: AppSize.size16,
                    ),
                  ),
                ),
                CommonHeightSizedBox(height: AppSize.size6),
                Padding(
                  padding: EdgeInsets.only(
                      left: AppSize.size40, right: AppSize.size20),
                  child: Text(
                    AppStrings.termsDescription,
                    style: TextStyle(
                      color: AppColors.smallTextColor,
                      fontFamily: FontFamily.latoRegular,
                      fontSize: AppSize.size12,
                    ),
                  ),
                ),
                CommonHeightSizedBox(height: AppSize.size24),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSize.size20),
                  child: Text(
                    AppStrings.service,
                    style: TextStyle(
                      color: AppColors.blackTextColor,
                      fontFamily: FontFamily.latoBold,
                      fontSize: AppSize.size16,
                    ),
                  ),
                ),
                CommonHeightSizedBox(height: AppSize.size6),
                Padding(
                  padding: EdgeInsets.only(
                      left: AppSize.size40, right: AppSize.size20),
                  child: Text(
                    AppStrings.serviceDescription,
                    style: TextStyle(
                      color: AppColors.smallTextColor,
                      fontFamily: FontFamily.latoRegular,
                      fontSize: AppSize.size12,
                    ),
                  ),
                ),
                CommonHeightSizedBox(height: AppSize.size24),
                Padding(
                  padding: EdgeInsets.only(
                      left: AppSize.size40, right: AppSize.size20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(AppSize.size7),
                        child: CircleAvatar(
                          backgroundColor: AppColors.smallTextColor,
                          radius: AppSize.size2,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: AppSize.size20),
                          child: Text(
                            AppStrings.lorenIpsum,
                            style: TextStyle(
                              color: AppColors.smallTextColor,
                              fontFamily: FontFamily.latoRegular,
                              fontSize: AppSize.size12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: AppSize.size40, right: AppSize.size20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(AppSize.size7),
                        child: CircleAvatar(
                          backgroundColor: AppColors.smallTextColor,
                          radius: AppSize.size2,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: AppSize.size20),
                          child: Text(
                            AppStrings.lorenIpsum,
                            style: TextStyle(
                              color: AppColors.smallTextColor,
                              fontFamily: FontFamily.latoRegular,
                              fontSize: AppSize.size12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: AppSize.size40, right: AppSize.size20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(AppSize.size7),
                        child: CircleAvatar(
                          backgroundColor: AppColors.smallTextColor,
                          radius: AppSize.size2,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: AppSize.size20),
                          child: Text(
                            AppStrings.lorenIpsum,
                            style: TextStyle(
                              color: AppColors.smallTextColor,
                              fontFamily: FontFamily.latoRegular,
                              fontSize: AppSize.size12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: AppSize.size40, right: AppSize.size20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(AppSize.size7),
                        child: CircleAvatar(
                          backgroundColor: AppColors.smallTextColor,
                          radius: AppSize.size2,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: AppSize.size20),
                          child: Text(
                            AppStrings.lorenIpsum,
                            style: TextStyle(
                              color: AppColors.smallTextColor,
                              fontFamily: FontFamily.latoRegular,
                              fontSize: AppSize.size12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                CommonHeightSizedBox(height: AppSize.size24),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSize.size20),
                  child: Text(
                    AppStrings.terms3,
                    style: TextStyle(
                      color: AppColors.blackTextColor,
                      fontFamily: FontFamily.latoBold,
                      fontSize: AppSize.size16,
                    ),
                  ),
                ),
                CommonHeightSizedBox(height: AppSize.size6),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSize.size20),
                  child: Text(
                    AppStrings.termsDescription,
                    style: TextStyle(
                      color: AppColors.smallTextColor,
                      fontFamily: FontFamily.latoRegular,
                      fontSize: AppSize.size12,
                    ),
                  ),
                ),
                CommonHeightSizedBox(height: AppSize.size12),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSize.size20),
                  child: Text(
                    AppStrings.lorem,
                    style: TextStyle(
                      color: AppColors.smallTextColor,
                      fontFamily: FontFamily.latoRegular,
                      fontSize: AppSize.size12,
                    ),
                  ),
                ),
                CommonHeightSizedBox(height: AppSize.size20),
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(
                left: AppSize.size20,
                right: AppSize.size20,
                bottom: AppSize.size20),
            child: Row(
              children: [
                Expanded(
                    child: Obx(() => ShortButton(
                      onTap: () {
                        termsOfServiceController.select.value = 1;
                        Get.to(() => HomeScreen());
                      },
                      height: AppSize.size54,
                      buttonColor:
                      termsOfServiceController.select.value == 1
                          ? AppColors.blackTextColor
                          : AppColors.backGroundColor,
                      borderColor: AppColors.blackTextColor,
                      text: AppStrings.decline,
                      textColor: termsOfServiceController.select.value == 1
                          ? AppColors.backGroundColor
                          : AppColors.blackTextColor,
                    ))),
                const CommonWidthSizedBox(width: AppSize.size19),
                Expanded(
                    child: ShortButton(
                      onTap: () {
                        termsOfServiceController.select.value = 2;
                        Get.to(() => HomeScreen());
                      },
                      height: AppSize.size54,
                      buttonColor: AppColors.blackTextColor,
                      borderColor: AppColors.blackTextColor,
                      text: AppStrings.accept,
                      textColor: AppColors.backGroundColor,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
