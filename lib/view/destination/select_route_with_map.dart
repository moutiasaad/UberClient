// ignore_for_file: must_be_immutable
// ignore_for_file: deprecated_member_use

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:prime_taxi_flutter_ui_kit/config/app_colors.dart';
import 'package:prime_taxi_flutter_ui_kit/config/app_icons.dart';
import 'package:prime_taxi_flutter_ui_kit/config/app_size.dart';
import 'package:prime_taxi_flutter_ui_kit/config/app_strings.dart';
import 'package:prime_taxi_flutter_ui_kit/config/font_family.dart';
import 'package:prime_taxi_flutter_ui_kit/controllers/book_ride_controller.dart';
import 'package:prime_taxi_flutter_ui_kit/controllers/language_controller.dart';
import 'package:prime_taxi_flutter_ui_kit/controllers/select_route_with_map_controller.dart';
import 'package:prime_taxi_flutter_ui_kit/view/book_ride/book_ride_screen.dart';

import '../widget/discard_route_bottom_sheet.dart';

class SelectRouteWithMapScreen extends StatelessWidget {
  final String? pickupAddress;
  final String? destinationAddress;

  SelectRouteWithMapScreen({
    Key? key,
    this.pickupAddress,
    this.destinationAddress,
  }) : super(key: key);

  SelectRouteWithMapController selectRouteWithMapController =
      Get.put(SelectRouteWithMapController());
  final LanguageController languageController = Get.put(LanguageController());
  BookRideController bookRideController = Get.put(BookRideController());

