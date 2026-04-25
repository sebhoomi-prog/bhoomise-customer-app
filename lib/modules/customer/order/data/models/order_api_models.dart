class CreateOrderRequestModel {
  const CreateOrderRequestModel({
    required this.type,
    required this.status,
    required this.storeId,
    required this.storeName,
    required this.totalLabel,
    required this.items,
  });

  final String type;
  final String status;
  final String storeId;
  final String storeName;
  final String totalLabel;
  final List<Map<String, dynamic>> items;

  Map<String, dynamic> toJson() => {
        'type': type,
        'status': status,
        'storeId': storeId,
        'storeName': storeName,
        'totalLabel': totalLabel,
        'items': items,
      };
}

class OrderApiModel {
  const OrderApiModel({
    required this.id,
    required this.type,
    required this.status,
    required this.storeId,
    required this.storeName,
    required this.totalLabel,
    this.items = const [],
  });

  final String id;
  final String type;
  final String status;
  final String storeId;
  final String storeName;
  final String totalLabel;
  final List<Map<String, dynamic>> items;

  factory OrderApiModel.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'];
    final parsedItems = itemsRaw is List
        ? itemsRaw
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList()
        : const <Map<String, dynamic>>[];
    return OrderApiModel(
      id: (json['id'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      storeId: (json['storeId'] ?? '').toString(),
      storeName: (json['storeName'] ?? '').toString(),
      totalLabel: (json['totalLabel'] ?? '').toString(),
      items: parsedItems,
    );
  }
}

class OrderListResponseModel {
  const OrderListResponseModel({required this.items});

  final List<OrderApiModel> items;

  factory OrderListResponseModel.fromApi(dynamic body) {
    final raw = _extractItems(body);
    return OrderListResponseModel(
      items: raw.map(OrderApiModel.fromJson).toList(),
    );
  }

  static List<Map<String, dynamic>> _extractItems(dynamic body) {
    if (body is Map) {
      final map = Map<String, dynamic>.from(body);
      final data = map['data'];
      if (data is Map && data['items'] is List) {
        return (data['items'] as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      if (map['items'] is List) {
        return (map['items'] as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }
    if (body is List) {
      return body
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }
}
