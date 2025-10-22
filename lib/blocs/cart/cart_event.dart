import 'package:equatable/equatable.dart';
import '../../data/models/cart_item_model.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class CartAddItem extends CartEvent {
  final CartItemModel item;

  const CartAddItem(this.item);

  @override
  List<Object?> get props => [item];
}

class CartRemoveItem extends CartEvent {
  final String itemId;

  const CartRemoveItem(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class CartClear extends CartEvent {
  const CartClear();
}

class CartCheckout extends CartEvent {
  const CartCheckout();
}
