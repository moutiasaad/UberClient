import '../client/api_client.dart';
import '../../models/points_model.dart';

class PointsService {
  final ApiClient _apiClient = ApiClient();

  // Get points balance and history
  Future<PointsModel> getPoints() async {
    try {
      final response = await _apiClient.get(
        '/customer/points',
        requiresAuth: true,
      );

      return PointsModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
