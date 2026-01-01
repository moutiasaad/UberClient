import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tshl_tawsil/config/app_colors.dart';
import 'package:tshl_tawsil/config/app_size.dart';
import 'package:tshl_tawsil/config/font_family.dart';
import 'package:tshl_tawsil/view/welcome/welcome_screen.dart';

deleteAccountBottomSheet(BuildContext context) {
  return showModalBottomSheet(
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(
      maxWidth: kIsWeb ? AppSize.size800 : double.infinity,
    ),
    isScrollControlled: true,
    shape: const OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(AppSize.size10),
        topRight: Radius.circular(AppSize.size10),
      ),
      borderSide: BorderSide.none,
    ),
    context: context,
    builder: (context) {
      return Container(
        height: AppSize.size228,
        width: double.infinity,
        padding: const EdgeInsets.only(
          top: AppSize.size20,
          left: AppSize.size20,
          right: AppSize.size20,
          bottom: AppSize.size40,
        ),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(AppSize.size10),
            topLeft: Radius.circular(AppSize.size10),
          ),
          color: AppColors.backGroundColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    bottom: AppSize.size16,
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Delete Account',
                      style: TextStyle(
                        fontFamily: FontFamily.latoBold,
                        fontWeight: FontWeight.w700,
                        fontSize: AppSize.size20,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
                Text(
                  'Are you sure you want to delete your account? This action cannot be undone.',
                  style: TextStyle(
                    fontFamily: FontFamily.latoMedium,
                    fontWeight: FontWeight.w500,
                    fontSize: AppSize.size14,
                    color: AppColors.smallTextColor,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      height: AppSize.size54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSize.size10),
                        border: Border.all(
                          color: AppColors.blackTextColor,
                          width: AppSize.size1,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: AppSize.size16,
                            fontWeight: FontWeight.w600,
                            fontFamily: FontFamily.latoSemiBold,
                            color: AppColors.blackTextColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: AppSize.size19,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // TODO: Call delete account API
                      Get.offAll(() => const WelcomeScreen());
                    },
                    child: Container(
                      height: AppSize.size54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSize.size10),
                        color: Colors.red,
                      ),
                      child: const Center(
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: AppSize.size16,
                            fontWeight: FontWeight.w600,
                            fontFamily: FontFamily.latoSemiBold,
                            color: AppColors.backGroundColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
