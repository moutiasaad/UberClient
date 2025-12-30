// ignore_for_file: must_be_immutable
// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:prime_taxi_flutter_ui_kit/config/app_strings.dart';
import 'package:prime_taxi_flutter_ui_kit/controllers/language_controller.dart';
import 'package:prime_taxi_flutter_ui_kit/controllers/my_rides_controller.dart';
import 'package:prime_taxi_flutter_ui_kit/models/ride_model.dart';
import 'package:prime_taxi_flutter_ui_kit/view/my_rides/my_rides_cancelled_details_screen.dart';
import 'package:prime_taxi_flutter_ui_kit/view/my_rides/my_rides_active_details_screen.dart';
import 'package:prime_taxi_flutter_ui_kit/view/my_rides/my_rides_completed_details_screen.dart';

import '../../config/app_colors.dart';
import '../../config/app_icons.dart';
import '../../config/app_size.dart';
import '../../config/font_family.dart';

class MyRidesScreen extends StatefulWidget {
  const MyRidesScreen({Key? key}) : super(key: key);

  @override
  State<MyRidesScreen> createState() => _MyRidesScreenState();
}

class _MyRidesScreenState extends State<MyRidesScreen> {
  final MyRidesController myRidesController = Get.put(MyRidesController());
  final LanguageController languageController = Get.put(LanguageController());

  @override
  void initState() {
    super.initState();
    _loadRideHistory();
  }

  Future<void> _loadRideHistory() async {
    await myRidesController.fetchRideHistory();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final rideDate = DateTime(date.year, date.month, date.day);

    if (rideDate == today) {
      return 'Today, ${DateFormat('h:mm a').format(date)}';
    } else if (rideDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${DateFormat('h:mm a').format(date)}';
    } else {
      return DateFormat('EEEE, MMM d').format(date);
    }
  }

  String _getVehicleIcon(String? vehicleType) {
    switch (vehicleType?.toLowerCase()) {
      case 'bike':
        return AppIcons.bike2Icon;
      case 'auto':
      case 'rickshaw':
        return AppIcons.rikshaw2Icon;
      case 'car':
      default:
        return AppIcons.carModelIcon;
    }
  }

  Color _getStatusColor(RideModel ride) {
    if (ride.isActive) {
      return AppColors.primaryColor;
    } else if (ride.isCancelled) {
      return AppColors.redColor;
    } else if (ride.isCompleted) {
      return AppColors.parrotColor;
    }
    return AppColors.smallTextColor;
  }

  String _getStatusText(RideModel ride) {
    if (ride.statusText != null) {
      return ride.statusText!;
    }
    if (ride.isActive) {
      return 'Active';
    } else if (ride.isCancelled) {
      return 'Cancelled';
    } else if (ride.isCompleted) {
      return 'Completed';
    }
    return ride.status.toUpperCase();
  }

  void _navigateToDetails(RideModel ride) {
    if (ride.isActive) {
      Get.to(() => MyRidesActiveDetailsScreen(rideId: ride.id));
    } else if (ride.isCancelled) {
      Get.to(() => MyRidesCancelledDetailsScreen());
    } else if (ride.isCompleted) {
      Get.to(() => MyRidesCompletedDetailsScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: AppColors.backGroundColor,
        width: kIsWeb ? AppSize.size800 : null,
        child: Scaffold(
          backgroundColor: AppColors.backGroundColor,
          resizeToAvoidBottomInset: false,
          appBar: _appBar(),
          body: _myRidesContent(),
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: AppColors.backGroundColor,
      elevation: AppSize.size0,
      automaticallyImplyLeading: false,
      title: Obx(() => Padding(
            padding:
                const EdgeInsets.only(left: AppSize.size5, top: AppSize.size10),
            child: !myRidesController.searchBoolean.value
                ? Row(
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
                        padding: EdgeInsets.only(
                            left: AppSize.size12, right: AppSize.size12),
                        child: Text(
                          AppStrings.myRides,
                          style: TextStyle(
                            fontSize: AppSize.size20,
                            fontFamily: FontFamily.latoBold,
                            fontWeight: FontWeight.w700,
                            color: AppColors.blackTextColor,
                          ),
                        ),
                      ),
                    ],
                  )
                : _searchTextField(),
          )),
      actions: [
        Obx(() => Padding(
              padding: const EdgeInsets.only(
                  top: AppSize.size10,
                  right: AppSize.size20,
                  left: AppSize.size20),
              child: !myRidesController.searchBoolean.value
                  ? GestureDetector(
                      onTap: () {
                        myRidesController.searchBoolean.value = true;
                      },
                      child: Image.asset(
                        AppIcons.search,
                        width: AppSize.size18,
                        color: AppColors.blackTextColor,
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        myRidesController.searchBoolean.value = false;
                      },
                      child: Image.asset(
                        AppIcons.closeIcon2,
                        width: AppSize.size18,
                        color: AppColors.blackTextColor,
                      ),
                    ),
            )),
      ],
    );
  }

