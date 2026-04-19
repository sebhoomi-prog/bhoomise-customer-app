import 'product_variant.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.variants,
    this.description,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final List<ProductVariant> variants;
}
