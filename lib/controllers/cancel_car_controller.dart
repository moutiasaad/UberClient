import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tshl_tawsil/config/app_strings.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../api/services/ride_service.dart';
import '../api/client/api_client.dart';
import 'home_controller.dart';

class CancelCarController extends GetxController {
  TextEditingController reasonController = TextEditingController();
  RxList<int> checkedIndexes = <int>[].obs;
  RxBool isCancelling = false.obs;

  final RideService _rideService = RideService();
  int? currentRideId;

  void toggleCheckbox(int index) {
    if (checkedIndexes.contains(index)) {
      checkedIndexes.remove(index);
    } else {
      checkedIndexes.add(index);
    }
  }

  // Get cancellation reason
  String getCancellationReason() {
    List<String> reasons = [];

    // Add checked reasons
    for (int index in checkedIndexes) {
      if (index < cancelCarIssue.length) {
        reasons.add(cancelCarIssue[index]);
      }
    }

    // Add custom reason if provided
    if (reasonController.text.trim().isNotEmpty) {
      reasons.add(reasonController.text.trim());
    }

    // Return combined reason or default
    return reasons.isNotEmpty ? reasons.join(', ') : 'Customer cancelled';
  }

  // Cancel ride API call
  Future<bool> cancelRide() async {
    if (currentRideId == null) {
      Fluttertoast.showToast(msg: 'No ride to cancel');
      return false;
    }

    try {
      isCancelling.value = true;

      final reason = getCancellationReason();

      await _rideService.cancelRide(
        rideId: currentRideId!,
        reason: reason,
      );

      // Clear the home controller's active ride
      try {
        final homeController = Get.find<HomeController>();
        homeController.activeRide.value = null;
      } catch (e) {
        debugPrint('HomeController not found: $e');
      }

      Fluttertoast.showToast(msg: 'Ride cancelled successfully');
      return true;
    } catch (e) {
      String errorMessage = 'Failed to cancel ride';
      if (e is ApiException) {
        errorMessage = e.message;
      }
      Fluttertoast.showToast(msg: errorMessage);
      return false;
    } finally {
      isCancelling.value = false;
    }
  }

  @override
  void onClose() {
    reasonController.dispose();
    super.onClose();
  }

  List<String> cancelCarIssue = [
    AppStrings.waitingForLongTime,
    AppStrings.thePriceIsNotReasonable,
    AppStrings.unableToContactDriver,
    AppStrings.wrongAddressShown,
    AppStrings.driverDeniedToComeToPickup,
    AppStrings.driverDeniedToGo,
    AppStrings.thePriceIsNotReasonable,
  ];
}
