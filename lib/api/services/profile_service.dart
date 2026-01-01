import '../client/api_client.dart';
import '../constants/api_constants.dart';
import '../../models/user_model.dart';

class ProfileService {
  final ApiClient _apiClient = ApiClient();

  // Get Profile
  Future<UserModel> getProfile() async {
    final response = await _apiClient.get(ApiConstants.customerProfile, requiresAuth: true);

    // depending on your API shape:
    final data = response['data'] ?? response;
    final userJson = data['user'] ?? data;

    return UserModel.fromJson(userJson);
  }

  // Update Profile with multipart PUT (name, phone, and optional image)
  Future<UserModel> updateProfile({
    required String name,
    required String phone,
    String? imagePath,
  }) async {
    try {
      final fields = <String, String>{
        'name': name,
        'phone': phone,
      };

      final files = <String, String>{};
      if (imagePath != null && imagePath.isNotEmpty) {
        files['image'] = imagePath;
      }

      final response = await _apiClient.multipart(
        ApiConstants.customerProfile,
        'PUT',
        fields: fields,
        files: files,
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

  // Delete Account
  Future<void> deleteAccount() async {
    try {
      await _apiClient.delete(
        ApiConstants.customerProfile,
        requiresAuth: true,
      );
    } catch (e) {
      rethrow;
    }
  }
}
