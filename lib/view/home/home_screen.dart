// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tshl_tawsil/common_widgets/common_height_sized_box.dart';
import 'package:tshl_tawsil/common_widgets/common_width_sized_box.dart';
import 'package:tshl_tawsil/config/app_colors.dart';
import 'package:tshl_tawsil/config/app_icons.dart';
import 'package:tshl_tawsil/config/app_images.dart';
import 'package:tshl_tawsil/config/app_size.dart';
import 'package:tshl_tawsil/config/app_strings.dart';
import 'package:tshl_tawsil/config/font_family.dart';
import 'package:tshl_tawsil/controllers/home_controller.dart';
import 'package:tshl_tawsil/models/ride_model.dart';
import 'package:tshl_tawsil/controllers/language_controller.dart';
import 'package:tshl_tawsil/view/destination/destination_screen.dart';
import 'package:tshl_tawsil/view/destination/select_route_screen.dart';
import 'package:tshl_tawsil/view/destination/select_route_with_map.dart';
import 'package:tshl_tawsil/view/my_rides/my_rides_screen.dart';
import 'package:tshl_tawsil/view/my_rides/my_rides_active_details_screen.dart';
import 'package:tshl_tawsil/view/points/points_screen.dart';
import 'package:tshl_tawsil/view/profile/profile_screen.dart';
import 'package:tshl_tawsil/view/safety/safety_screen.dart';
import 'package:tshl_tawsil/view/settings/settings_screen.dart';
import 'package:tshl_tawsil/view/widget/logout_bottom_sheet.dart';
import 'package:tshl_tawsil/api/services/profile_service.dart';
import 'package:tshl_tawsil/models/user_model.dart';

