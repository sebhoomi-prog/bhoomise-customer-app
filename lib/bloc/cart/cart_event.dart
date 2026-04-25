import '../../modules/customer/cart/domain/entities/cart_line.dart';
import '../base/index.dart';

class CartLoadRequested extends BaseEvent {
  const CartLoadRequested();
}

class CartAddRequested extends BaseEvent {
  const CartAddRequested(this.line);

  final CartLine line;

  @override
  List<Object?> get props => <Object?>[line];
}

class CartIncrementRequested extends BaseEvent {
  const CartIncrementRequested(this.line);

  final CartLine line;

  @override
  List<Object?> get props => <Object?>[line];
}

class CartDecrementRequested extends BaseEvent {
  const CartDecrementRequested(this.line);

  final CartLine line;

  @override
  List<Object?> get props => <Object?>[line];
}

class CartRemoveRequested extends BaseEvent {
  const CartRemoveRequested(this.line);

  final CartLine line;

  @override
  List<Object?> get props => <Object?>[line];
}
