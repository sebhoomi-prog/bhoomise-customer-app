import '../../domain/entities/delivery_address.dart';

class DeliveryAddressModel extends DeliveryAddress {
  const DeliveryAddressModel({
    required super.id,
    required super.label,
    required super.recipientName,
    required super.phone,
    required super.line1,
    super.line2,
    super.landmark,
    required super.city,
    required super.state,
    required super.pincode,
    required super.isDefault,
  });

  factory DeliveryAddressModel.fromJson(Map<String, dynamic> json) {
    return DeliveryAddressModel(
      id: json['id'] as String,
      label: json['label'] as String? ?? 'Other',
      recipientName: json['recipientName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      line1: json['line1'] as String? ?? '',
      line2: json['line2'] as String?,
      landmark: json['landmark'] as String?,
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'recipientName': recipientName,
      'phone': phone,
      'line1': line1,
      'line2': line2,
      'landmark': landmark,
      'city': city,
      'state': state,
      'pincode': pincode,
      'isDefault': isDefault,
    };
  }

  @override
  DeliveryAddressModel copyWith({
    String? id,
    String? label,
    String? recipientName,
    String? phone,
    String? line1,
    String? line2,
    String? landmark,
    String? city,
    String? state,
    String? pincode,
    bool? isDefault,
  }) {
    return DeliveryAddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      recipientName: recipientName ?? this.recipientName,
      phone: phone ?? this.phone,
      line1: line1 ?? this.line1,
      line2: line2 ?? this.line2,
      landmark: landmark ?? this.landmark,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