import '../../common_widgets/common_text_feild.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController homeController = Get.find<HomeController>();
  final LanguageController languageController = Get.put(LanguageController());
  final ProfileService _profileService = ProfileService();
  UserModel? _currentUser;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
      if (mounted) {
        homeController.loadActiveRide();
      }
    });
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = await _profileService.getProfile();
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    languageController.loadSelectedLanguage();
    return Center(
      child: Container(
        color: AppColors.backGroundColor,
        width: kIsWeb ? AppSize.size800 : null,
        child: Scaffold(
          drawer: Drawer(
            shape: const RoundedRectangleBorder(),
            width: AppSize.size250,
            backgroundColor: AppColors.backGroundColor,
            child: Column(
              children: [
                Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      height: AppSize.size73,
                      width: AppSize.size76,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                        image: AssetImage(
                          AppImages.menuBarImage,
                        ),
                        fit: BoxFit.fill,
                      )),
                    )),
                const CommonHeightSizedBox(height: AppSize.size12),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSize.size20),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: AppSize.size66,
                            spreadRadius: AppSize.size0,
                          )
                        ],
                        color: AppColors.backGroundColor,
                        borderRadius: BorderRadius.circular(AppSize.size10)),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSize.size12),
                      child: Row(
                        children: [
                          Container(
                            height: AppSize.size40,
                            width: AppSize.size40,
                            decoration: BoxDecoration(
                                color: AppColors.borderColor,
                                shape: BoxShape.circle),
                            child: const Center(
                              child: Text(
                                AppStrings.ar,
                                style: TextStyle(
                                  color: AppColors.blackTextColor,
                                  fontFamily: FontFamily.latoBold,
                                  fontSize: AppSize.size14,
                                ),
                              ),
                            ),
                          ),
                          const CommonWidthSizedBox(width: AppSize.size10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _currentUser != null
                                      ? 'Hello, ${_currentUser!.name}'
                                      : AppStrings.helloAlbert,
                                  style: const TextStyle(
                                    color: AppColors.blackTextColor,
                                    fontFamily: FontFamily.latoBold,
                                    fontSize: AppSize.size16,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const CommonHeightSizedBox(height: AppSize.size6),
                                Text(
                                  _currentUser != null
                                      ? _currentUser!.phone
                                      : AppStrings.demoMobile,
                                  style: const TextStyle(
                                    color: AppColors.smallTextColor,
                                    fontFamily: FontFamily.latoRegular,
                                    fontSize: AppSize.size12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const CommonHeightSizedBox(height: AppSize.size34),
                _buildProfile(),
                const CommonHeightSizedBox(height: AppSize.size24),
                _buildMyRides(),
                const CommonHeightSizedBox(height: AppSize.size24),
                _buildPoints(),
                const CommonHeightSizedBox(height: AppSize.size24),
                _buildSafety(),
                const CommonHeightSizedBox(height: AppSize.size24),
                _buildSetting(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSize.size32, vertical: AppSize.size40),
                  child: Divider(
                    height: AppSize.size0,
                    color: AppColors.dividerColor,
                    thickness: AppSize.size1,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSize.size32),
                  child: GestureDetector(
                    onTap: () {
                      logoutBottomSheet(context);
                    },
                    child: Row(
                      children: [
                        Image.asset(
                          AppIcons.logOut,
                          height: AppSize.size16,
                          width: AppSize.size16,
                        ),
                        const CommonWidthSizedBox(width: AppSize.size6),
                        const Text(
                          AppStrings.logOut,
                          style: TextStyle(
                            color: AppColors.redColor,
                            fontFamily: FontFamily.latoSemiBold,
                            fontSize: AppSize.size16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: AppColors.backGroundColor,
                        child: Obx(
                          () => GoogleMap(
                            myLocationEnabled: false,
                            myLocationButtonEnabled: true,
                            zoomControlsEnabled: false,
                            initialCameraPosition: const CameraPosition(
                              target:
                                  LatLng(AppSize.latitude, AppSize.longitude),
                              zoom: AppSize.size14,
                            ),
                            mapType: MapType.normal,
                            markers: Set.from(homeController.markers),
                            onMapCreated: (controller) {
                              homeController.gMapsFunctionCall(
                                  homeController.initialLocation);
                            },
                          ),
                        )),
                    Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top,
                          right: AppSize.size20,
                          left: AppSize.size20),
                      child: Row(
                        children: [
                          Padding(
                              padding:
                                  const EdgeInsets.only(top: AppSize.size12),
                              child: Builder(
                                builder: (BuildContext builderContext) {
                                  return GestureDetector(
                                    onTap: () {
                                      Scaffold.of(builderContext).openDrawer();
                                    },
                                    child: Container(
                                      height: AppSize.size46,
                                      width: AppSize.size46,
                                      decoration: BoxDecoration(
                                          color: AppColors.backGroundColor,
                                          borderRadius: BorderRadius.circular(
                                              AppSize.size10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.shadow,
                                              blurRadius: AppSize.size66,
                                              spreadRadius: AppSize.size0,
                                            )
                                          ]),
                                      child: Center(
                                          child: Image.asset(
                                        AppIcons.drawerIcon,
                                        height: AppSize.size20,
                                        width: AppSize.size20,
                                      )),
                                    ),
                                  );
                                },
                              )),
                          const CommonWidthSizedBox(
                            width: AppSize.size12,
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: AppSize.size12),
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      spreadRadius: AppSize.opacity10,
                                      color: AppColors.blackTextColor
                                          .withOpacity(AppSize.opacity10),
                                      blurRadius: AppSize.size20,
                                    ),
                                  ],
                                ),
                                child: CustomTextField(
                                  controller:
                                      homeController.userLocationController,
                                  hintText: AppStrings.enterLocation,
                                  hintFontSize: AppSize.size12,
                                  hintColor: AppColors.smallTextColor,
                                  hintTextColor: AppColors.smallTextColor,
                                  fontFamily: FontFamily.latoRegular,
                                  height: AppSize.size46,
                                  fillColor: AppColors.backGroundColor,
                                  cursorColor: AppColors.smallTextColor,
                                  fillFontFamily: FontFamily.latoSemiBold,
                                  fillFontWeight: FontWeight.w400,
                                  fillFontSize: AppSize.size12,
                                  fontWeight: FontWeight.w400,
                                  fillTextColor: AppColors.blackTextColor,
                                  readOnly: true, // Make field read-only to prevent typing
                                  onTap: () {
                                    // Only navigate to book ride if there's NO active ride
                                    if (homeController.activeRide.value == null) {
                                      Get.to(() => SelectRouteWithMapScreen(
                                        pickupAddress: homeController.userAddress.value,
                                        destinationAddress: '',
                                      ));
                                    }
                                    // If there IS an active ride, do nothing
                                  },
                                  suffixIcon: Obx(
                                    () => Padding(
                                      padding: EdgeInsets.only(
                                          right: languageController.arb.value
                                              ? AppSize.size7
                                              : AppSize.size16,
                                          left: languageController.arb.value
                                              ? AppSize.size16
                                              : AppSize.size7),
                                      child: Obx(
                                        () => homeController.like.value
                                            ? GestureDetector(
                                                onTap: () {
                                                  homeController.like.value =
                                                      false;
                                                },
                                                child: Image.asset(
                                                  AppIcons.likeFill,
                                                  height: AppSize.size18,
                                                  width: AppSize.size18,
                                                  color: AppColors.redColor,
                                                ),
                                              )
                                            : GestureDetector(
                                                onTap: () {
                                                  homeController.like.value =
                                                      true;
                                                },
                                                child: Image.asset(
                                                  AppIcons.like,
                                                  height: AppSize.size18,
                                                  width: AppSize.size18,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                  suffixIconConstraints: const BoxConstraints(
                                    maxWidth: AppSize.size38,
                                  ),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(
                                      left: AppSize.size12,
                                      right: AppSize.size8,
                                    ),
                                    child: Image.asset(
                                      AppIcons.mapIcon,
                                      height: AppSize.size18,
                                      width: AppSize.size18,
                                    ),
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                    maxWidth: AppSize.size36,
                                  ),
                                  contentPadding: const EdgeInsets.only(
                                      left: AppSize.size16,
                                      top: AppSize.size10,
                                      bottom: AppSize.size10),
                                ),
                              ),
                            ),
                          ),
                          const CommonWidthSizedBox(width: AppSize.size12),
                          Padding(
                            padding: const EdgeInsets.only(top: AppSize.size12),
                            child: GestureDetector(
                              onTap: () {
                                Get.to(() => const MyRidesScreen());
                              },
                              child: Container(
                                height: AppSize.size46,
                                width: AppSize.size46,
                                decoration: BoxDecoration(
                                    color: AppColors.backGroundColor,
                                    borderRadius: BorderRadius.circular(
                                        AppSize.size10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.shadow,
                                        blurRadius: AppSize.size66,
                                        spreadRadius: AppSize.size0,
                                      )
                                    ]),
                                child: Center(
                                    child: Image.asset(
                                  AppIcons.search,
                                  height: AppSize.size20,
                                  width: AppSize.size20,
                                  color: AppColors.blackTextColor,
                                )),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        homeController.onTapDirection();
                      },
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: AppSize.size20,
                            bottom: AppSize.size20,
                          ),
                          child: Image.asset(
                            AppIcons.gpsIcon,
                            width: AppSize.size38,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            GestureDetector(
                behavior: HitTestBehavior.translucent,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: AppSize.time200),
                  height: AppSize.size370,
                  padding: const EdgeInsets.only(
                    top: AppSize.size10,
                    left: AppSize.size20,
                    right: AppSize.size20,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppSize.size10),
                      topRight: Radius.circular(AppSize.size10),
                    ),
                    color: AppColors.backGroundColor,
                    boxShadow: [
                      BoxShadow(
                        spreadRadius: AppSize.size1,
                        blurRadius: AppSize.size17,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        AppIcons.bottomSheetIcon,
                        width: AppSize.size40,
                      ),
                      // Obx(
                      //   () =>
                        // languageController.arb.value
                            // ?
                        // Container(
                        //         height: AppSize.size82,
                        //         margin: const EdgeInsets.only(
                        //           top: AppSize.size24,
                        //         ),
                        //         padding: EdgeInsets.only(
                        //             left: languageController.arb.value
                        //                 ? 0
                        //                 : AppSize.size15,
                        //             right: languageController.arb.value
                        //                 ? AppSize.size15
                        //                 : 0),
                        //         decoration: BoxDecoration(
                        //           color: AppColors.backGroundColor,
                        //           border: Border.all(
                        //             color: AppColors.smallTextColor
                        //                 .withOpacity(AppSize.opacity10),
                        //           ),
                        //           borderRadius:
                        //               BorderRadius.circular(AppSize.size10),
                        //         ),
                        //         child: GridView.builder(
                        //           shrinkWrap: true,
                        //           gridDelegate:
                        //               const SliverGridDelegateWithFixedCrossAxisCount(
                        //             crossAxisCount: AppSize.four,
                        //             mainAxisExtent: AppSize.size64,
                        //             crossAxisSpacing: AppSize.size15,
                        //           ),
                        //           physics: const NeverScrollableScrollPhysics(),
                        //           padding: const EdgeInsets.only(
                        //             top: AppSize.size15,
                        //           ),
                        //           itemCount:
                        //               homeController.serviceString.length,
                        //           itemBuilder: (context, index) {
                        //             return GestureDetector(
                        //               onTap: () {
                        //                 homeController.setServiceIndex(index);
                        //               },
                        //               child: Obx(() => SizedBox(
                        //                     width: AppSize.size30,
                        //                     child: Row(
                        //                       mainAxisAlignment:
                        //                           MainAxisAlignment
                        //                               .spaceBetween,
                        //                       children: [
                        //                         Column(
                        //                           crossAxisAlignment:
                        //                               CrossAxisAlignment.center,
                        //                           mainAxisAlignment:
                        //                               MainAxisAlignment
                        //                                   .spaceBetween,
                        //                           children: [
                        //                             Image.asset(
                        //                               homeController
                        //                                   .serviceIcon[index],
                        //                               width: AppSize.size30,
                        //                             ),
                        //                             Text(
                        //                               homeController
                        //                                   .serviceString[index],
                        //                               style: TextStyle(
                        //                                 fontSize:
                        //                                     AppSize.size12,
                        //                                 fontFamily: FontFamily
                        //                                     .latoRegular,
                        //                                 fontWeight:
                        //                                     FontWeight.w400,
                        //                                 color: homeController
                        //                                             .selectedServiceIndex
                        //                                             .value ==
                        //                                         index
                        //                                     ? AppColors
                        //                                         .blackTextColor
                        //                                     : AppColors
                        //                                         .smallTextColor,
                        //                               ),
                        //                             ),
                        //                             if (homeController
                        //                                     .selectedServiceIndex
                        //                                     .value ==
                        //                                 index) ...[
                        //                               Padding(
                        //                                 padding:
                        //                                     const EdgeInsets
                        //                                         .only(
                        //                                   top: AppSize.size5,
                        //                                 ),
                        //                                 child: Image.asset(
                        //                                   AppIcons
                        //                                       .selectLineIcon,
                        //                                   width: AppSize.size30,
                        //                                 ),
                        //                               ),
                        //                             ] else
                        //                               Padding(
                        //                                 padding:
                        //                                     const EdgeInsets
                        //                                         .only(
                        //                                   top: AppSize.size5,
                        //                                 ),
                        //                                 child: Image.asset(
                        //                                   AppIcons
                        //                                       .selectLineIcon,
                        //                                   width: AppSize.size30,
                        //                                   color: AppColors
                        //                                       .backGroundColor,
                        //                                 ),
                        //                               ),
                        //                           ],
                        //                         ),
                        //                       ],
                        //                     ),
                        //                   )),
                        //             );
                        //           },
                        //         ),
                        //       )
                        //     :
                        // Container(
                        //         height: AppSize.size82,
                        //         margin: const EdgeInsets.only(
                        //           top: AppSize.size24,
                        //         ),
                        //         padding: EdgeInsets.only(
                        //             left: languageController.arb.value
                        //                 ? 0
                        //                 : AppSize.size15,
                        //             right: languageController.arb.value
                        //                 ? AppSize.size15
                        //                 : 0),
                        //         decoration: BoxDecoration(
                        //           color: AppColors.backGroundColor,
                        //           border: Border.all(
                        //             color: AppColors.smallTextColor
                        //                 .withOpacity(AppSize.opacity10),
                        //           ),
                        //           borderRadius:
                        //               BorderRadius.circular(AppSize.size10),
                        //         ),
                        //         child: GridView.builder(
                        //           shrinkWrap: true,
                        //           gridDelegate:
                        //               const SliverGridDelegateWithFixedCrossAxisCount(
                        //             crossAxisCount: AppSize.four,
                        //             mainAxisExtent: AppSize.size64,
                        //             crossAxisSpacing: AppSize.size15,
                        //           ),
                        //           physics: const NeverScrollableScrollPhysics(),
                        //           padding: const EdgeInsets.only(
                        //             top: AppSize.size15,
                        //           ),
                        //           itemCount:
                        //               homeController.serviceString.length,
                        //           itemBuilder: (context, index) {
                        //             return GestureDetector(
                        //               onTap: () {
                        //                 homeController.setServiceIndex(index);
                        //               },
                        //               child: Obx(() => SizedBox(
                        //                     width: AppSize.size30,
                        //                     child: Row(
                        //                       mainAxisAlignment:
                        //                           MainAxisAlignment
                        //                               .spaceBetween,
                        //                       children: [
                        //                         Column(
                        //                           crossAxisAlignment:
                        //                               CrossAxisAlignment.center,
                        //                           mainAxisAlignment:
                        //                               MainAxisAlignment
                        //                                   .spaceBetween,
                        //                           children: [
                        //                             Image.asset(
                        //                               homeController
                        //                                   .serviceIcon[index],
                        //                               width: AppSize.size30,
                        //                             ),
                        //                             Text(
                        //                               homeController
                        //                                   .serviceString[index],
                        //                               style: TextStyle(
                        //                                 fontSize:
                        //                                     AppSize.size12,
                        //                                 fontFamily: FontFamily
                        //                                     .latoRegular,
                        //                                 fontWeight:
                        //                                     FontWeight.w400,
                        //                                 color: homeController
                        //                                             .selectedServiceIndex
                        //                                             .value ==
                        //                                         index
                        //                                     ? AppColors
                        //                                         .blackTextColor
                        //                                     : AppColors
                        //                                         .smallTextColor,
                        //                               ),
                        //                             ),
                        //                             if (homeController
                        //                                     .selectedServiceIndex
                        //                                     .value ==
                        //                                 index) ...[
                        //                               Padding(
                        //                                 padding:
                        //                                     const EdgeInsets
                        //                                         .only(
                        //                                   top: AppSize.size5,
                        //                                 ),
                        //                                 child: Image.asset(
                        //                                   AppIcons
                        //                                       .selectLineIcon,
                        //                                   width: AppSize.size30,
                        //                                 ),
                        //                               ),
                        //                             ] else
                        //                               Padding(
                        //                                 padding:
                        //                                     const EdgeInsets
                        //                                         .only(
                        //                                   top: AppSize.size5,
                        //                                 ),
                        //                                 child: Image.asset(
                        //                                   AppIcons
                        //                                       .selectLineIcon,
                        //                                   width: AppSize.size30,
                        //                                   color: AppColors
                        //                                       .backGroundColor,
                        //                                 ),
                        //                               ),
                        //                           ],
                        //                         ),
                        //                       ],
                        //                     ),
                        //                   )),
                        //             );
                        //           },
                        //         ),
                        //       )
                      // ),
                      Obx(() => homeController.activeRide.value != null
                        ? _buildActiveRideCard(homeController.activeRide.value!)
                        : _buildNoActiveRideCard(),
                      ),
                    ],
                  ),
                ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Padding _buildProfile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSize.size32),
      child: GestureDetector(
        onTap: () {
          Get.to(() => ProfileScreen());
        },
        child: Row(
          children: [
            Container(
              height: AppSize.size24,
              width: AppSize.size24,
              decoration: const BoxDecoration(
                  color: AppColors.lightTheme, shape: BoxShape.circle),
              child: Center(
                  child: Image.asset(
                AppIcons.user,
                height: AppSize.size14,
                width: AppSize.size14,
              )),
            ),
            const CommonWidthSizedBox(width: AppSize.size8),
            const Text(
              AppStrings.profile,
              style: TextStyle(
                color: AppColors.blackTextColor,
                fontFamily: FontFamily.latoSemiBold,
                fontSize: AppSize.size16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding _buildMyRides() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSize.size32),
      child: GestureDetector(
        onTap: () {
          Get.to(() => MyRidesScreen());
        },
        child: Row(
          children: [
            Container(
              height: AppSize.size24,
              width: AppSize.size24,
              decoration: const BoxDecoration(
                  color: AppColors.lightTheme, shape: BoxShape.circle),
              child: Center(
                  child: Image.asset(
                AppIcons.scooter,
                height: AppSize.size14,
                width: AppSize.size14,
              )),
            ),
            const CommonWidthSizedBox(width: AppSize.size8),
            const Text(
              AppStrings.myRides,
              style: TextStyle(
                color: AppColors.blackTextColor,
                fontFamily: FontFamily.latoSemiBold,
                fontSize: AppSize.size16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding _buildPoints() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSize.size32),
      child: GestureDetector(
        onTap: () {
          Get.to(() => const PointsScreen());
        },
        child: Row(
          children: [
            Container(
              height: AppSize.size24,
              width: AppSize.size24,
              decoration: const BoxDecoration(
                  color: AppColors.lightTheme, shape: BoxShape.circle),
              child: Center(
                  child: Image.asset(
                AppIcons.dollarIcon,
                height: AppSize.size14,
                width: AppSize.size14,
              )),
            ),
            const CommonWidthSizedBox(width: AppSize.size8),
            const Text(
              'Points',
              style: TextStyle(
                color: AppColors.blackTextColor,
                fontFamily: FontFamily.latoSemiBold,
                fontSize: AppSize.size16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding _buildSafety() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSize.size32),
      child: GestureDetector(
        onTap: () {
          Get.to(() => SafetyScreen());
        },
        child: Row(
          children: [
            Container(
              height: AppSize.size24,
              width: AppSize.size24,
              decoration: const BoxDecoration(
                  color: AppColors.lightTheme, shape: BoxShape.circle),
              child: Center(
                  child: Image.asset(
                AppIcons.verify,
                height: AppSize.size14,
                width: AppSize.size14,
              )),
            ),
            const CommonWidthSizedBox(width: AppSize.size8),
            const Text(
              AppStrings.safety,
              style: TextStyle(
                color: AppColors.blackTextColor,
                fontFamily: FontFamily.latoSemiBold,
                fontSize: AppSize.size16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding _buildSetting() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSize.size32),
      child: GestureDetector(
        onTap: () {
          Get.to(() => SettingsScreen());
        },
        child: Row(
          children: [
            Container(
              height: AppSize.size24,
              width: AppSize.size24,
              decoration: const BoxDecoration(
                  color: AppColors.lightTheme, shape: BoxShape.circle),
              child: Center(
                  child: Image.asset(
                AppIcons.settings,
                height: AppSize.size14,
                width: AppSize.size14,
              )),
            ),
            const CommonWidthSizedBox(width: AppSize.size8),
            const Text(
              AppStrings.settings,
              style: TextStyle(
                color: AppColors.blackTextColor,
                fontFamily: FontFamily.latoSemiBold,
                fontSize: AppSize.size16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveRideCard(RideModel ride) {
    // Use status_color from API or fallback to default
    Color statusColor;
    switch (ride.statusColor) {
      case 'warning':
        statusColor = Colors.orange;
        break;
      case 'success':
        statusColor = AppColors.greenColor;
        break;
      case 'danger':
        statusColor = AppColors.redColor;
        break;
      case 'info':
        statusColor = AppColors.primaryColor;
        break;
      default:
        statusColor = AppColors.primaryColor;
    }

    // Use status_text from API or fallback
    String statusText = ride.statusText ?? ride.status.toUpperCase();

    return GestureDetector(
      onTap: () {
        Get.to(() => MyRidesActiveDetailsScreen(rideId: ride.id));
      },
      child: Container(
        margin: const EdgeInsets.only(top: AppSize.size16),
        padding: const EdgeInsets.all(AppSize.size16),
        decoration: BoxDecoration(
          color: AppColors.backGroundColor,
          borderRadius: BorderRadius.circular(AppSize.size10),
          border: Border.all(
            color: AppColors.smallTextColor.withOpacity(AppSize.opacity10),
          ),
          boxShadow: [
            BoxShadow(
              spreadRadius: AppSize.size2,
              color: AppColors.blackTextColor.withOpacity(AppSize.opacity10),
              blurRadius: AppSize.size20,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: AppSize.size8),
                      child: Image.asset(
                        AppIcons.carModelIcon,
                        width: AppSize.size24,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSize.size6),
                          child: Row(
                            children: [
                              const Text(
                                'Current Ride',
                                style: TextStyle(
                                  fontSize: AppSize.size16,
                                  fontFamily: FontFamily.latoBold,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.blackTextColor,
                                ),
                              ),
                              if (ride.distanceKm != null) ...[
                                const SizedBox(width: AppSize.size8),
                                Text(
                                  '${ride.distanceKm!.toStringAsFixed(1)} km',
                                  style: const TextStyle(
                                    fontSize: AppSize.size12,
                                    fontFamily: FontFamily.latoRegular,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.smallTextColor,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Text(
                          '\$${ride.finalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: AppSize.size12,
                            fontFamily: FontFamily.latoRegular,
                            fontWeight: FontWeight.w400,
                            color: AppColors.smallTextColor,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: AppSize.size12),
                          child: Row(
                            children: [
                              Container(
                                width: AppSize.size10,
                                height: AppSize.size10,
                                margin: const EdgeInsets.only(right: AppSize.size6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.greenColor,
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    width: AppSize.size6,
                                    height: AppSize.size6,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.greenColor,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: AppSize.size150,
                                child: Text(
                                  ride.pickupAddress,
                                  style: const TextStyle(
                                    fontSize: AppSize.size12,
                                    fontFamily: FontFamily.latoRegular,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.blackTextColor,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: AppSize.size4),
                          height: AppSize.size12,
                          width: AppSize.size1,
                          color: AppColors.smallTextColor,
                        ),
                        Row(
                          children: [
                            Container(
                              width: AppSize.size10,
                              height: AppSize.size10,
                              margin: const EdgeInsets.only(right: AppSize.size6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.redColor,
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  width: AppSize.size6,
                                  height: AppSize.size6,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.redColor,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: AppSize.size150,
                              child: Text(
                                ride.dropoffAddress,
                                style: const TextStyle(
                                  fontSize: AppSize.size12,
                                  fontFamily: FontFamily.latoRegular,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.blackTextColor,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: AppSize.size12,
                        fontFamily: FontFamily.latoMedium,
                        fontWeight: FontWeight.w500,
                        color: statusColor,
                      ),
                    ),
                    if (ride.driver != null)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSize.size38),
                        child: Image.asset(
                          AppIcons.man1Icon,
                          width: AppSize.size28,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoActiveRideCard() {
    return Container(
      margin: const EdgeInsets.only(top: AppSize.size16),
      padding: const EdgeInsets.all(AppSize.size20),
      decoration: BoxDecoration(
        color: AppColors.backGroundColor,
        borderRadius: BorderRadius.circular(AppSize.size10),
        border: Border.all(
          color: AppColors.smallTextColor.withOpacity(AppSize.opacity10),
        ),
      ),
      child: Column(
        children: [
          Image.asset(
            AppIcons.carModelIcon,
            width: AppSize.size80,
            color: AppColors.smallTextColor,
          ),
          const SizedBox(height: AppSize.size12),
          const Text(
            'No Active Ride',
            style: TextStyle(
              fontSize: AppSize.size16,
              fontFamily: FontFamily.latoBold,
              fontWeight: FontWeight.w700,
              color: AppColors.blackTextColor,
            ),
          ),
          const SizedBox(height: AppSize.size8),
          const Text(
            'Book a ride to get started',
            style: TextStyle(
              fontSize: AppSize.size12,
              fontFamily: FontFamily.latoRegular,
              fontWeight: FontWeight.w400,
              color: AppColors.smallTextColor,
            ),
          ),
          const SizedBox(height: AppSize.size16),
          GestureDetector(
            onTap: () {
              Get.to(() => SelectRouteWithMapScreen());
            },
            child: Container(
              height: AppSize.size46,
              decoration: BoxDecoration(
                color: AppColors.blackTextColor,
                borderRadius: BorderRadius.circular(AppSize.size10),
              ),
              child: const Center(
                child: Text(
                  'Book a Ride',
                  style: TextStyle(
                    fontSize: AppSize.size14,
                    fontFamily: FontFamily.latoSemiBold,
                    fontWeight: FontWeight.w600,
                    color: AppColors.backGroundColor,
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