  void initializeList(BuildContext context) {
    selectRouteWithMapController.routeListTiles.assignAll([
      _buildSelectableListTile(
          AppStrings.yourLocation,
          Colors.green,
          selectRouteWithMapController.locationController,
          0),
      _buildSelectableListTile(
          AppStrings.enterDestination,
          Colors.yellow,
          selectRouteWithMapController.destinationController,
          1),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    // Set addresses from previous screen
    if (pickupAddress != null && pickupAddress!.isNotEmpty) {
      selectRouteWithMapController.locationController.text = pickupAddress!;
    }
    if (destinationAddress != null && destinationAddress!.isNotEmpty) {
      selectRouteWithMapController.destinationController.text = destinationAddress!;
      // Geocode and add markers for both addresses
      selectRouteWithMapController.geocodeAndShowMarkers(pickupAddress, destinationAddress);
    }
    initializeList(context);
    languageController.loadSelectedLanguage();
    return Center(
      child: Container(
        color: AppColors.backGroundColor,
        width: kIsWeb ? AppSize.size800 : null,
        child: Scaffold(
          backgroundColor: AppColors.backGroundColor,
          resizeToAvoidBottomInset: false,
          appBar: _appBar(),
          body: _routeMapContent(context),
          floatingActionButton: _bookRideButton(context),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        ),
      ),
    );
  }

  //Select Route with Map Content
  _appBar() {
    return AppBar(
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
                selectRouteWithMapController.showPolyline.value = false;
                selectRouteWithMapController.isTimerElapsed.value = false;
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
                AppStrings.selectRoute,
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

  _routeMapContent(BuildContext context) {
    return Stack(
      children: [
        Container(
            width: double.infinity,
            height: double.infinity,
            color: AppColors.backGroundColor,
            child: Obx(
              () => GoogleMap(
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                zoomGesturesEnabled: true,
                scrollGesturesEnabled: true,
                rotateGesturesEnabled: true,
                tiltGesturesEnabled: true,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(25.2854, 51.5310), // Qatar (Doha)
                  zoom: 12,
                ),
                mapType: MapType.normal,
                markers: Set.from(selectRouteWithMapController.markers),
                polylines: selectRouteWithMapController.showPolyline.value
                    ? Set<Polyline>.from(selectRouteWithMapController.polylines.value)
                    : <Polyline>{},
                onMapCreated: (controller) {
                  selectRouteWithMapController.myMapController = controller;
                  selectRouteWithMapController.gMapsFunctionCall(
                      selectRouteWithMapController.initialLocation);
                },
                onTap: (LatLng tappedLocation) {
                  selectRouteWithMapController.onMapTapped(tappedLocation);
                },
              ),
            )),
        // Zoom controls
        Positioned(
          right: AppSize.size20,
          bottom: AppSize.size140,
          child: Column(
            children: [
              // Zoom In Button
              GestureDetector(
                onTap: () {
                  selectRouteWithMapController.zoomIn();
                },
                child: Container(
                  width: AppSize.size40,
                  height: AppSize.size40,
                  decoration: BoxDecoration(
                    color: AppColors.backGroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppSize.size8),
                      topRight: Radius.circular(AppSize.size8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blackTextColor.withOpacity(0.2),
                        blurRadius: AppSize.size8,
                        spreadRadius: AppSize.size1,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add,
                      size: AppSize.size24,
                      color: AppColors.blackTextColor,
                    ),
                  ),
                ),
              ),
              // Divider
              Container(
                width: AppSize.size40,
                height: 1,
                color: AppColors.smallTextColor.withOpacity(0.3),
              ),
              // Zoom Out Button
              GestureDetector(
                onTap: () {
                  selectRouteWithMapController.zoomOut();
                },
                child: Container(
                  width: AppSize.size40,
                  height: AppSize.size40,
                  decoration: BoxDecoration(
                    color: AppColors.backGroundColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(AppSize.size8),
                      bottomRight: Radius.circular(AppSize.size8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blackTextColor.withOpacity(0.2),
                        blurRadius: AppSize.size8,
                        spreadRadius: AppSize.size1,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.remove,
                      size: AppSize.size24,
                      color: AppColors.blackTextColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Search fields with suggestions
        Positioned(
          top: AppSize.size12,
          left: AppSize.size20,
          right: AppSize.size20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Input fields container
              Obx(
                () => Stack(
                  alignment: languageController.arb.value
                      ? Alignment.topRight
                      : Alignment.topLeft,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.backGroundColor,
                        border: Border.all(
                          color: AppColors.smallTextColor
                              .withOpacity(AppSize.opacity15),
                          width: AppSize.size1,
                        ),
                        borderRadius: BorderRadius.circular(AppSize.size10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildSearchField(
                            hintText: AppStrings.yourLocation,
                            color: Colors.green,
                            controller: selectRouteWithMapController.locationController,
                            fieldIndex: 0,
                            isPickup: true,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: AppSize.size30,
                            ),
                            child: DottedLine(
                              direction: Axis.horizontal,
                              alignment: WrapAlignment.center,
                              lineLength:
                                  kIsWeb ? AppSize.size680 : AppSize.size255,
                              lineThickness: AppSize.size1,
                              dashLength: AppSize.size4,
                              dashColor: AppColors.smallTextColor
                                  .withOpacity(AppSize.opacity20),
                              dashRadius: AppSize.size0,
                              dashGapLength: AppSize.size4,
                              dashGapColor: Colors.transparent,
                              dashGapRadius: AppSize.size0,
                            ),
                          ),
                          _buildSearchField(
                            hintText: AppStrings.enterDestination,
                            color: Colors.yellow,
                            controller: selectRouteWithMapController.destinationController,
                            fieldIndex: 1,
                            isPickup: false,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: languageController.arb.value ? 0 : AppSize.size23,
                        right: languageController.arb.value
                            ? AppSize.size23
                            : AppSize.size0,
                        top: AppSize.size45,
                      ),
                      child: Container(
                        width: AppSize.size1,
                        height: AppSize.size46,
                        color: AppColors.smallTextColor,
                      ),
                    ),
                    Positioned(
                      bottom: AppSize.size10,
                      right: languageController.arb.value ? null : AppSize.size16,
                      left: languageController.arb.value ? AppSize.size16 : null,
                      child: GestureDetector(
                        onTap: () {
                          selectRouteWithMapController.swapItems();
                        },
                        child: Container(
                          width: AppSize.size22,
                          height: AppSize.size22,
                          decoration: BoxDecoration(
                            color: AppColors.backGroundColor,
                            border: Border.all(
                              color: AppColors.smallTextColor
                                  .withOpacity(AppSize.opacity10),
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Image.asset(
                              AppIcons.swapIcon,
                              width: AppSize.size14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Suggestions dropdown
              Obx(() {
                // Show pickup suggestions
                if (selectRouteWithMapController.showPickupSuggestions.value &&
                    selectRouteWithMapController.pickupSuggestions.isNotEmpty) {
                  return _buildSuggestionsDropdown(
                    suggestions: selectRouteWithMapController.pickupSuggestions,
                    isPickup: true,
                  );
                }
                // Show destination suggestions
                if (selectRouteWithMapController.showDestinationSuggestions.value &&
                    selectRouteWithMapController.destinationSuggestions.isNotEmpty) {
                  return _buildSuggestionsDropdown(
                    suggestions: selectRouteWithMapController.destinationSuggestions,
                    isPickup: false,
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField({
    required String hintText,
    required Color color,
    required TextEditingController controller,
    required int fieldIndex,
    required bool isPickup,
  }) {
    return Obx(() => GestureDetector(
      onTap: () {
        selectRouteWithMapController.setActiveField(fieldIndex);
      },
      child: Container(
        color: selectRouteWithMapController.activeFieldIndex.value == fieldIndex
            ? AppColors.primaryColor.withOpacity(0.1)
            : Colors.transparent,
        child: ListTile(
          dense: true,
          minLeadingWidth: AppSize.size16,
          leading: Padding(
            padding: const EdgeInsets.only(top: AppSize.size7),
            child: Container(
              width: AppSize.size14,
              height: AppSize.size14,
              decoration: BoxDecoration(
                border: Border.all(
                  color: color,
                  width: selectRouteWithMapController.activeFieldIndex.value == fieldIndex
                      ? AppSize.size2
                      : AppSize.size1,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: AppSize.size8,
                  height: AppSize.size8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          title: TextField(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              hintText: hintText,
              hintStyle: const TextStyle(
                fontSize: AppSize.size14,
                fontWeight: FontWeight.w400,
                fontFamily: FontFamily.latoRegular,
                color: AppColors.smallTextColor,
              ),
              border: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              suffixIcon: controller.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        controller.clear();
                        if (isPickup) {
                          selectRouteWithMapController.clearPickupSuggestions();
                        } else {
                          selectRouteWithMapController.clearDestinationSuggestions();
                        }
                      },
                      child: const Icon(
                        Icons.clear,
                        size: AppSize.size18,
                        color: AppColors.smallTextColor,
                      ),
                    )
                  : null,
            ),
            style: const TextStyle(
              fontSize: AppSize.size14,
              fontWeight: FontWeight.w400,
              fontFamily: FontFamily.latoRegular,
              color: AppColors.blackTextColor,
              overflow: TextOverflow.ellipsis,
            ),
            cursorColor: AppColors.smallTextColor,
            controller: controller,
            onTap: () {
              selectRouteWithMapController.setActiveField(fieldIndex);
            },
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Loading indicator
              Obx(() {
                final isLoading = isPickup
                    ? selectRouteWithMapController.isSearchingPickup.value
                    : selectRouteWithMapController.isSearchingDestination.value;
                if (isLoading) {
                  return const SizedBox(
                    width: AppSize.size18,
                    height: AppSize.size18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryColor,
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              // My location button (only for pickup)
              if (isPickup && selectRouteWithMapController.activeFieldIndex.value == fieldIndex)
                GestureDetector(
                  onTap: () {
                    selectRouteWithMapController.useCurrentLocationForPickup();
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(left: AppSize.size8),
                    child: Icon(
                      Icons.my_location,
                      size: 18,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildSuggestionsDropdown({
    required List<PlacePrediction> suggestions,
    required bool isPickup,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: AppSize.size4),
      constraints: const BoxConstraints(maxHeight: 250),
      decoration: BoxDecoration(
        color: AppColors.backGroundColor,
        borderRadius: BorderRadius.circular(AppSize.size10),
        border: Border.all(
          color: AppColors.smallTextColor.withOpacity(AppSize.opacity15),
          width: AppSize.size1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackTextColor.withOpacity(0.1),
            blurRadius: AppSize.size10,
            spreadRadius: AppSize.size1,
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: suggestions.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: AppColors.smallTextColor.withOpacity(AppSize.opacity10),
        ),
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return InkWell(
            onTap: () {
              selectRouteWithMapController.selectPlace(
                suggestion,
                isPickup: isPickup,
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSize.size16,
                vertical: AppSize.size12,
              ),
              child: Row(
                children: [
                  Container(
                    width: AppSize.size36,
                    height: AppSize.size36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSize.size8),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.location_on_outlined,
                        size: AppSize.size20,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSize.size12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          suggestion.mainText,
                          style: const TextStyle(
                            fontSize: AppSize.size14,
                            fontWeight: FontWeight.w500,
                            fontFamily: FontFamily.latoMedium,
                            color: AppColors.blackTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (suggestion.secondaryText.isNotEmpty) ...[
                          const SizedBox(height: AppSize.size2),
                          Text(
                            suggestion.secondaryText,
                            style: const TextStyle(
                              fontSize: AppSize.size12,
                              fontWeight: FontWeight.w400,
                              fontFamily: FontFamily.latoRegular,
                              color: AppColors.smallTextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  _bookRideButton(BuildContext context) {
    return Container(
      height: AppSize.size120,
      color: AppColors.backGroundColor,
      padding: const EdgeInsets.only(
        top: AppSize.size16,
      ),
      child: Column(
        children: [
          const Text(
            AppStrings.youCanSpendUp,
            style: TextStyle(
              fontSize: AppSize.size14,
              fontWeight: FontWeight.w600,
              fontFamily: FontFamily.latoSemiBold,
              color: AppColors.blackTextColor,
            ),
          ),
          GestureDetector(
            onTap: () async {
              // Get pickup coordinates and address
              final pickupLat = selectRouteWithMapController.initialLocation.value.latitude;
              final pickupLng = selectRouteWithMapController.initialLocation.value.longitude;
              final pickupAddr = selectRouteWithMapController.locationController.text;

              // Get destination coordinates and address
              final dropoffLat = selectRouteWithMapController.selectedDestination?.latitude ?? 0;
              final dropoffLng = selectRouteWithMapController.selectedDestination?.longitude ?? 0;
              final dropoffAddr = selectRouteWithMapController.destinationController.text;

              // Validate that both locations are set
              if (pickupLat == 0 || pickupLng == 0 || dropoffLat == 0 || dropoffLng == 0) {
                Get.snackbar(
                  'Error',
                  'Please select both pickup and destination locations',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              // Set locations in BookRideController and calculate fare
              bookRideController.setLocations(
                pickLat: pickupLat,
                pickLng: pickupLng,
                pickAddress: pickupAddr,
                dropLat: dropoffLat,
                dropLng: dropoffLng,
                dropAddress: dropoffAddr,
              );

              selectRouteWithMapController.addPolylineToDestination();
              Get.to(() => BookRideScreen());
            },
            child: Container(
              height: AppSize.size54,
              margin: const EdgeInsets.only(
                top: AppSize.size12,
                left: AppSize.size20,
                right: AppSize.size20,
              ),
              decoration: BoxDecoration(
                color: AppColors.blackTextColor,
                borderRadius: BorderRadius.circular(AppSize.size10),
              ),
              child: const Center(
                child: Text(
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
          ),
        ],
      ),
    );
  }

  _buildSelectableListTile(
      String hintText, Color color, TextEditingController controller, int fieldIndex) {
    return Obx(() => GestureDetector(
      onTap: () {
        selectRouteWithMapController.setActiveField(fieldIndex);
      },
      child: Container(
        color: selectRouteWithMapController.activeFieldIndex.value == fieldIndex
            ? AppColors.primaryColor.withOpacity(0.1)
            : Colors.transparent,
        child: ListTile(
          dense: true,
          minLeadingWidth: AppSize.size16,
          leading: Padding(
            padding: const EdgeInsets.only(top: AppSize.size7),
            child: Container(
              width: AppSize.size14,
              height: AppSize.size14,
              decoration: BoxDecoration(
                border: Border.all(
                  color: color,
                  width: selectRouteWithMapController.activeFieldIndex.value == fieldIndex
                      ? AppSize.size2
                      : AppSize.size1,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: AppSize.size8,
                  height: AppSize.size8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          title: TextField(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              hintText: hintText,
              hintStyle: const TextStyle(
                fontSize: AppSize.size14,
                fontWeight: FontWeight.w400,
                fontFamily: FontFamily.latoRegular,
                color: AppColors.smallTextColor,
              ),
              border: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(
              fontSize: AppSize.size14,
              fontWeight: FontWeight.w400,
              fontFamily: FontFamily.latoRegular,
              color: AppColors.blackTextColor,
              overflow: TextOverflow.ellipsis,
            ),
            cursorColor: AppColors.smallTextColor,
            controller: controller,
            onTap: () {
              selectRouteWithMapController.setActiveField(fieldIndex);
            },
          ),
          trailing: selectRouteWithMapController.activeFieldIndex.value == fieldIndex
              ? const Icon(Icons.my_location, size: 18, color: AppColors.primaryColor)
              : null,
        ),
      ),
    ));
  }
}
