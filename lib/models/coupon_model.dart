class CouponModel {
  final int id;
  final String code;
  final String type;
  final double value;
  final double? minRideAmount;
  final double? maxDiscountAmount;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final int? usageLimit;
  final int? usedCount;
  final bool isActive;

  CouponModel({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    this.minRideAmount,
    this.maxDiscountAmount,
    this.validFrom,
    this.validUntil,
    this.usageLimit,
    this.usedCount,
    this.isActive = true,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      type: json['type'] ?? 'percentage',
      value: (json['value'] ?? 0).toDouble(),
      minRideAmount: json['min_ride_amount'] != null
          ? (json['min_ride_amount']).toDouble()
          : null,
      maxDiscountAmount: json['max_discount_amount'] != null
          ? (json['max_discount_amount']).toDouble()
          : null,
      validFrom: json['valid_from'] != null
          ? DateTime.parse(json['valid_from'])
          : null,
      validUntil: json['valid_until'] != null
          ? DateTime.parse(json['valid_until'])
          : null,
      usageLimit: json['usage_limit'],
      usedCount: json['used_count'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'type': type,
      'value': value,
      'min_ride_amount': minRideAmount,
      'max_discount_amount': maxDiscountAmount,
      'valid_from': validFrom?.toIso8601String(),
      'valid_until': validUntil?.toIso8601String(),
      'usage_limit': usageLimit,
      'used_count': usedCount,
      'is_active': isActive,
    };
  }

  bool get isPercentage => type == 'percentage';
  bool get isFixed => type == 'fixed';

  bool get isValid {
    if (!isActive) return false;

    final now = DateTime.now();
    if (validFrom != null && now.isBefore(validFrom!)) return false;
    if (validUntil != null && now.isAfter(validUntil!)) return false;

    if (usageLimit != null && usedCount != null) {
      if (usedCount! >= usageLimit!) return false;
    }

    return true;
  }

  double calculateDiscount(double rideAmount) {
    if (!isValid) return 0;
    if (minRideAmount != null && rideAmount < minRideAmount!) return 0;

    double discount = 0;
    if (isPercentage) {
      discount = rideAmount * (value / 100);
    } else {
      discount = value;
    }

    if (maxDiscountAmount != null && discount > maxDiscountAmount!) {
      discount = maxDiscountAmount!;
    }

    return discount;
  }
}
