class PointsModel {
  final int balance;
  final double valueInDinar;
  final int pointsToDinarRate;
  final String currency;
  final List<PointHistory> history;

  PointsModel({
    required this.balance,
    required this.valueInDinar,
    required this.pointsToDinarRate,
    required this.currency,
    required this.history,
  });

  factory PointsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return PointsModel(
      balance: data['balance'] ?? 0,
      valueInDinar: (data['value_in_dinar'] ?? 0).toDouble(),
      pointsToDinarRate: data['points_to_dinar_rate'] ?? 100,
      currency: data['currency'] ?? 'SAR',
      history: (data['history'] as List?)
              ?.map((item) => PointHistory.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class PointHistory {
  final int id;
  final String type;
  final String typeText;
  final int points;
  final int balanceAfter;
  final int? rideId;
  final String description;
  final bool isPositive;
  final DateTime createdAt;

  PointHistory({
    required this.id,
    required this.type,
    required this.typeText,
    required this.points,
    required this.balanceAfter,
    this.rideId,
    required this.description,
    required this.isPositive,
    required this.createdAt,
  });

  factory PointHistory.fromJson(Map<String, dynamic> json) {
    return PointHistory(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      typeText: json['type_text'] ?? '',
      points: json['points'] ?? 0,
      balanceAfter: json['balance_after'] ?? 0,
      rideId: json['ride_id'],
      description: json['description'] ?? '',
      isPositive: json['is_positive'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
