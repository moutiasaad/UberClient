import 'dart:async';
import 'package:get/get.dart';
import 'package:prime_taxi_flutter_ui_kit/config/app_size.dart';
import 'package:prime_taxi_flutter_ui_kit/api/services/auth_service.dart';
import 'package:prime_taxi_flutter_ui_kit/api/services/profile_service.dart';
import 'package:prime_taxi_flutter_ui_kit/controllers/home_controller.dart';
import 'package:prime_taxi_flutter_ui_kit/view/welcome/welcome_screen.dart';
import 'package:prime_taxi_flutter_ui_kit/view/home/home_screen.dart';
import 'package:prime_taxi_flutter_ui_kit/view/create_profile/create_profile_screen.dart';

class SplashController extends GetxController {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();

  @override
  void onInit() {
    super.onInit();

    /// ✅ REGISTER HomeController ONCE HERE
    /// This fixes: "HomeController not found"
    Get.put<HomeController>(HomeController(), permanent: true);

    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.delayed(const Duration(seconds: AppSize.four));

    final hasToken = await _authService.isLoggedIn();

    // 🚫 Not logged in → Welcome
    if (!hasToken) {
      Get.offAll(() => const WelcomeScreen());
      return;
    }

    // ✅ Logged in → validate token & fetch profile
    try {
      final user = await _profileService.getProfile();

      final hasName = (user.name ?? '').trim().isNotEmpty;

      if (hasName) {
        // ✅ HomeController already exists here
        Get.offAll(() => HomeScreen());
      } else {
        Get.offAll(
              () => CreateProfileScreen(),
          arguments: {'email': user.email ?? ''},
        );
      }
    } catch (e) {
      // ❌ Token invalid / expired
      Get.offAll(() => const WelcomeScreen());
    }
  }
}