  Widget _myRidesContent() {
    return Obx(() {
      if (myRidesController.isLoadingRides.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        );
      }

      if (myRidesController.rideHistory.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: _loadRideHistory,
        color: AppColors.primaryColor,
        child: ListView.builder(
          padding: const EdgeInsets.only(
            top: AppSize.size24,
            right: AppSize.size20,
            left: AppSize.size20,
            bottom: AppSize.size20,
          ),
          itemCount: myRidesController.rideHistory.length,
          itemBuilder: (context, index) {
            final ride = myRidesController.rideHistory[index];
            return _buildRideCard(ride);
          },
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AppIcons.carModelIcon,
            width: AppSize.size80,
            color: AppColors.smallTextColor.withOpacity(0.5),
          ),
          const SizedBox(height: AppSize.size20),
          const Text(
            'No Rides Yet',
            style: TextStyle(
              fontSize: AppSize.size18,
              fontFamily: FontFamily.latoBold,
              fontWeight: FontWeight.w700,
              color: AppColors.blackTextColor,
            ),
          ),
          const SizedBox(height: AppSize.size8),
          const Text(
            'Your ride history will appear here',
            style: TextStyle(
              fontSize: AppSize.size14,
              fontFamily: FontFamily.latoRegular,
              fontWeight: FontWeight.w400,
              color: AppColors.smallTextColor,
            ),
          ),
          const SizedBox(height: AppSize.size24),
          GestureDetector(
            onTap: _loadRideHistory,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSize.size24,
                vertical: AppSize.size12,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(AppSize.size10),
              ),
              child: const Text(
                'Refresh',
                style: TextStyle(
                  fontSize: AppSize.size14,
                  fontFamily: FontFamily.latoMedium,
                  fontWeight: FontWeight.w500,
                  color: AppColors.backGroundColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideCard(RideModel ride) {
    final statusColor = _getStatusColor(ride);
    final statusText = _getStatusText(ride);
    final vehicleIcon = _getVehicleIcon(ride.driver?.vehicleType);
    final dateText = _formatDate(ride.createdAt);

    return GestureDetector(
      onTap: () => _navigateToDetails(ride),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSize.size24),
        padding: const EdgeInsets.only(
          left: AppSize.size16,
          top: AppSize.size16,
          right: AppSize.size16,
          bottom: AppSize.size16,
        ),
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
                Expanded(
                  child: Row(
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
                            vehicleIcon,
                            width: AppSize.size24,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSize.size6),
                              child: Text(
                                dateText,
                                style: const TextStyle(
                                  fontSize: AppSize.size16,
                                  fontFamily: FontFamily.latoBold,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.blackTextColor,
                                ),
                              ),
                            ),
                            Text(
                              'Ride #${ride.id} • \$${ride.finalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: AppSize.size12,
                                fontFamily: FontFamily.latoRegular,
                                fontWeight: FontWeight.w400,
                                color: AppColors.smallTextColor,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: AppSize.size16),
                              child: Row(
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
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Obx(
                              () => Container(
                                margin: EdgeInsets.only(
                                    right: languageController.arb.value
                                        ? AppSize.size4
                                        : 0,
                                    left: languageController.arb.value
                                        ? AppSize.size0
                                        : AppSize.size4),
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
                                      left: languageController.arb.value
                                          ? AppSize.size6
                                          : 0,
                                      right: languageController.arb.value
                                          ? AppSize.size0
                                          : AppSize.size6,
                                    ),
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
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
                          AppIcons.man3Icon,
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

  Widget _searchTextField() {
    return const TextField(
      autofocus: true,
      cursorColor: AppColors.smallTextColor,
      style: TextStyle(
        fontWeight: FontWeight.w500,
        fontFamily: FontFamily.latoRegular,
        fontSize: AppSize.size16,
        color: AppColors.blackTextColor,
      ),
      decoration: InputDecoration(
        hintText: AppStrings.searchHere,
        hintStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontFamily: FontFamily.latoRegular,
          fontSize: AppSize.size16,
          color: AppColors.smallTextColor,
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide.none,
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide.none,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
