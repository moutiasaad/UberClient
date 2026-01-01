import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tshl_tawsil/config/app_icons.dart';
import 'package:tshl_tawsil/controllers/home_controller.dart';
import 'package:tshl_tawsil/view/home/home_screen.dart';
import '../config/app_strings.dart';
import '../api/services/ride_service.dart';
import '../api/client/api_client.dart';
import '../models/fare_model.dart';
import '../models/ride_model.dart';

HomeController homeController = Get.put(HomeController());

class BookRideController extends GetxController {
  TextEditingController locationController =
      TextEditingController(text: homeController.userAddress.value);
  TextEditingController destinationController =
      TextEditingController(text: AppStrings.templeDestination);
  TextEditingController addStopController =
      TextEditingController(text: AppStrings.stopDestination);
  TextEditingController promoCodeController = TextEditingController();

  RxInt selectedInnerContainerIndex = 0.obs;
  RxInt selectedFullScreenRideContainerIndex = 0.obs;

  // API service
  final RideService _rideService = RideService();

  // Loading states
  RxBool isLoadingFare = false.obs;
  RxBool isBookingRide = false.obs;

  // Fare data
  Rx<FareModel?> fareData = Rx<FareModel?>(null);

  // Ride data
  Rx<RideModel?> currentRide = Rx<RideModel?>(null);

  // Pickup and dropoff coordinates
  double? pickupLat;
  double? pickupLng;
  String pickupAddress = '';

  double? dropoffLat;
  double? dropoffLng;
  String dropoffAddress = '';

  // Selected payment method
  RxString selectedPaymentMethod = 'cash'.obs;

  // Selected time for ride - default to current time + 10 minutes
  Rx<DateTime?> selectedTime = Rx<DateTime?>(DateTime.now().add(const Duration(minutes: 10)));

  void selectInnerContainer(int index) {
    selectedInnerContainerIndex.value = index;
  }

  void selectFullScreenContainer(int index) {
    selectedFullScreenRideContainerIndex.value = index;
  }

  // Set selected time
  void setSelectedTime(DateTime time) {
    selectedTime.value = time;
  }

  // Format selected time for display
  String get formattedSelectedTime {
    if (selectedTime.value == null) return 'Select Time';
    final time = selectedTime.value!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final selectedDate = DateTime(time.year, time.month, time.day);

    String dayLabel;
    if (selectedDate == today) {
      dayLabel = 'Today';
    } else if (selectedDate == tomorrow) {
      dayLabel = 'Tomorrow';
    } else {
      // Format as "Dec 31"
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      dayLabel = '${months[time.month - 1]} ${time.day}';
    }

    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$dayLabel, $hour:$minute $period';
  }

  List<String> ridesImage = [
    AppIcons.carIcon,
    AppIcons.bikeIcon,
    AppIcons.autoIcon,
    AppIcons.carIcon,
  ];

  List<String> rides = [
    AppStrings.car,
    AppStrings.bike,
    AppStrings.auto,
    AppStrings.hourlyRental,
  ];

  List<String> ridesSubtitle = [
    AppStrings.getCarAtYourDoorStep,
    AppStrings.beatTheTrafficOnABike,
    AppStrings.comfyEconomicalAuto,
    AppStrings.getRidesAtHourlyPackages,
  ];

  List<String> ridesPrice = [
    AppStrings.dollar76,
    AppStrings.dollar39,
    AppStrings.dollar59,
  ];

  List<String> paymentMethodImage = [
    AppIcons.paypalIcon,
    AppIcons.visaIcon,
    AppIcons.netbankingIcon,
    AppIcons.upiIcon,
    AppIcons.googlePayIcon,
  ];

  List<String> paymentMethod = [
    AppStrings.payPal,
    AppStrings.debitCreditCard,
    AppStrings.netbanking,
    AppStrings.upiPayment,
    AppStrings.googlePay,
  ];

  // Calculate fare
  Future<void> calculateFare() async {
    if (pickupLat == null || dropoffLat == null) {
      Fluttertoast.showToast(msg: 'Please select pickup and dropoff locations');
      return;
    }

    try {
      isLoadingFare.value = true;

      final fare = await _rideService.calculateFare(
        pickupLat: pickupLat!,
        pickupLng: pickupLng!,
        dropoffLat: dropoffLat!,
        dropoffLng: dropoffLng!,
        couponCode: promoCodeController.text.trim().isNotEmpty
            ? promoCodeController.text.trim()
            : null,
      );

      fareData.value = fare;

      // Update price displays
      if (ridesPrice.isNotEmpty) {
        ridesPrice[0] = '\$${fare.totalFare.toStringAsFixed(2)}';
      }

    } catch (e) {
      String errorMessage = 'Failed to calculate fare';
      if (e is ApiException) {
        errorMessage = e.message;
      }
      Fluttertoast.showToast(msg: errorMessage);
    } finally {
      isLoadingFare.value = false;
    }
  }

  // Book ride
  Future<void> bookRide() async {
    if (pickupLat == null || dropoffLat == null) {
      Fluttertoast.showToast(msg: 'Please select pickup and dropoff locations');
      return;
    }

    try {
      isBookingRide.value = true;

      final ride = await _rideService.requestRide(
        pickupLat: pickupLat!,
        pickupLng: pickupLng!,
        pickupAddress: pickupAddress,
        dropoffLat: dropoffLat!,
        dropoffLng: dropoffLng!,
        dropoffAddress: dropoffAddress,
        paymentMethod: selectedPaymentMethod.value,
        couponCode: promoCodeController.text.trim().isNotEmpty
            ? promoCodeController.text.trim()
            : null,
        scheduledTime: selectedTime.value,
      );

      currentRide.value = ride;

      Fluttertoast.showToast(msg: 'Ride requested successfully!');

      // Reload home controller to fetch the new ride
      try {
        final homeController = Get.find<HomeController>();
        await homeController.loadActiveRide();
      } catch (e) {
        // HomeController might not be initialized yet
        debugPrint('HomeController not found: $e');
      }

      // Navigate to searching driver screen
      Get.offAll(() => HomeScreen());

    } catch (e) {
      String errorMessage = 'Failed to book ride';
      if (e is ApiException) {
        errorMessage = e.message;
      }
      Fluttertoast.showToast(msg: errorMessage);
    } finally {
      isBookingRide.value = false;
    }
  }

  // Set locations from route selection
  void setLocations({
    required double pickLat,
    required double pickLng,
    required String pickAddress,
    required double dropLat,
    required double dropLng,
    required String dropAddress,
  }) {
    pickupLat = pickLat;
    pickupLng = pickLng;
    pickupAddress = pickAddress;

    dropoffLat = dropLat;
    dropoffLng = dropLng;
    dropoffAddress = dropAddress;

    locationController.text = pickAddress;
    destinationController.text = dropAddress;

    // Automatically calculate fare
    calculateFare();
  }

  @override
  void onClose() {
    locationController.dispose();
    destinationController.dispose();
    addStopController.dispose();
    promoCodeController.dispose();
    super.onClose();
  }
}
