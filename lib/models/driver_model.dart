class DriverModel {
  final int id;
  final String name;
  final String? email;
  final String phone;
  final String? image;
  final double rating;
  final int totalTrips;
  final int yearsExperience;
  final String? vehicleType;
  final String? vehicleModel;
  final String? vehicleColor;
  final String? plateNumber;
  final String? licenseNumber;
  final DateTime? licenseExpiry;
  final String? nationalId;
  final String status;
  final double? currentLatitude;
  final double? currentLongitude;
  final DateTime? memberSince;

  DriverModel({
    required this.id,
    required this.name,
    this.email,
    required this.phone,
    this.image,
    this.rating = 0.0,
    this.totalTrips = 0,
    this.yearsExperience = 0,
    this.vehicleType,
    this.vehicleModel,
    this.vehicleColor,
    this.plateNumber,
    this.licenseNumber,
    this.licenseExpiry,
    this.nationalId,
    this.status = 'offline',
    this.currentLatitude,
    this.currentLongitude,
    this.memberSince,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'] ?? '',
      image: json['image'] ?? json['profile_image'],
      rating: (json['rating'] ?? 0).toDouble(),
      totalTrips: json['total_trips'] ?? json['trips_count'] ?? 0,
      yearsExperience: json['years_experience'] ?? json['experience_years'] ?? 0,
      vehicleType: json['vehicle_type'],
      vehicleModel: json['vehicle_model'],
      vehicleColor: json['vehicle_color'],
      plateNumber: json['plate_number'],
      licenseNumber: json['license_number'],
      licenseExpiry: json['license_expiry'] != null
          ? DateTime.parse(json['license_expiry'])
          : null,
      nationalId: json['national_id'],
      status: json['status'] ?? 'offline',
      currentLatitude: json['current_latitude'] != null
          ? (json['current_latitude']).toDouble()
          : null,
      currentLongitude: json['current_longitude'] != null
          ? (json['current_longitude']).toDouble()
          : null,
      memberSince: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'image': image,
      'rating': rating,
      'total_trips': totalTrips,
      'years_experience': yearsExperience,
      'vehicle_type': vehicleType,
      'vehicle_model': vehicleModel,
      'vehicle_color': vehicleColor,
      'plate_number': plateNumber,
      'license_number': licenseNumber,
      'license_expiry': licenseExpiry?.toIso8601String(),
      'national_id': nationalId,
      'status': status,
      'current_latitude': currentLatitude,
      'current_longitude': currentLongitude,
      'created_at': memberSince?.toIso8601String(),
    };
  }
}
