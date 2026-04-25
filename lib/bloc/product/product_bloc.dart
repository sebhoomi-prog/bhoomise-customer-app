import 'package:flutter_bloc/flutter_bloc.dart';

import '../../modules/customer/product/domain/usecases/get_products.dart';
import '../base/index.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<BaseEvent, ProductBlocState> {
  ProductBloc(this._getProducts) : super(const ProductBlocState()) {
    on<ProductLoadRequested>(_onLoad);
    on<ProductRefreshRequested>(_onLoad);
  }

  final GetProducts _getProducts;

  Future<void> _onLoad(
    BaseEvent event,
    Emitter<ProductBlocState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final products = await _getProducts();
      emit(state.copyWith(loading: false, products: products));
    } on Object catch (e) {
      emit(state.copyWith(loading: false, errorMessage: e.toString()));
    }
  }
}
