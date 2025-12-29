class PointsModel {
  final int totalPoints;
  final List<PointTransaction> transactions;

  PointsModel({
    required this.totalPoints,
    required this.transactions,
  });

  factory PointsModel.fromJson(Map<String, dynamic> json) {
    return PointsModel(
      totalPoints: json['total_points'] ?? json['balance'] ?? 0,
      transactions: json['transactions'] != null
          ? (json['transactions'] as List)
              .map((t) => PointTransaction.fromJson(t))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_points': totalPoints,
      'transactions': transactions.map((t) => t.toJson()).toList(),
    };
  }
}

class PointTransaction {
  final int id;
  final String type;
  final int points;
  final String description;
  final int? rideId;
  final DateTime createdAt;

  PointTransaction({
    required this.id,
    required this.type,
    required this.points,
    required this.description,
    this.rideId,
    required this.createdAt,
  });

  factory PointTransaction.fromJson(Map<String, dynamic> json) {
    return PointTransaction(
      id: json['id'] ?? 0,
      type: json['type'] ?? 'earned',
      points: json['points'] ?? 0,
      description: json['description'] ?? '',
      rideId: json['ride_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'points': points,
      'description': description,
      'ride_id': rideId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isEarned => type == 'earned';
  bool get isRedeemed => type == 'redeemed';
}
