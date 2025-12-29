class FareModel {
  final double baseFare;
  final double distanceFare;
  final double distance;
  final int duration;
  final double subtotal;
  final double? discountAmount;
  final double? pointsDiscount;
  final double totalFare;
  final String? couponCode;
  final int? pointsUsed;

  FareModel({
    required this.baseFare,
    required this.distanceFare,
    required this.distance,
    required this.duration,
    required this.subtotal,
    this.discountAmount,
    this.pointsDiscount,
    required this.totalFare,
    this.couponCode,
    this.pointsUsed,
  });

  factory FareModel.fromJson(Map<String, dynamic> json) {
    return FareModel(
      baseFare: (json['base_fare'] ?? 0).toDouble(),
      distanceFare: (json['distance_fare'] ?? 0).toDouble(),
      distance: (json['distance'] ?? 0).toDouble(),
      duration: json['duration'] ?? 0,
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      discountAmount: json['discount_amount'] != null
          ? (json['discount_amount']).toDouble()
          : null,
      pointsDiscount: json['points_discount'] != null
          ? (json['points_discount']).toDouble()
          : null,
      totalFare: (json['total_fare'] ?? 0).toDouble(),
      couponCode: json['coupon_code'],
      pointsUsed: json['points_used'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base_fare': baseFare,
      'distance_fare': distanceFare,
      'distance': distance,
      'duration': duration,
      'subtotal': subtotal,
      'discount_amount': discountAmount,
      'points_discount': pointsDiscount,
      'total_fare': totalFare,
      'coupon_code': couponCode,
      'points_used': pointsUsed,
    };
  }
}
