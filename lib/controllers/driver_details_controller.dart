import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tshl_tawsil/config/app_icons.dart';
import 'package:tshl_tawsil/config/app_strings.dart';
import 'package:tshl_tawsil/controllers/home_controller.dart';

HomeController homeController = Get.put(HomeController());

class DriverDetailsController extends GetxController {
  TextEditingController locationController =
      TextEditingController(text: homeController.userAddress.value);
  TextEditingController destinationController =
      TextEditingController(text: AppStrings.templeDestination);
  TextEditingController addStopController =
      TextEditingController(text: AppStrings.stopDestination);

  List<String> detailsImage = [
    AppIcons.ratingIcon,
    AppIcons.tripIcon,
    AppIcons.yearIcon,
  ];

  List<String> detailsString = [
    AppStrings.like1and6,
    AppStrings.number578,
    AppStrings.number8,
  ];

  List<String> detailsTitle = [
    AppStrings.rating,
    AppStrings.trips,
    AppStrings.years,
  ];
}
