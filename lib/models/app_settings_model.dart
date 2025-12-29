class AppSettingsModel {
  final double baseFare;
  final double perKmRate;
  final double perMinuteRate;
  final double cancellationFee;
  final int pointsPerRide;
  final double pointsToMoneyRatio;
  final String currency;
  final String currencySymbol;
  final int otpExpiryMinutes;
  final int searchRadiusKm;
  final String? privacyPolicyUrl;
  final String? termsUrl;
  final String? supportPhone;
  final String? supportEmail;

  AppSettingsModel({
    required this.baseFare,
    required this.perKmRate,
    required this.perMinuteRate,
    this.cancellationFee = 0,
    this.pointsPerRide = 10,
    this.pointsToMoneyRatio = 0.1,
    this.currency = 'USD',
    this.currencySymbol = '\$',
    this.otpExpiryMinutes = 5,
    this.searchRadiusKm = 5,
    this.privacyPolicyUrl,
    this.termsUrl,
    this.supportPhone,
    this.supportEmail,
  });

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      baseFare: (json['base_fare'] ?? 5.0).toDouble(),
      perKmRate: (json['per_km_rate'] ?? 1.5).toDouble(),
      perMinuteRate: (json['per_minute_rate'] ?? 0.5).toDouble(),
      cancellationFee: (json['cancellation_fee'] ?? 0).toDouble(),
      pointsPerRide: json['points_per_ride'] ?? 10,
      pointsToMoneyRatio: (json['points_to_money_ratio'] ?? 0.1).toDouble(),
      currency: json['currency'] ?? 'USD',
      currencySymbol: json['currency_symbol'] ?? '\$',
      otpExpiryMinutes: json['otp_expiry_minutes'] ?? 5,
      searchRadiusKm: json['search_radius_km'] ?? 5,
      privacyPolicyUrl: json['privacy_policy_url'],
      termsUrl: json['terms_url'],
      supportPhone: json['support_phone'],
      supportEmail: json['support_email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base_fare': baseFare,
      'per_km_rate': perKmRate,
      'per_minute_rate': perMinuteRate,
      'cancellation_fee': cancellationFee,
      'points_per_ride': pointsPerRide,
      'points_to_money_ratio': pointsToMoneyRatio,
      'currency': currency,
      'currency_symbol': currencySymbol,
      'otp_expiry_minutes': otpExpiryMinutes,
      'search_radius_km': searchRadiusKm,
      'privacy_policy_url': privacyPolicyUrl,
      'terms_url': termsUrl,
      'support_phone': supportPhone,
      'support_email': supportEmail,
    };
  }
}
