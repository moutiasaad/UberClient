import 'driver_model.dart';

class RideModel {
  final int id;
  final int? customerId;
  final int? driverId;
  final double pickupLat;
  final double pickupLng;
  final String pickupAddress;
  final double dropoffLat;
  final double dropoffLng;
  final String dropoffAddress;
  final double? distanceKm;
  final int? estimatedDurationMinutes;
  final int? actualDurationMinutes;
  final String status;
  final String? statusText;
  final String? statusColor;
  final String paymentMethod;
  final String? paymentStatus;
  final double baseFare;
  final double distanceFare;
  final double totalFare;
  final double? discountAmount;
  final double finalAmount;
  final int? pointsUsed;
  final double? pointsDiscount;
  final bool isCancellable;
  final String? cancelledBy;
  final String? cancellationReason;
  final DateTime? createdAt;
  final DateTime? acceptedAt;
  final DateTime? driverArrivedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final DriverModel? driver;

  RideModel({
    required this.id,
    this.customerId,
    this.driverId,
    required this.pickupLat,
    required this.pickupLng,
    required this.pickupAddress,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.dropoffAddress,
    this.distanceKm,
    this.estimatedDurationMinutes,
    this.actualDurationMinutes,
    required this.status,
    this.statusText,
    this.statusColor,
    required this.paymentMethod,
    this.paymentStatus,
    required this.baseFare,
    required this.distanceFare,
    required this.totalFare,
    this.discountAmount,
    required this.finalAmount,
    this.pointsUsed,
    this.pointsDiscount,
    this.isCancellable = true,
    this.cancelledBy,
    this.cancellationReason,
    this.createdAt,
    this.acceptedAt,
    this.driverArrivedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.driver,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    // Handle nested pickup object
    final pickup = json['pickup'] as Map<String, dynamic>?;
    final dropoff = json['dropoff'] as Map<String, dynamic>?;
    final fare = json['fare'] as Map<String, dynamic>?;
    final timestamps = json['timestamps'] as Map<String, dynamic>?;

    return RideModel(
      id: json['id'] ?? 0,
      customerId: json['customer_id'],
      driverId: json['driver_id'],
      // Pickup - handle both nested and flat structure
      pickupLat: pickup != null
          ? (pickup['latitude'] ?? 0).toDouble()
          : (json['pickup_lat'] ?? 0).toDouble(),
      pickupLng: pickup != null
          ? (pickup['longitude'] ?? 0).toDouble()
          : (json['pickup_lng'] ?? 0).toDouble(),
      pickupAddress: pickup != null
          ? (pickup['address'] ?? '')
          : (json['pickup_address'] ?? ''),
      // Dropoff - handle both nested and flat structure
      dropoffLat: dropoff != null
          ? (dropoff['latitude'] ?? 0).toDouble()
          : (json['dropoff_lat'] ?? 0).toDouble(),
      dropoffLng: dropoff != null
          ? (dropoff['longitude'] ?? 0).toDouble()
          : (json['dropoff_lng'] ?? 0).toDouble(),
      dropoffAddress: dropoff != null
          ? (dropoff['address'] ?? '')
          : (json['dropoff_address'] ?? ''),
      // Distance and duration
      distanceKm: json['distance_km'] != null
          ? (json['distance_km']).toDouble()
          : null,
      estimatedDurationMinutes: json['estimated_duration_minutes'],
      actualDurationMinutes: json['actual_duration_minutes'],
      // Status
      status: json['status'] ?? 'pending',
      statusText: json['status_text'],
      statusColor: json['status_color'],
      // Payment
      paymentMethod: json['payment_method'] ?? 'cash',
      paymentStatus: json['payment_status'],
      // Fare - handle both nested and flat structure
      baseFare: fare != null
          ? (fare['base_fare'] ?? 0).toDouble()
          : (json['base_fare'] ?? 0).toDouble(),
      distanceFare: fare != null
          ? (fare['distance_fare'] ?? 0).toDouble()
          : (json['distance_fare'] ?? 0).toDouble(),
      totalFare: fare != null
          ? (fare['total_fare'] ?? 0).toDouble()
          : (json['total_fare'] ?? 0).toDouble(),
      discountAmount: fare != null
          ? (fare['discount_amount'] ?? 0).toDouble()
          : (json['discount_amount'] ?? 0).toDouble(),
      finalAmount: fare != null
          ? (fare['final_amount'] ?? fare['total_fare'] ?? 0).toDouble()
          : (json['final_amount'] ?? json['total_fare'] ?? 0).toDouble(),
      pointsUsed: fare != null
          ? fare['points_used']
          : json['points_used'],
      pointsDiscount: fare != null
          ? (fare['points_discount'] ?? 0).toDouble()
          : (json['points_discount'] ?? 0).toDouble(),
      // Cancellation
      isCancellable: json['is_cancellable'] ?? true,
      cancelledBy: json['cancelled_by'],
      cancellationReason: json['cancellation_reason'],
      // Timestamps - handle both nested and flat structure
      createdAt: timestamps != null
          ? (timestamps['created_at'] != null
              ? DateTime.parse(timestamps['created_at'])
              : null)
          : (json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null),
      acceptedAt: timestamps != null
          ? (timestamps['accepted_at'] != null
              ? DateTime.parse(timestamps['accepted_at'])
              : null)
          : (json['accepted_at'] != null
              ? DateTime.parse(json['accepted_at'])
              : null),
      driverArrivedAt: timestamps != null
          ? (timestamps['driver_arrived_at'] != null
              ? DateTime.parse(timestamps['driver_arrived_at'])
              : null)
          : (json['driver_arrived_at'] != null
              ? DateTime.parse(json['driver_arrived_at'])
              : null),
      startedAt: timestamps != null
          ? (timestamps['started_at'] != null
              ? DateTime.parse(timestamps['started_at'])
              : null)
          : (json['started_at'] != null
              ? DateTime.parse(json['started_at'])
              : null),
      completedAt: timestamps != null
          ? (timestamps['completed_at'] != null
              ? DateTime.parse(timestamps['completed_at'])
              : null)
          : (json['completed_at'] != null
              ? DateTime.parse(json['completed_at'])
              : null),
      cancelledAt: timestamps != null
          ? (timestamps['cancelled_at'] != null
              ? DateTime.parse(timestamps['cancelled_at'])
              : null)
          : (json['cancelled_at'] != null
              ? DateTime.parse(json['cancelled_at'])
              : null),
      // Driver
      driver: json['driver'] != null ? DriverModel.fromJson(json['driver']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'driver_id': driverId,
      'pickup': {
        'latitude': pickupLat,
        'longitude': pickupLng,
        'address': pickupAddress,
      },
      'dropoff': {
        'latitude': dropoffLat,
        'longitude': dropoffLng,
        'address': dropoffAddress,
      },
      'distance_km': distanceKm,
      'estimated_duration_minutes': estimatedDurationMinutes,
      'actual_duration_minutes': actualDurationMinutes,
      'fare': {
        'base_fare': baseFare,
        'distance_fare': distanceFare,
        'total_fare': totalFare,
        'discount_amount': discountAmount,
        'final_amount': finalAmount,
        'points_used': pointsUsed,
        'points_discount': pointsDiscount,
      },
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'status': status,
      'status_text': statusText,
      'status_color': statusColor,
      'is_cancellable': isCancellable,
      'cancelled_by': cancelledBy,
      'cancellation_reason': cancellationReason,
      'timestamps': {
        'created_at': createdAt?.toIso8601String(),
        'accepted_at': acceptedAt?.toIso8601String(),
        'driver_arrived_at': driverArrivedAt?.toIso8601String(),
        'started_at': startedAt?.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'cancelled_at': cancelledAt?.toIso8601String(),
      },
      'driver': driver?.toJson(),
    };
  }

  // Helper methods for status checking
  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isArrived => status == 'arrived' || status == 'driver_arrived';
  bool get isStarted => status == 'started' || status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isActive => isPending || isAccepted || isArrived || isStarted;
}
