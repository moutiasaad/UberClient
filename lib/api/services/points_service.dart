import '../client/api_client.dart';
import '../constants/api_constants.dart';
import '../../models/points_model.dart';

class PointsService {
  final ApiClient _apiClient = ApiClient();

  // Get Points Balance and History
  Future<PointsModel> getPoints() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.customerPoints,
        requiresAuth: true,
      );

      return PointsModel.fromJson(response['data'] ?? response);
    } catch (e) {
      rethrow;
    }
  }
}
