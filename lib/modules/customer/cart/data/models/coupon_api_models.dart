class CouponApiModel {
  const CouponApiModel({
    required this.code,
    required this.percentOff,
    required this.active,
    this.maxRedemptions,
    this.eligiblePackGrams,
    this.minPackGramsAnyLine,
    this.badge,
    this.description,
    this.expiresAt,
  });

  final String code;
  final int percentOff;
  final bool active;
  final int? maxRedemptions;
  final List<int>? eligiblePackGrams;
  final int? minPackGramsAnyLine;
  final String? badge;
  final String? description;
  final DateTime? expiresAt;

  factory CouponApiModel.fromJson(Map<String, dynamic> json) {
    final packsRaw = json['eligiblePackGrams'] ?? json['eligible_pack_grams'];
    final packs = packsRaw is List
        ? packsRaw
            .whereType<num>()
            .map((e) => e.toInt())
            .where((e) => e > 0)
            .toList()
        : null;
    final minRaw = json['minPackGramsAnyLine'] ?? json['min_pack_grams_any_line'];
    return CouponApiModel(
      code: (json['code'] ?? '').toString().trim().toUpperCase(),
      percentOff: (json['percentOff'] as num?)?.toInt() ?? 0,
      active: json['active'] as bool? ?? true,
      maxRedemptions: (json['maxRedemptions'] as num?)?.toInt(),
      eligiblePackGrams: (packs == null || packs.isEmpty) ? null : packs,
      minPackGramsAnyLine: (minRaw as num?)?.toInt(),
      badge: json['badge']?.toString() ?? json['category']?.toString(),
      description: json['description']?.toString(),
      expiresAt: _parseDate(json['expiresAt'] ?? json['expires_at']),
    );
  }

  Map<String, dynamic> toCouponOfferMap() => {
        'code': code,
        'percentOff': percentOff,
        'active': active,
        if (eligiblePackGrams != null) 'eligiblePackGrams': eligiblePackGrams,
        if (minPackGramsAnyLine != null)
          'minPackGramsAnyLine': minPackGramsAnyLine,
      };

  static DateTime? _parseDate(dynamic value) {
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

class CouponListResponseModel {
  const CouponListResponseModel({required this.items});

  final List<CouponApiModel> items;

  factory CouponListResponseModel.fromApi(dynamic body) {
    final items = _extractItems(body).map(CouponApiModel.fromJson).toList();
    return CouponListResponseModel(items: items);
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

class CouponSingleResponseModel {
  const CouponSingleResponseModel({required this.item});

  final CouponApiModel item;

  factory CouponSingleResponseModel.fromApi(dynamic body) {
    if (body is! Map) {
      throw const FormatException('Invalid coupon response body.');
    }
    final map = Map<String, dynamic>.from(body);
    final data = map['data'];
    final payload = data is Map ? data : map;
    return CouponSingleResponseModel(
      item: CouponApiModel.fromJson(Map<String, dynamic>.from(payload)),
    );
  }
}
