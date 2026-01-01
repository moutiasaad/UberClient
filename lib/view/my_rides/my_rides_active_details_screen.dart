// ignore_for_file: must_be_immutable
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tshl_tawsil/api/services/ride_service.dart';
import 'package:tshl_tawsil/controllers/language_controller.dart';
import 'package:tshl_tawsil/controllers/my_rides_controller.dart';
import 'package:tshl_tawsil/models/ride_model.dart';
import 'package:tshl_tawsil/view/book_ride/cancel_car_screen.dart';
import 'package:tshl_tawsil/view/book_ride/driver_details_screen.dart';

import '../../config/app_colors.dart';
import '../../config/app_icons.dart';
import '../../config/app_size.dart';
import '../../config/app_strings.dart';
import '../../config/font_family.dart';
import '../safety/safety_screen.dart';

class MyRidesActiveDetailsScreen extends StatefulWidget {
  final int rideId;

  const MyRidesActiveDetailsScreen({Key? key, required this.rideId}) : super(key: key);

  @override
  State<MyRidesActiveDetailsScreen> createState() => _MyRidesActiveDetailsScreenState();
}

class _MyRidesActiveDetailsScreenState extends State<MyRidesActiveDetailsScreen> {
  final MyRidesController myRidesController = Get.put(MyRidesController());
  final LanguageController languageController = Get.put(LanguageController());
  final RideService _rideService = RideService();

