class UserModel {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String? image;
  final int? countryId;
  final String? language;
  final int points;
  final String? referralCode;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.image,
    this.countryId,
    this.language,
    this.points = 0,
    this.referralCode,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      image: json['image'],
      countryId: json['country_id'],
      language: json['language'] ?? 'en',
      points: json['points'] ?? 0,
      referralCode: json['referral_code'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'image': image,
      'country_id': countryId,
      'language': language,
      'points': points,
      'referral_code': referralCode,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? image,
    int? countryId,
    String? language,
    int? points,
    String? referralCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      image: image ?? this.image,
      countryId: countryId ?? this.countryId,
      language: language ?? this.language,
      points: points ?? this.points,
      referralCode: referralCode ?? this.referralCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
