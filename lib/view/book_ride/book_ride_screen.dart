// ignore_for_file: must_be_immutable
// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:prime_taxi_flutter_ui_kit/controllers/book_ride_controller.dart';
import 'package:prime_taxi_flutter_ui_kit/controllers/language_controller.dart';
import 'package:prime_taxi_flutter_ui_kit/controllers/select_route_with_map_controller.dart';
import 'package:prime_taxi_flutter_ui_kit/view/book_ride/book_ride_full_screen.dart';
import 'package:prime_taxi_flutter_ui_kit/view/widget/auto_details_bottom_sheet.dart';
import 'package:prime_taxi_flutter_ui_kit/view/widget/schedule_a_ride_bottom_sheet.dart';

import '../../config/app_colors.dart';
import '../../config/app_icons.dart';
import '../../config/app_size.dart';
import '../../config/app_strings.dart';
import '../../config/font_family.dart';

class BookRideScreen extends StatelessWidget {
  BookRideScreen({Key? key}) : super(key: key);

  SelectRouteWithMapController selectRouteWithMapController =
      Get.put(SelectRouteWithMapController());
  BookRideController bookRideController = Get.find<BookRideController>();
  final LanguageController languageController = Get.put(LanguageController());

  @override
  Widget build(BuildContext context) {
    languageController.loadSelectedLanguage();
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.dark));
    return Center(
      child: Container(
        color: AppColors.backGroundColor,
        width: kIsWeb ? AppSize.size800 : null,
        child: Scaffold(
          backgroundColor: AppColors.backGroundColor,
          body: _bookRideContent(context),
        ),
      ),
    );
  }

  //Book Ride Content
  _appBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: AppSize.size0,
      automaticallyImplyLeading: false,
      title: Padding(
        padding:
            const EdgeInsets.only(left: AppSize.size5, top: AppSize.size10),
        child: Align(
          alignment: Alignment.topLeft,
          child: GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Image.asset(
              AppIcons.arrowBack,
              width: AppSize.size20,
            ),
          ),
        ),
      ),
    );
  }

  _bookRideContent(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          // height: AppSize.size282,
          color: AppColors.backGroundColor,
          child: Obx(
            () => GoogleMap(
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              initialCameraPosition: const CameraPosition(
                target: LatLng(AppSize.latitude, AppSize.longitude72),
                zoom: AppSize.size13,
              ),
              mapType: MapType.normal,
              markers: Set.from(selectRouteWithMapController.markers),
              polylines: selectRouteWithMapController.showPolyline.value
                  ? Set.from(selectRouteWithMapController.polylines)
                  : <Polyline>{},
              onMapCreated: (controller) {
                selectRouteWithMapController.myMapController = controller;
                selectRouteWithMapController.gMapsFunctionCall(
                    selectRouteWithMapController.initialLocation);
              },
            ),
          ),
        ),
        _appBar(),
        Align(
          alignment: Alignment.bottomCenter,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppSize.size12,
                    right: AppSize.size20,
                  ),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () {
                        Get.to(() => BookRideFullScreen());
                      },
                      child: Image.asset(
                        AppIcons.fullScreenIcon,
                        width: AppSize.size38,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      bottom: Platform.isAndroid ? AppSize.size30 : AppSize.size10),
                  child: Container(
                    height: AppSize.size616,
                    decoration: const BoxDecoration(
                      color: AppColors.backGroundColor,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(AppSize.size10),
                        topLeft: Radius.circular(AppSize.size10),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(AppSize.size10),
                              topLeft: Radius.circular(AppSize.size10),
                            ),
                            child: Container(
                              height: AppSize.size560,
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(AppSize.size10),
                                  topLeft: Radius.circular(AppSize.size10),
                                ),
                                color: AppColors.backGroundColor,
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      color: AppColors.backGroundColor,
                                      child: SingleChildScrollView(
                                        padding: const EdgeInsets.only(
                                          top: AppSize.size10,
                                          left: AppSize.size20,
                                          right: AppSize.size20,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: AppSize.size20,
                                              ),
                                              child: Align(
                                                alignment: Alignment.topCenter,
                                                child: Image.asset(
                                                  AppIcons.bottomSheetIcon,
                                                  width: AppSize.size40,
                                                ),
                                              ),
                                            ),
                                            Obx(() => Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text(
                                                  AppStrings.distance,
                                                  style: TextStyle(
                                                    fontFamily: FontFamily.latoBold,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: AppSize.size20,
                                                    color: AppColors.blackTextColor,
                                                  ),
                                                ),
                                                Text(
                                                  bookRideController.fareData.value != null
                                                      ? '${bookRideController.fareData.value!.distanceFare.toStringAsFixed(1)} km'
                                                      : bookRideController.isLoadingFare.value
                                                          ? 'Calculating...'
                                                          : '-- km',
                                                  style: const TextStyle(
                                                    fontFamily:
                                                        FontFamily.latoRegular,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: AppSize.size14,
                                                    color: AppColors.blackTextColor,
                                                  ),
                                                ),
                                              ],
                                            )),
                                            Divider(
                                              color: AppColors.smallTextColor
                                                  .withOpacity(AppSize.opacity10),
                                              height: AppSize.size28,
                                            ),
                                            Padding(
                                                padding: const EdgeInsets.only(
                                                  top: AppSize.size10,
                                                ),
                                                child: Obx(
                                                  () => Stack(
                                                    alignment:
                                                        languageController.arb.value
                                                            ? Alignment.topRight
                                                            : Alignment.topLeft,
                                                    children: [
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          color: AppColors
                                                              .backGroundColor,
                                                          border: Border.all(
                                                            color: AppColors
                                                                .smallTextColor
                                                                .withOpacity(AppSize
                                                                    .opacity15),
                                                            width: AppSize.size1and5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  AppSize.size10),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              spreadRadius:
                                                                  AppSize.size1,
                                                              color: AppColors
                                                                  .blackTextColor
                                                                  .withOpacity(AppSize
                                                                      .opacity10),
                                                              blurRadius:
                                                                  AppSize.size20,
                                                            ),
                                                          ],
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            ListTile(
                                                              dense: true,
                                                              minLeadingWidth:
                                                                  AppSize.size16,
                                                              leading: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                  top: AppSize.size7,
                                                                ),
                                                                child: Container(
                                                                  width:
                                                                      AppSize.size14,
                                                                  height:
                                                                      AppSize.size14,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    border:
                                                                        Border.all(
                                                                      color: Colors
                                                                          .green,
                                                                      width: AppSize
                                                                          .size1,
                                                                    ),
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                  child: Center(
                                                                    child: Container(
                                                                      width: AppSize
                                                                          .size8,
                                                                      height: AppSize
                                                                          .size8,
                                                                      decoration:
                                                                          const BoxDecoration(
                                                                        color: Colors
                                                                            .green,
                                                                        shape: BoxShape
                                                                            .circle,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              title: TextField(
                                                                decoration:
                                                                    const InputDecoration(
                                                                  contentPadding:
                                                                      EdgeInsets.zero,
                                                                  hintText: AppStrings
                                                                      .yourLocation,
                                                                  hintStyle:
                                                                      TextStyle(
                                                                    fontSize: AppSize
                                                                        .size14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    fontFamily:
                                                                        FontFamily
                                                                            .latoRegular,
                                                                    color: AppColors
                                                                        .smallTextColor,
                                                                  ),
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide
                                                                            .none,
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide
                                                                            .none,
                                                                  ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide
                                                                            .none,
                                                                  ),
                                                                ),
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize:
                                                                      AppSize.size14,
                                                                  fontWeight:
                                                                      FontWeight.w400,
                                                                  fontFamily:
                                                                      FontFamily
                                                                          .latoRegular,
                                                                  color: AppColors
                                                                      .blackTextColor,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                                cursorColor: AppColors
                                                                    .smallTextColor,
                                                                controller:
                                                                    bookRideController
                                                                        .locationController,
                                                              ),
                                                            ),
                                                            Obx(
                                                              () => Padding(
                                                                padding:
                                                                    EdgeInsets.only(
                                                                  left:
                                                                      languageController
                                                                              .arb
                                                                              .value
                                                                          ? 0
                                                                          : AppSize
                                                                              .size30,
                                                                  right:
                                                                      languageController
                                                                              .arb
                                                                              .value
                                                                          ? AppSize
                                                                              .size30
                                                                          : 0,
                                                                ),
                                                                child: DottedLine(
                                                                  direction:
                                                                      Axis.horizontal,
                                                                  alignment:
                                                                      WrapAlignment
                                                                          .center,
                                                                  lineLength: kIsWeb
                                                                      ? AppSize
                                                                          .size680
                                                                      : AppSize
                                                                          .size255,
                                                                  lineThickness:
                                                                      AppSize.size1,
                                                                  dashLength:
                                                                      AppSize.size4,
                                                                  dashColor: AppColors
                                                                      .smallTextColor
                                                                      .withOpacity(AppSize
                                                                          .opacity20),
                                                                  dashRadius:
                                                                      AppSize.size0,
                                                                  dashGapLength:
                                                                      AppSize.size4,
                                                                  dashGapColor: Colors
                                                                      .transparent,
                                                                  dashGapRadius:
                                                                      AppSize.size0,
                                                                ),
                                                              ),
                                                            ),
                                                            ListTile(
                                                              dense: true,
                                                              minLeadingWidth:
                                                                  AppSize.size16,
                                                              leading: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                  top: AppSize.size6,
                                                                ),
                                                                child: Container(
                                                                  width:
                                                                      AppSize.size14,
                                                                  height:
                                                                      AppSize.size14,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    border:
                                                                        Border.all(
                                                                      color: Colors
                                                                          .yellow,
                                                                      width: AppSize
                                                                          .size1,
                                                                    ),
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                  child: Center(
                                                                    child: Container(
                                                                      width: AppSize
                                                                          .size8,
                                                                      height: AppSize
                                                                          .size8,
                                                                      decoration:
                                                                          const BoxDecoration(
                                                                        color: Colors
                                                                            .yellow,
                                                                        shape: BoxShape
                                                                            .circle,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              title: TextField(
                                                                decoration:
                                                                    const InputDecoration(
                                                                  contentPadding:
                                                                      EdgeInsets.zero,
                                                                  hintText: AppStrings
                                                                      .enterDestination,
                                                                  hintStyle:
                                                                      TextStyle(
                                                                    fontSize: AppSize
                                                                        .size14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    fontFamily:
                                                                        FontFamily
                                                                            .latoRegular,
                                                                    color: AppColors
                                                                        .smallTextColor,
                                                                  ),
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide
                                                                            .none,
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide
                                                                            .none,
                                                                  ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide
                                                                            .none,
                                                                  ),
                                                                ),
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize:
                                                                      AppSize.size14,
                                                                  fontWeight:
                                                                      FontWeight.w400,
                                                                  fontFamily:
                                                                      FontFamily
                                                                          .latoRegular,
                                                                  color: AppColors
                                                                      .blackTextColor,
                                                                ),
                                                                cursorColor: AppColors
                                                                    .smallTextColor,
                                                                controller:
                                                                    bookRideController
                                                                        .destinationController,
                                                              ),
                                                              trailing:
                                                                  GestureDetector(
                                                                onTap: () {},
                                                                child: Image.asset(
                                                                  AppIcons.editIcon,
                                                                  width:
                                                                      AppSize.size16,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets.only(
                                                          left: languageController
                                                                  .arb.value
                                                              ? 0
                                                              : AppSize.size23,
                                                          right: languageController
                                                                  .arb.value
                                                              ? AppSize.size23
                                                              : 0,
                                                          top: AppSize.size45,
                                                        ),
                                                        child: Container(
                                                          width: AppSize.size1,
                                                          height: AppSize.size46,
                                                          color: AppColors
                                                              .smallTextColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: AppSize.size24,
                                              ),
                                              child: GestureDetector(
                                                onTap: () {
                                                  scheduleARideBottomSheet(context);
                                                },
                                                child: Obx(() => Container(
                                                  height: AppSize.size54,
                                                  padding: const EdgeInsets.only(
                                                    left: AppSize.size16,
                                                    right: AppSize.size16,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.backGroundColor,
                                                    border: Border.all(
                                                      color: bookRideController.selectedTime.value != null
                                                          ? AppColors.primaryColor
                                                          : AppColors.smallTextColor.withOpacity(AppSize.opacity15),
                                                      width: AppSize.size1and5,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            AppSize.size10),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        spreadRadius: AppSize.size1,
                                                        color: AppColors
                                                            .blackTextColor
                                                            .withOpacity(
                                                                AppSize.opacity10),
                                                        blurRadius: AppSize.size20,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Obx(
                                                            () => Padding(
                                                              padding:
                                                                  EdgeInsets.only(
                                                                right:
                                                                    languageController
                                                                            .arb.value
                                                                        ? 0
                                                                        : AppSize
                                                                            .size10,
                                                                left:
                                                                    languageController
                                                                            .arb.value
                                                                        ? AppSize
                                                                            .size10
                                                                        : 0,
                                                              ),
                                                              child: Image.asset(
                                                                AppIcons.alarmIcon,
                                                                width: AppSize.size18,
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                            bookRideController.formattedSelectedTime,
                                                            style: TextStyle(
                                                              fontSize:
                                                                  AppSize.size14,
                                                              fontWeight:
                                                                  FontWeight.w600,
                                                              fontFamily: FontFamily
                                                                  .latoSemiBold,
                                                              color: bookRideController.selectedTime.value != null
                                                                  ? AppColors.primaryColor
                                                                  : AppColors.blackTextColor,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Image.asset(
                                                        AppIcons.rightArrowIcon,
                                                        width: AppSize.size16,
                                                      ),
                                                    ],
                                                  ),
                                                )),
                                              ),
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.only(
                                                top: AppSize.size20,
                                                bottom: AppSize.size16,
                                              ),
                                              child: Text(
                                                AppStrings.recommendedRides,
                                                style: TextStyle(
                                                  fontFamily: FontFamily.latoBold,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: AppSize.size16,
                                                  color: AppColors.blackTextColor,
                                                ),
                                              ),
                                            ),
                                            // Car ride option only
                                            Obx(() => Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: AppSize.size16,
                                              ),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: AppColors.backGroundColor,
                                                  border: Border.all(
                                                    color: AppColors.primaryColor,
                                                    width: AppSize.size1and5,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          AppSize.size10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      spreadRadius: AppSize.opacity10,
                                                      color: AppColors.blackTextColor
                                                          .withOpacity(AppSize.opacity10),
                                                      blurRadius: AppSize.size10,
                                                    ),
                                                  ],
                                                ),
                                                child: ListTile(
                                                  horizontalTitleGap: AppSize.size7,
                                                  dense: true,
                                                  leading: Image.asset(
                                                    AppIcons.carIcon,
                                                    width: AppSize.size32,
                                                  ),
                                                  title: const Text(
                                                    AppStrings.car,
                                                    style: TextStyle(
                                                      fontSize: AppSize.size14,
                                                      fontWeight: FontWeight.w700,
                                                      fontFamily: FontFamily.latoBold,
                                                      color: AppColors.blackTextColor,
                                                    ),
                                                  ),
                                                  subtitle: const Text(
                                                    AppStrings.getCarAtYourDoorStep,
                                                    style: TextStyle(
                                                      fontSize: AppSize.size12,
                                                      fontWeight: FontWeight.w400,
                                                      fontFamily: FontFamily.latoRegular,
                                                      color: AppColors.smallTextColor,
                                                    ),
                                                  ),
                                                  trailing: SizedBox(
                                                    width: AppSize.size100,
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.only(
                                                            right: AppSize.size6,
                                                          ),
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              autoDetailsBottomSheet(context);
                                                            },
                                                            child: Image.asset(
                                                              AppIcons.infoIcon,
                                                              width: AppSize.size14,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          bookRideController.fareData.value != null
                                                              ? '\$${bookRideController.fareData.value!.totalFare.toStringAsFixed(2)}'
                                                              : bookRideController.isLoadingFare.value
                                                                  ? '...'
                                                                  : '\$--',
                                                          style: const TextStyle(
                                                            fontFamily: FontFamily.latoMedium,
                                                            fontWeight: FontWeight.w500,
                                                            fontSize: AppSize.size14,
                                                            color: AppColors.blackTextColor,
                                                          ),
                                                        ),
                                                        Container(
                                                          width: AppSize.size16,
                                                          height: AppSize.size16,
                                                          margin: EdgeInsets.only(
                                                            right: languageController.arb.value
                                                                ? AppSize.size8
                                                                : 0,
                                                            left: languageController.arb.value
                                                                ? 0
                                                                : AppSize.size8,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            border: Border.all(
                                                              color: AppColors.primaryColor,
                                                            ),
                                                            shape: BoxShape.circle,
                                                          ),
                                                          child: Center(
                                                            child: Container(
                                                              width: AppSize.size8,
                                                              height: AppSize.size8,
                                                              decoration: const BoxDecoration(
                                                                color: AppColors.primaryColor,
                                                                shape: BoxShape.circle,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )),
                                            // Select Payment title
                                            const Padding(
                                              padding: EdgeInsets.only(
                                                top: AppSize.size8,
                                                bottom: AppSize.size16,
                                              ),
                                              child: Text(
                                                'Select Payment',
                                                style: TextStyle(
                                                  fontFamily: FontFamily.latoBold,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: AppSize.size16,
                                                  color: AppColors.blackTextColor,
                                                ),
                                              ),
                                            ),
                                            // Cash option
                                            Obx(() => GestureDetector(
                                              onTap: () {
                                                bookRideController.selectedPaymentMethod.value = 'cash';
                                              },
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                  bottom: AppSize.size12,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.backGroundColor,
                                                  border: Border.all(
                                                    color: bookRideController.selectedPaymentMethod.value == 'cash'
                                                        ? AppColors.primaryColor
                                                        : AppColors.smallTextColor.withOpacity(AppSize.opacity15),
                                                    width: AppSize.size1and5,
                                                  ),
                                                  borderRadius: BorderRadius.circular(AppSize.size10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      spreadRadius: AppSize.opacity10,
                                                      color: AppColors.blackTextColor.withOpacity(AppSize.opacity10),
                                                      blurRadius: AppSize.size10,
                                                    ),
                                                  ],
                                                ),
                                                child: ListTile(
                                                  dense: true,
                                                  horizontalTitleGap: AppSize.size7,
                                                  leading: Image.asset(
                                                    AppIcons.cashIcon,
                                                    width: AppSize.size28,
                                                  ),
                                                  title: const Text(
                                                    'Cash',
                                                    style: TextStyle(
                                                      fontSize: AppSize.size14,
                                                      fontWeight: FontWeight.w700,
                                                      fontFamily: FontFamily.latoBold,
                                                      color: AppColors.blackTextColor,
                                                    ),
                                                  ),
                                                  subtitle: const Text(
                                                    'Pay with cash',
                                                    style: TextStyle(
                                                      fontSize: AppSize.size12,
                                                      fontWeight: FontWeight.w400,
                                                      fontFamily: FontFamily.latoRegular,
                                                      color: AppColors.smallTextColor,
                                                    ),
                                                  ),
                                                  trailing: Container(
                                                    width: AppSize.size16,
                                                    height: AppSize.size16,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: AppColors.primaryColor,
                                                      ),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: bookRideController.selectedPaymentMethod.value == 'cash'
                                                        ? Center(
                                                            child: Container(
                                                              width: AppSize.size8,
                                                              height: AppSize.size8,
                                                              decoration: const BoxDecoration(
                                                                color: AppColors.primaryColor,
                                                                shape: BoxShape.circle,
                                                              ),
                                                            ),
                                                          )
                                                        : null,
                                                  ),
                                                ),
                                              ),
                                            )),
                                            // Wallet option
                                            Obx(() => GestureDetector(
                                              onTap: () {
                                                bookRideController.selectedPaymentMethod.value = 'wallet';
                                              },
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                  bottom: AppSize.size16,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.backGroundColor,
                                                  border: Border.all(
                                                    color: bookRideController.selectedPaymentMethod.value == 'wallet'
                                                        ? AppColors.primaryColor
                                                        : AppColors.smallTextColor.withOpacity(AppSize.opacity15),
                                                    width: AppSize.size1and5,
                                                  ),
                                                  borderRadius: BorderRadius.circular(AppSize.size10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      spreadRadius: AppSize.opacity10,
                                                      color: AppColors.blackTextColor.withOpacity(AppSize.opacity10),
                                                      blurRadius: AppSize.size10,
                                                    ),
                                                  ],
                                                ),
                                                child: ListTile(
                                                  dense: true,
                                                  horizontalTitleGap: AppSize.size7,
                                                  leading: Image.asset(
                                                    AppIcons.walletIcon,
                                                    width: AppSize.size28,
                                                  ),
                                                  title: const Text(
                                                    'Wallet',
                                                    style: TextStyle(
                                                      fontSize: AppSize.size14,
                                                      fontWeight: FontWeight.w700,
                                                      fontFamily: FontFamily.latoBold,
                                                      color: AppColors.blackTextColor,
                                                    ),
                                                  ),
                                                  subtitle: const Text(
                                                    'Pay with wallet balance',
                                                    style: TextStyle(
                                                      fontSize: AppSize.size12,
                                                      fontWeight: FontWeight.w400,
                                                      fontFamily: FontFamily.latoRegular,
                                                      color: AppColors.smallTextColor,
                                                    ),
                                                  ),
                                                  trailing: Container(
                                                    width: AppSize.size16,
                                                    height: AppSize.size16,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: AppColors.primaryColor,
                                                      ),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: bookRideController.selectedPaymentMethod.value == 'wallet'
                                                        ? Center(
                                                            child: Container(
                                                              width: AppSize.size8,
                                                              height: AppSize.size8,
                                                              decoration: const BoxDecoration(
                                                                color: AppColors.primaryColor,
                                                                shape: BoxShape.circle,
                                                              ),
                                                            ),
                                                          )
                                                        : null,
                                                  ),
                                                ),
                                              ),
                                            )),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Book Ride button at bottom
                                  Container(
                                    padding: const EdgeInsets.only(
                                      top: AppSize.size16,
                                      left: AppSize.size20,
                                      right: AppSize.size20,
                                      bottom: AppSize.size20,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.backGroundColor,
                                      boxShadow: [
                                        BoxShadow(
                                          spreadRadius:
                                          AppSize.size1,
                                          color: AppColors
                                              .blackTextColor
                                              .withOpacity(AppSize
                                              .opacity10),
                                          blurRadius:
                                          AppSize.size20,
                                        ),
                                      ],
                                    ),
                                    child: Obx(() => GestureDetector(
                                      onTap: bookRideController.isBookingRide.value
                                          ? null
                                          : () {
                                              bookRideController.bookRide();
                                            },
                                      child: Container(
                                        height: AppSize.size54,
                                        decoration: BoxDecoration(
                                          color: bookRideController.isBookingRide.value
                                              ? AppColors.smallTextColor
                                              : AppColors.blackTextColor,
                                          borderRadius: BorderRadius.circular(
                                              AppSize.size10),
                                        ),
                                        child: Center(
                                          child: bookRideController.isBookingRide.value
                                              ? const SizedBox(
                                                  width: AppSize.size24,
                                                  height: AppSize.size24,
                                                  child: CircularProgressIndicator(
                                                    color: AppColors.backGroundColor,
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : const Text(
                                                  AppStrings.bookRide,
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
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
