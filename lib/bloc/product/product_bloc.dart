import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/network_exceptions.dart';
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
    } on NetworkException catch (e) {
      final message = e.message.trim().isEmpty
          ? 'Unable to reach server. Please check your internet and try again.'
          : e.message;
      emit(state.copyWith(loading: false, errorMessage: message));
    } on Object {
      emit(
        state.copyWith(
          loading: false,
          errorMessage:
              'Unable to load products right now. Please try again in a moment.',
        ),
      );
    }
  }
}
