import '../client/api_client.dart';
import '../constants/api_constants.dart';
import '../../models/user_model.dart';

class ProfileService {
  final ApiClient _apiClient = ApiClient();

  // Get Profile
  Future<UserModel> getProfile() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.customerProfile,
        requiresAuth: true,
      );

      return UserModel.fromJson(response['data'] ?? response['user'] ?? response);
    } catch (e) {
      rethrow;
    }
  }

  // Update Profile
  Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? language,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (language != null) body['language'] = language;

      final response = await _apiClient.put(
        ApiConstants.customerProfile,
        body: body,
        requiresAuth: true,
      );

      return UserModel.fromJson(response['data'] ?? response['user'] ?? response);
    } catch (e) {
      rethrow;
    }
  }

  // Upload Profile Image
  Future<String> uploadProfileImage(String imagePath) async {
    try {
      final response = await _apiClient.multipart(
        ApiConstants.customerProfileImage,
        'POST',
        files: {'image': imagePath},
        requiresAuth: true,
      );

      return response['data']?['image_url'] ?? response['image_url'] ?? '';
    } catch (e) {
      rethrow;
    }
  }

  // Update FCM Token
  Future<void> updateFcmToken(String fcmToken) async {
    try {
      await _apiClient.put(
        ApiConstants.customerFcmToken,
        body: {'fcm_token': fcmToken},
        requiresAuth: true,
      );
    } catch (e) {
      rethrow;
    }
  }
}
