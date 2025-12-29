import 'driver_model.dart';

class RideModel {
  final int id;
  final int customerId;
  final int? driverId;
  final double pickupLat;
  final double pickupLng;
  final String pickupAddress;
  final double dropoffLat;
  final double dropoffLng;
  final String dropoffAddress;
  final String status;
  final String paymentMethod;
  final double baseFare;
  final double distanceFare;
  final double? discountAmount;
  final double? pointsDiscount;
  final double totalFare;
  final double? distance;
  final int? duration;
  final String? couponCode;
  final int? pointsUsed;
  final int? pointsEarned;
  final double? customerRating;
  final String? customerComment;
  final String? cancellationReason;
  final String? cancelledBy;
  final DateTime? scheduledAt;
  final DateTime? acceptedAt;
  final DateTime? arrivedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DriverModel? driver;

  RideModel({
    required this.id,
    required this.customerId,
    this.driverId,
    required this.pickupLat,
    required this.pickupLng,
    required this.pickupAddress,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.dropoffAddress,
    required this.status,
    required this.paymentMethod,
    required this.baseFare,
    required this.distanceFare,
    this.discountAmount,
    this.pointsDiscount,
    required this.totalFare,
    this.distance,
    this.duration,
    this.couponCode,
    this.pointsUsed,
    this.pointsEarned,
    this.customerRating,
    this.customerComment,
    this.cancellationReason,
    this.cancelledBy,
    this.scheduledAt,
    this.acceptedAt,
    this.arrivedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    required this.createdAt,
    required this.updatedAt,
    this.driver,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      id: json['id'] ?? 0,
      customerId: json['customer_id'] ?? 0,
      driverId: json['driver_id'],
      pickupLat: (json['pickup_lat'] ?? 0).toDouble(),
      pickupLng: (json['pickup_lng'] ?? 0).toDouble(),
      pickupAddress: json['pickup_address'] ?? '',
      dropoffLat: (json['dropoff_lat'] ?? 0).toDouble(),
      dropoffLng: (json['dropoff_lng'] ?? 0).toDouble(),
      dropoffAddress: json['dropoff_address'] ?? '',
      status: json['status'] ?? 'pending',
      paymentMethod: json['payment_method'] ?? 'cash',
      baseFare: (json['base_fare'] ?? 0).toDouble(),
      distanceFare: (json['distance_fare'] ?? 0).toDouble(),
      discountAmount: json['discount_amount'] != null
          ? (json['discount_amount']).toDouble()
          : null,
      pointsDiscount: json['points_discount'] != null
          ? (json['points_discount']).toDouble()
          : null,
      totalFare: (json['total_fare'] ?? 0).toDouble(),
      distance: json['distance'] != null ? (json['distance']).toDouble() : null,
      duration: json['duration'],
      couponCode: json['coupon_code'],
      pointsUsed: json['points_used'],
      pointsEarned: json['points_earned'],
      customerRating: json['customer_rating'] != null
          ? (json['customer_rating']).toDouble()
          : null,
      customerComment: json['customer_comment'],
      cancellationReason: json['cancellation_reason'],
      cancelledBy: json['cancelled_by'],
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.parse(json['scheduled_at'])
          : null,
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'])
          : null,
      arrivedAt:
          json['arrived_at'] != null ? DateTime.parse(json['arrived_at']) : null,
      startedAt:
          json['started_at'] != null ? DateTime.parse(json['started_at']) : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      driver: json['driver'] != null ? DriverModel.fromJson(json['driver']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'driver_id': driverId,
      'pickup_lat': pickupLat,
      'pickup_lng': pickupLng,
      'pickup_address': pickupAddress,
      'dropoff_lat': dropoffLat,
      'dropoff_lng': dropoffLng,
      'dropoff_address': dropoffAddress,
      'status': status,
      'payment_method': paymentMethod,
      'base_fare': baseFare,
      'distance_fare': distanceFare,
      'discount_amount': discountAmount,
      'points_discount': pointsDiscount,
      'total_fare': totalFare,
      'distance': distance,
      'duration': duration,
      'coupon_code': couponCode,
      'points_used': pointsUsed,
      'points_earned': pointsEarned,
      'customer_rating': customerRating,
      'customer_comment': customerComment,
      'cancellation_reason': cancellationReason,
      'cancelled_by': cancelledBy,
      'scheduled_at': scheduledAt?.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'arrived_at': arrivedAt?.toIso8601String(),
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'driver': driver?.toJson(),
    };
  }

  // Helper methods for status checking
  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isArrived => status == 'arrived';
  bool get isStarted => status == 'started';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isActive => isPending || isAccepted || isArrived || isStarted;
}
