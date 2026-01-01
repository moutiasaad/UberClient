import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tshl_tawsil/config/app_strings.dart';
import 'package:tshl_tawsil/controllers/storage_controller.dart';
import 'package:tshl_tawsil/localization/app_translation.dart';
import 'package:tshl_tawsil/view/splash/splash_screen.dart';
import 'firebase_options.dart';

// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Handling background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Request notification permissions (iOS)
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  await GetStorage.init();
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
