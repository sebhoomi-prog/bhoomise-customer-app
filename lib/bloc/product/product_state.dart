import '../../modules/customer/product/domain/entities/product.dart';

class ProductBlocState {
  const ProductBlocState({
    this.loading = true,
    this.products = const <Product>[],
    this.errorMessage,
  });

  final bool loading;
  final List<Product> products;
  final String? errorMessage;

  ProductBlocState copyWith({
    bool? loading,
    List<Product>? products,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProductBlocState(
      loading: loading ?? this.loading,
      products: products ?? this.products,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
