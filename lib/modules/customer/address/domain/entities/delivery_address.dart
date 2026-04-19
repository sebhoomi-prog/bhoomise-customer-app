class DeliveryAddress {
  const DeliveryAddress({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.phone,
    required this.line1,
    this.line2,
    this.landmark,
    required this.city,
    required this.state,
    required this.pincode,
    required this.isDefault,
  });

  final String id;
  final String label;
  final String recipientName;
  final String phone;
  final String line1;
  final String? line2;
  final String? landmark;
  final String city;
  final String state;
  final String pincode;
  final bool isDefault;

  DeliveryAddress copyWith({
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
    return DeliveryAddress(
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
