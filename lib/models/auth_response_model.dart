import 'user_model.dart';

class AuthResponseModel {
  final bool success;
  final String message;
  final String? token;
  final UserModel? user;

  AuthResponseModel({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      success: json['success'] ?? true,
      message: json['message'] ?? '',
      token: json['token'] ?? json['data']?['token'],
      user: json['user'] != null
          ? UserModel.fromJson(json['user'])
          : json['data']?['user'] != null
              ? UserModel.fromJson(json['data']['user'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'token': token,
      'user': user?.toJson(),
    };
  }
}
