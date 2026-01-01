import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../client/api_client.dart';
import '../constants/api_constants.dart';
import '../../models/ride_model.dart';
import '../../models/fare_model.dart';
import '../../controllers/storage_controller.dart';

class RideService {
  final ApiClient _apiClient = ApiClient();

  // Calculate Fare
  Future<FareModel> calculateFare({
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
    String? couponCode,
    int? usePoints,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.calculateFare,
        body: {
          'pickup_lat': pickupLat,
          'pickup_lng': pickupLng,
          'dropoff_lat': dropoffLat,
          'dropoff_lng': dropoffLng,
          if (couponCode != null && couponCode.isNotEmpty)
            'coupon_code': couponCode,
          if (usePoints != null && usePoints > 0) 'use_points': usePoints,
        },
        requiresAuth: true,
      );

      return FareModel.fromJson(response['data'] ?? response);
    } catch (e) {
      rethrow;
    }
  }

  // Request Ride
  Future<RideModel> requestRide({
    required double pickupLat,
    required double pickupLng,
    required String pickupAddress,
    required double dropoffLat,
    required double dropoffLng,
    required String dropoffAddress,
    required String paymentMethod,
    String? couponCode,
    int usePoints = 0,
    DateTime? scheduledTime,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.requestRide,
        body: {
          'pickup_lat': pickupLat,
          'pickup_lng': pickupLng,
          'pickup_address': pickupAddress,
          'dropoff_lat': dropoffLat,
          'dropoff_lng': dropoffLng,
          'dropoff_address': dropoffAddress,
          'payment_method': paymentMethod,
          'coupon_code': couponCode,
          'use_points': usePoints,
          'pickup_time': scheduledTime?.toIso8601String(),
        },
        requiresAuth: true,
      );

      return RideModel.fromJson(response['data'] ?? response['ride'] ?? response);
    } catch (e) {
      rethrow;
    }
  }

  // Get Active Ride
  Future<RideModel?> getActiveRide() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.activeRide,
        requiresAuth: true,
      );

      if (response['data'] == null) return null;

      return RideModel.fromJson(response['data'] ?? response['ride'] ?? response);
    } catch (e) {
      // If no active ride, return null instead of throwing error
      if (e is ApiException && e.message.contains('No active ride')) {
        return null;
      }
      rethrow;
    }
  }

  // Get Ride Details
  Future<RideModel> getRideDetails(int rideId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.rideDetails}/$rideId',
        requiresAuth: true,
      );

      return RideModel.fromJson(response['data'] ?? response['ride'] ?? response);
    } catch (e) {
      rethrow;
    }
  }

  // Get Ride History
  Future<List<RideModel>> getRideHistory({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.rideHistory}?page=$page&per_page=$perPage',
        requiresAuth: true,
      );

      final List<dynamic> ridesJson = response['data'] ?? response['rides'] ?? [];
      return ridesJson.map((json) => RideModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Cancel Ride
  Future<void> cancelRide({
    required int rideId,
    required String reason,
  }) async {
    try {
      // Get auth token from storage
      final token = await StorageController.instance.getString(ApiConstants.tokenKey);

      debugPrint('🔴 Cancelling ride: $rideId with reason: $reason');
      debugPrint('🔴 Full URL: ${ApiConstants.baseUrl}${ApiConstants.cancelRide}/$rideId/cancel');
      debugPrint('🔑 Token: ${token?.substring(0, 20)}...');

      // Use direct http.post as shown in the example
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.cancelRide}/$rideId/cancel'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'reason': reason}),
      );

      debugPrint('🔴 Response status: ${response.statusCode}');
      debugPrint('🔴 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('🟢 Ride cancelled successfully');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to cancel ride');
      }
    } catch (e) {
      debugPrint('❌ Cancel ride error: $e');
      rethrow;
    }
  }

  // Rate Ride
  Future<void> rateRide({
    required int rideId,
    required int rating,
    String? comment,
  }) async {
    try {
      await _apiClient.post(
        '${ApiConstants.rateRide}/$rideId/rate',
        body: {
          'rating': rating,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
        requiresAuth: true,
      );
    } catch (e) {
      rethrow;
    }
  }
}
