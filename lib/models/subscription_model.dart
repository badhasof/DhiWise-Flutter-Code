class SubscriptionModel {
  final String id;
  final String name;
  final String type; // "monthly" or "lifetime"
  final double price;
  final String status; // "active", "expired", "canceled"
  final DateTime? startDate;
  final DateTime? endDate;

  SubscriptionModel({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.status,
    this.startDate,
    this.endDate,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'expired',
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'price': price,
      'status': status,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }

  bool get isActive => status == 'active';
} 