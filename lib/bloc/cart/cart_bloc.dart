import 'package:flutter_bloc/flutter_bloc.dart';

import '../../modules/customer/cart/domain/repositories/cart_repository.dart';
import '../../modules/customer/cart/domain/usecases/add_to_cart.dart';
import '../../modules/customer/cart/domain/usecases/change_cart_quantity.dart';
import '../../modules/customer/cart/domain/usecases/remove_from_cart.dart';
import '../base/index.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<BaseEvent, CartBlocState> {
  CartBloc(
    this._repository,
    this._addToCart,
    this._removeFromCart,
    this._changeQuantity,
  ) : super(const CartBlocState()) {
    on<CartLoadRequested>(_onLoad);
    on<CartAddRequested>(_onAdd);
    on<CartIncrementRequested>(_onIncrement);
    on<CartDecrementRequested>(_onDecrement);
    on<CartRemoveRequested>(_onRemove);
  }

  final CartRepository _repository;
  final AddToCart _addToCart;
  final RemoveFromCart _removeFromCart;
  final ChangeCartQuantity _changeQuantity;

  Future<void> _onLoad(
    CartLoadRequested event,
    Emitter<CartBlocState> emit,
  ) async {
    final lines = await _repository.getLines();
    emit(state.copyWith(lines: lines));
  }

  Future<void> _onAdd(
    CartAddRequested event,
    Emitter<CartBlocState> emit,
  ) async {
    await _addToCart(event.line);
    add(const CartLoadRequested());
  }

  Future<void> _onIncrement(
    CartIncrementRequested event,
    Emitter<CartBlocState> emit,
  ) async {
    final next = event.line.quantity + 1;
    await _changeQuantity(event.line.productId, event.line.variantId, next);
    add(const CartLoadRequested());
  }

  Future<void> _onDecrement(
    CartDecrementRequested event,
    Emitter<CartBlocState> emit,
  ) async {
    final next = event.line.quantity - 1;
    await _changeQuantity(event.line.productId, event.line.variantId, next);
    add(const CartLoadRequested());
  }

  Future<void> _onRemove(
    CartRemoveRequested event,
    Emitter<CartBlocState> emit,
  ) async {
    await _removeFromCart(event.line.productId, event.line.variantId);
    add(const CartLoadRequested());
  }
}
