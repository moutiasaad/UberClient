import '../client/api_client.dart';
import '../constants/api_constants.dart';
import '../../models/auth_response_model.dart';
import '../../models/user_model.dart';
import '../../controllers/storage_controller.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  // ========== NEW: Email-based Authentication (Recommended) ==========

  /// Step 1: Send OTP via Email
  /// This endpoint handles both new user registration and existing user login
  /// Only email is required, other fields are optional
  Future<Map<String, dynamic>> sendEmailOtp({
    required String email,
    String? fullname,
    String? phone,
    int? countryId,
    String? referralCode,
  }) async {
    try {
      final body = <String, dynamic>{
        'email': email,
      };

      // Add optional fields only if provided
      if (fullname != null && fullname.isNotEmpty) body['fullname'] = fullname;
      if (phone != null && phone.isNotEmpty) body['phone'] = phone;
      if (countryId != null) body['country_id'] = countryId;
      if (referralCode != null && referralCode.isNotEmpty) body['referral_code'] = referralCode;

      final response = await _apiClient.post(
        ApiConstants.customerEmailAuth,
        body: body,
        requiresAuth: false,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Step 2: Verify OTP (Email-based)
  /// Verifies the OTP sent to the email and returns authentication token
  Future<AuthResponseModel> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.customerVerifyOtp,
        body: {
          'email': email,
          'otp': otp,
        },
        requiresAuth: false,
      );

      final authResponse = AuthResponseModel.fromJson(response['data'] ?? response);

      // Store token and user data
      if (authResponse.token != null) {
        await _saveAuthData(authResponse.token!, authResponse.user);
      }

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  // ========== OLD: Phone-based Authentication (Backward Compatibility) ==========

  // Customer Register
  Future<AuthResponseModel> registerCustomer({
    required String name,
    required String phone,
    required String email,
    required String password,
    required int countryId,
    String? referralCode,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.customerRegister,
        body: {
          'name': name,
          'phone': phone,
          'email': email,
          'password': password,
          'country_id': countryId,
          if (referralCode != null && referralCode.isNotEmpty)
            'referral_code': referralCode,
        },
        requiresAuth: false,
      );

      final authResponse = AuthResponseModel.fromJson(response['data'] ?? response);

      // Store token if provided
      if (authResponse.token != null) {
        await _saveAuthData(authResponse.token!, authResponse.user);
      }

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  // Verify OTP
  Future<AuthResponseModel> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.customerVerifyOtp,
        body: {
          'phone': phone,
          'otp': otp,
        },
        requiresAuth: false,
      );

      final authResponse = AuthResponseModel.fromJson(response['data'] ?? response);

      // Store token and user data
      if (authResponse.token != null) {
        await _saveAuthData(authResponse.token!, authResponse.user);
      }

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  // Customer Login
  Future<AuthResponseModel> loginCustomer({
    required String phoneOrEmail,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.customerLogin,
        body: {
          'phone_or_email': phoneOrEmail,
          'password': password,
        },
        requiresAuth: false,
      );

      final authResponse = AuthResponseModel.fromJson(response['data'] ?? response);

      // Store token and user data
      if (authResponse.token != null) {
        await _saveAuthData(authResponse.token!, authResponse.user);
      }

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  // Forgot Password
  Future<Map<String, dynamic>> forgotPassword({
    required String phone,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.customerForgotPassword,
        body: {'phone': phone},
        requiresAuth: false,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Reset Password
  Future<Map<String, dynamic>> resetPassword({
    required String phone,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.customerResetPassword,
        body: {
          'phone': phone,
          'otp': otp,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
        requiresAuth: false,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _apiClient.post(
        ApiConstants.customerLogout,
        requiresAuth: true,
      );
    } catch (e) {
      // Even if API call fails, clear local data
    } finally {
      await _clearAuthData();
    }
  }

  // Save auth data to storage
  Future<void> _saveAuthData(String token, UserModel? user) async {
    await StorageController.instance.setString(ApiConstants.tokenKey, token);
    await StorageController.instance.setBool(ApiConstants.isLoggedInKey, true);

    if (user != null) {
      await StorageController.instance.setString(
        ApiConstants.userKey,
        user.toJson().toString(),
      );
    }
  }

  // Clear auth data from storage
  Future<void> _clearAuthData() async {
    await StorageController.instance.remove(ApiConstants.tokenKey);
    await StorageController.instance.remove(ApiConstants.userKey);
    await StorageController.instance.setBool(ApiConstants.isLoggedInKey, false);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await StorageController.instance.getString(ApiConstants.tokenKey);
    return token != null && token.isNotEmpty;
  }

  // Get stored token
  Future<String?> getToken() async {
    return await StorageController.instance.getString(ApiConstants.tokenKey);
  }
}