  RideModel? rideDetails;
  bool isLoading = true;
  String? errorMessage;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _loadRideDetails();
    _startAutoUpdate();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startAutoUpdate() {
    // Update driver location every 20 seconds
    _updateTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
      if (mounted && rideDetails != null && !rideDetails!.isCompleted && !rideDetails!.isCancelled) {
        _loadRideDetails(silent: true);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _loadRideDetails({bool silent = false}) async {
    try {
      if (!silent) {
        setState(() {
          isLoading = true;
          errorMessage = null;
        });
      }

      final ride = await _rideService.getRideDetails(widget.rideId);

      if (mounted) {
        setState(() {
          rideDetails = ride;
          if (!silent) {
            isLoading = false;
          }
        });

        // Update map markers with driver location
        if (ride.pickupLat != 0 && ride.pickupLng != 0) {
          await myRidesController.updateMarkersForRide(
            pickupLat: ride.pickupLat,
            pickupLng: ride.pickupLng,
            dropoffLat: ride.dropoffLat,
            dropoffLng: ride.dropoffLng,
            driverLat: ride.driver?.currentLatitude,
            driverLng: ride.driver?.currentLongitude,
          );

          // Draw polyline from pickup to dropoff using FREE OSRM API
          debugPrint('📍 Drawing polyline from pickup (${ride.pickupLat}, ${ride.pickupLng}) to dropoff (${ride.dropoffLat}, ${ride.dropoffLng})');
          await myRidesController.drawPolylineFromPickupToDropoff(
            pickupLat: ride.pickupLat,
            pickupLng: ride.pickupLng,
            dropoffLat: ride.dropoffLat,
            dropoffLng: ride.dropoffLng,
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading ride details: $e');
      if (mounted) {
        setState(() {
          if (!silent) {
            isLoading = false;
          }
          errorMessage = e.toString();
        });
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('EEEE, MMM d').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: AppColors.backGroundColor,
        width: kIsWeb ? AppSize.size800 : null,
        child: Scaffold(
          backgroundColor: AppColors.backGroundColor,
          appBar: _appBar(),
          body: isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
              : errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error loading ride details',
                            style: const TextStyle(
                              fontSize: AppSize.size16,
                              fontFamily: FontFamily.latoMedium,
                              color: AppColors.blackTextColor,
                            ),
                          ),
                          const SizedBox(height: AppSize.size16),
                          GestureDetector(
                            onTap: _loadRideDetails,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSize.size20,
                                vertical: AppSize.size10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(AppSize.size10),
                              ),
                              child: const Text(
                                'Retry',
                                style: TextStyle(
                                  color: AppColors.backGroundColor,
                                  fontFamily: FontFamily.latoMedium,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _myRidesActiveDetailsContent(),
          floatingActionButton: rideDetails != null &&
              rideDetails!.isCancellable &&
              rideDetails!.isPending
              ? _bottomButton()
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar() {
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
            Padding(
              padding:
                  const EdgeInsets.only(left: AppSize.size12, right: AppSize.size12),
              child: Text(
                rideDetails != null ? 'Ride #${rideDetails!.id}' : AppStrings.car,
                style: const TextStyle(
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

  Widget _myRidesActiveDetailsContent() {
    if (rideDetails == null) return const SizedBox.shrink();

    final ride = rideDetails!;

    // Get status color
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

    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        top: AppSize.size24,
      ),
      child: Column(
        children: [
          Container(
            height: AppSize.size238,
            margin: const EdgeInsets.only(bottom: AppSize.size24),
            child: Obx(
              () => GoogleMap(
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                initialCameraPosition: CameraPosition(
                  target: LatLng(ride.pickupLat, ride.pickupLng),
                  zoom: AppSize.size15,
                ),
                mapType: MapType.normal,
                markers: Set.from(myRidesController.markers),
                polylines: Set.from(myRidesController.polylines),
                onMapCreated: (controller) {
                  myRidesController.myMapController = controller;
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: AppSize.size20, right: AppSize.size20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Padding(
                            padding: EdgeInsets.only(
                                right: languageController.arb.value
                                    ? 0
                                    : AppSize.size8,
                                left: languageController.arb.value
                                    ? AppSize.size8
                                    : AppSize.size0),
                            child: Image.asset(
                              AppIcons.carModelIcon,
                              width: AppSize.size24,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: AppSize.size6),
                              child: Text(
                                _formatDate(ride.createdAt),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontFamily: FontFamily.latoBold,
                                  fontSize: AppSize.size16,
                                  color: AppColors.blackTextColor,
                                ),
                              ),
                            ),
                            Text(
                              'Ride #${ride.id}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontFamily: FontFamily.latoRegular,
                                fontSize: AppSize.size12,
                                color: AppColors.smallTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      ride.statusText ?? ride.status.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontFamily: FontFamily.latoMedium,
                        fontSize: AppSize.size12,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: AppSize.size24, bottom: AppSize.size24),
                  child: Divider(
                    color:
                        AppColors.smallTextColor.withOpacity(AppSize.opacity20),
                    height: AppSize.size0,
                  ),
                ),
                Row(
                  children: [
                    Obx(
                      () => Container(
                        width: AppSize.size10,
                        height: AppSize.size10,
                        margin: EdgeInsets.only(
                            right: languageController.arb.value
                                ? 0
                                : AppSize.size6,
                            left: languageController.arb.value
                                ? AppSize.size6
                                : AppSize.size0),
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
                    ),
                    Expanded(
                      child: Text(
                        ride.pickupAddress,
                        style: const TextStyle(
                          fontSize: AppSize.size12,
                          fontFamily: FontFamily.latoRegular,
                          fontWeight: FontWeight.w400,
                          color: AppColors.blackTextColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Obx(
                  () => Container(
                    margin: EdgeInsets.only(
                        left: languageController.arb.value ? 0 : AppSize.size4,
                        right: languageController.arb.value
                            ? AppSize.size4
                            : AppSize.size0),
                    height: AppSize.size12,
                    width: AppSize.size1,
                    color: AppColors.smallTextColor,
                  ),
                ),
                Row(
                  children: [
                    Obx(
                      () => Container(
                        width: AppSize.size10,
                        height: AppSize.size10,
                        margin: EdgeInsets.only(
                            right: languageController.arb.value
                                ? 0
                                : AppSize.size6,
                            left: languageController.arb.value
                                ? AppSize.size6
                                : AppSize.size0),
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
                    ),
                    Expanded(
                      child: Text(
                        ride.dropoffAddress,
                        style: const TextStyle(
                          fontSize: AppSize.size12,
                          fontFamily: FontFamily.latoRegular,
                          fontWeight: FontWeight.w400,
                          color: AppColors.blackTextColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: AppSize.size24, bottom: AppSize.size16),
                  child: Divider(
                    color:
                        AppColors.smallTextColor.withOpacity(AppSize.opacity20),
                    height: AppSize.size0,
                  ),
                ),
                Container(
                  height: AppSize.size115,
                  padding: const EdgeInsets.only(
                    left: AppSize.size28,
                    right: AppSize.size28,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.backGroundColor,
                    borderRadius: BorderRadius.circular(AppSize.size10),
                    border: Border.all(
                      color: AppColors.smallTextColor
                          .withOpacity(AppSize.opacity15),
                      width: AppSize.size1and5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        spreadRadius: AppSize.size1,
                        color: AppColors.blackTextColor
                            .withOpacity(AppSize.opacity10),
                        blurRadius: AppSize.size17,
                      ),
                    ],
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _customDetails(
                          AppIcons.dollarIcon,
                          '\$${ride.finalAmount.toStringAsFixed(2)}',
                          AppStrings.rideFare,
                        ),
                        VerticalDivider(
                          color: AppColors.smallTextColor
                              .withOpacity(AppSize.opacity20),
                          indent: AppSize.size28,
                          endIndent: AppSize.size28,
                        ),
                        _customDetails(
                          AppIcons.tripIcon,
                          '${ride.distanceKm?.toStringAsFixed(1) ?? '0'} km',
                          AppStrings.trip,
                        ),
                        VerticalDivider(
                          color: AppColors.smallTextColor
                              .withOpacity(AppSize.opacity20),
                          indent: AppSize.size28,
                          endIndent: AppSize.size28,
                        ),
                        _customDetails(
                          AppIcons.yearIcon,
                          '${ride.estimatedDurationMinutes ?? 0} min',
                          AppStrings.tripTime,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: AppSize.size16),
                  padding: const EdgeInsets.all(AppSize.size16),
                  decoration: BoxDecoration(
                    color: AppColors.backGroundColor,
                    borderRadius: BorderRadius.circular(AppSize.size10),
                    border: Border.all(
                      color: AppColors.smallTextColor
                          .withOpacity(AppSize.opacity15),
                      width: AppSize.size1and5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        spreadRadius: AppSize.size1,
                        color: AppColors.blackTextColor
                            .withOpacity(AppSize.opacity10),
                        blurRadius: AppSize.size17,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Obx(
                            () => Padding(
                              padding: EdgeInsets.only(
                                  right: languageController.arb.value
                                      ? 0
                                      : AppSize.size10,
                                  left: languageController.arb.value
                                      ? AppSize.size10
                                      : AppSize.size0),
                              child: Image.asset(
                                AppIcons.scooterIcon,
                                width: AppSize.size28,
                              ),
                            ),
                          ),
                          Text(
                            ride.isPending
                                ? 'Searching for driver...'
                                : ride.isAccepted
                                    ? 'Driver is on the way'
                                    : ride.isArrived
                                        ? 'Driver has arrived'
                                        : ride.isStarted
                                            ? 'Trip in progress'
                                            : 'Ride Confirmed',
                            style: const TextStyle(
                              fontSize: AppSize.size14,
                              fontFamily: FontFamily.latoMedium,
                              fontWeight: FontWeight.w500,
                              color: AppColors.blackTextColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSize.size12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                AppIcons.cashIcon,
                                width: AppSize.size20,
                              ),
                              const SizedBox(width: AppSize.size8),
                              Text(
                                ride.paymentMethod.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: AppSize.size12,
                                  fontFamily: FontFamily.latoMedium,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.smallTextColor,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            ride.paymentStatus?.toUpperCase() ?? 'PENDING',
                            style: TextStyle(
                              fontSize: AppSize.size12,
                              fontFamily: FontFamily.latoMedium,
                              fontWeight: FontWeight.w500,
                              color: ride.paymentStatus == 'paid'
                                  ? AppColors.greenColor
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Driver info (only show if driver is assigned)
                if (ride.driver != null) ...[
                  Container(
                    margin: const EdgeInsets.only(top: AppSize.size16),
                    height: AppSize.size115,
                    padding: const EdgeInsets.only(
                      top: AppSize.size10,
                      left: AppSize.size16,
                      right: AppSize.size16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.backGroundColor,
                      borderRadius: BorderRadius.circular(AppSize.size10),
                      border: Border.all(
                        color: AppColors.smallTextColor
                            .withOpacity(AppSize.opacity15),
                        width: AppSize.size1and5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          spreadRadius: AppSize.size1,
                          color: AppColors.blackTextColor
                              .withOpacity(AppSize.opacity10),
                          blurRadius: AppSize.size17,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          visualDensity: const VisualDensity(
                            vertical: AppSize.minus1,
                          ),
                          dense: true,
                          horizontalTitleGap: AppSize.size3,
                          leading: Image.asset(
                            AppIcons.man3Icon,
                            width: AppSize.size34,
                          ),
                          title: Text(
                            ride.driver!.name,
                            style: const TextStyle(
                              fontSize: AppSize.size16,
                              fontWeight: FontWeight.w700,
                              fontFamily: FontFamily.latoBold,
                              color: AppColors.blackTextColor,
                            ),
                          ),
                          subtitle: Text(
                            ride.driver!.vehicleModel ?? '',
                            style: const TextStyle(
                              fontSize: AppSize.size12,
                              fontWeight: FontWeight.w400,
                              fontFamily: FontFamily.latoRegular,
                              color: AppColors.smallTextColor,
                            ),
                          ),
                          trailing: SizedBox(
                            width: AppSize.size65,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: AppSize.size3,
                                          left: AppSize.size3),
                                      child: Image.asset(
                                        AppIcons.starIcon,
                                        width: AppSize.size14,
                                      ),
                                    ),
                                    Text(
                                      ride.driver!.rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: AppSize.size12,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: FontFamily.latoRegular,
                                        color: AppColors.smallTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: AppSize.size6,
                                  ),
                                  child: Text(
                                    ride.driver!.plateNumber ?? '',
                                    style: const TextStyle(
                                      fontSize: AppSize.size12,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: FontFamily.latoBold,
                                      color: AppColors.blackTextColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                GestureDetector(
                  onTap: () {
                    Get.to(() => SafetyScreen());
                  },
                  child: Container(
                    margin: const EdgeInsets.only(
                        top: AppSize.size16, bottom: AppSize.size120),
                    height: AppSize.size54,
                    padding: const EdgeInsets.only(
                      left: AppSize.size16,
                      right: AppSize.size16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.backGroundColor,
                      borderRadius: BorderRadius.circular(AppSize.size10),
                      border: Border.all(
                        color: AppColors.smallTextColor
                            .withOpacity(AppSize.opacity15),
                        width: AppSize.size1and5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          spreadRadius: AppSize.size1,
                          color: AppColors.blackTextColor
                              .withOpacity(AppSize.opacity10),
                          blurRadius: AppSize.size17,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Obx(
                              () => Padding(
                                padding: EdgeInsets.only(
                                    right: languageController.arb.value
                                        ? 0
                                        : AppSize.size10,
                                    left: languageController.arb.value
                                        ? AppSize.size10
                                        : 0),
                                child: Image.asset(
                                  AppIcons.helpIcon,
                                  width: AppSize.size18,
                                ),
                              ),
                            ),
                            const Text(
                              AppStrings.getHelp,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontFamily: FontFamily.latoSemiBold,
                                fontSize: AppSize.size14,
                                color: AppColors.blackTextColor,
                              ),
                            ),
                          ],
                        ),
                        Image.asset(
                          AppIcons.rightArrowIcon,
                          width: AppSize.size18,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomButton() {
    return Container(
      height: AppSize.size100,
      color: AppColors.backGroundColor,
      child: Center(
        child: GestureDetector(
          onTap: () {
            Get.to(() => CancelCarScreen(rideId: widget.rideId));
          },
          child: Container(
            height: AppSize.size54,
            margin: const EdgeInsets.only(
              left: AppSize.size20,
              right: AppSize.size20,
            ),
            decoration: BoxDecoration(
              color: AppColors.blackTextColor,
              borderRadius: BorderRadius.circular(AppSize.size10),
            ),
            child: const Center(
              child: Text(
                AppStrings.cancelRide,
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
    );
  }

  Widget _customDetails(String image, String text1, String text2) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          image,
          width: AppSize.size38,
        ),
        Padding(
          padding: const EdgeInsets.only(top: AppSize.size8),
          child: Text(
            text1,
            style: const TextStyle(
              fontSize: AppSize.size16,
              fontWeight: FontWeight.w700,
              fontFamily: FontFamily.latoBold,
              color: AppColors.blackTextColor,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: AppSize.size4),
          child: Text(
            text2,
            style: const TextStyle(
              fontSize: AppSize.size12,
              fontWeight: FontWeight.w400,
              fontFamily: FontFamily.latoRegular,
              color: AppColors.smallTextColor,
            ),
          ),
        ),
      ],
    );
  }
}
