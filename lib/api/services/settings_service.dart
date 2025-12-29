import '../client/api_client.dart';
import '../constants/api_constants.dart';
import '../../models/app_settings_model.dart';

class SettingsService {
  final ApiClient _apiClient = ApiClient();

  // Get App Settings
  Future<AppSettingsModel> getSettings() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.settings,
        requiresAuth: false,
      );

      return AppSettingsModel.fromJson(response['data'] ?? response);
    } catch (e) {
      rethrow;
    }
  }
}
