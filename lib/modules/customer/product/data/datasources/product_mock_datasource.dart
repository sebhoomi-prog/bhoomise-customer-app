import '../models/product_model.dart';
import '../models/product_variant_model.dart';
import 'product_remote_datasource.dart';

/// In-memory catalog until a remote [ProductRemoteDataSource] is wired (e.g. REST API).
class ProductMockDataSource implements ProductRemoteDataSource {
  @override
  Future<List<ProductModel>> fetchProducts() async {
    return [
      ProductModel(
        id: 'mushroom_oyster',
        name: 'Fresh Oyster Mushrooms',
        description: 'Grown locally, ideal for stir-fry and soups.',
        imageUrl:
            'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?fm=jpg&fit=crop&w=800&q=80',
        variants: [
          ProductVariantModel(
            id: 'v200',
            label: '200 g',
            totalGrams: 200,
            priceMinor: 9000,
            stock: 40,
            lowStockThreshold: 8,
          ),
          ProductVariantModel(
            id: 'v500',
            label: '500 g',
            totalGrams: 500,
            priceMinor: 20000,
            stock: 22,
            lowStockThreshold: 5,
          ),
          ProductVariantModel(
            id: 'v1k',
            label: '1 kg',
            totalGrams: 1000,
            priceMinor: 38000,
            stock: 18,
            lowStockThreshold: 4,
          ),
          ProductVariantModel(
            id: 'v2k',
            label: '2 kg',
            totalGrams: 2000,
            priceMinor: 72000,
            stock: 10,
            lowStockThreshold: 3,
          ),
          ProductVariantModel(
            id: 'v10k',
            label: '10 kg',
            totalGrams: 10000,
            priceMinor: 320000,
            stock: 4,
            lowStockThreshold: 2,
          ),
        ],
      ),
      ProductModel(
        id: 'mushroom_button',
        name: 'Button Mushrooms',
        description: 'Versatile white mushrooms for everyday cooking.',
        imageUrl:
            'https://images.unsplash.com/photo-1567333506008-8be40c293909?fm=jpg&fit=crop&w=800&q=80',
        variants: [
          ProductVariantModel(
            id: 'bv250',
            label: '250 g',
            totalGrams: 250,
            priceMinor: 7500,
            stock: 3,
            lowStockThreshold: 5,
          ),
          ProductVariantModel(
            id: 'bv500',
            label: '500 g',
            totalGrams: 500,
            priceMinor: 17000,
            stock: 0,
            lowStockThreshold: 5,
          ),
        ],
      ),
    ];
  }
}
