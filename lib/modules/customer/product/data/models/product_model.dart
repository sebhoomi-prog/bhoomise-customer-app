import '../../../../../core/util/product_image_url.dart';
import '../../domain/entities/product.dart';
import 'product_variant_model.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.variants,
    super.description,
    super.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final variants = (json['variants'] as List<dynamic>? ?? [])
        .map((e) => ProductVariantModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return ProductModel(
      id: (json['id'] ?? json['product_id'] ?? '').toString(),
      name: (json['name'] ?? json['product_name'] ?? json['display_name'] ?? '')
          .toString(),
      description: json['description'] as String?,
      imageUrl: sanitizeProductImageUrl(
        json['image_url'] as String? ?? json['hero_image_url'] as String?,
      ),
      variants: variants,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        if (imageUrl != null) 'image_url': imageUrl,
        'variants': variants
            .map((v) => ProductVariantModel.fromEntity(v).toJson())
            .toList(),
      };
}
