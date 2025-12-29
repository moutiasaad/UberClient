import '../client/api_client.dart';
import '../constants/api_constants.dart';

class CouponService {
  final ApiClient _apiClient = ApiClient();

  // Validate Coupon
  Future<Map<String, dynamic>> validateCoupon({
    required String code,
    required double rideAmount,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.validateCoupon,
        body: {
          'code': code,
          'ride_amount': rideAmount,
        },
        requiresAuth: true,
      );

      return response['data'] ?? response;
    } catch (e) {
      rethrow;
    }
  }
}
