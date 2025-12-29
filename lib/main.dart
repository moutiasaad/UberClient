import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prime_taxi_flutter_ui_kit/config/app_strings.dart';
import 'package:prime_taxi_flutter_ui_kit/controllers/storage_controller.dart';
import 'package:prime_taxi_flutter_ui_kit/localization/app_translation.dart';
import 'package:prime_taxi_flutter_ui_kit/view/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? languageCode = await StorageController.instance.getLanguage();
  String? countryCode = await StorageController.instance.getCountryCode();
  runApp(MyApp(
    languageCode: languageCode,
    countryCode: countryCode,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.languageCode, this.countryCode});

  final String? languageCode;
  final String? countryCode;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      translationsKeys: AppTranslation.translationsKeys,
      debugShowCheckedModeBanner: false,
      title: AppStrings.primeTaxiBooking,
      locale: Locale(languageCode ?? "en", countryCode ?? "US"),
      home: SplashScreen(),
    );
  }
}
