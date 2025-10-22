import 'package:equatable/equatable.dart';
import '../../data/models/cart_item_model.dart';

enum CartStatus { idle, adding, removing, checkingOut, success, error }

class CartState extends Equatable {
  final CartStatus status;
  final List<CartItemModel> items;
  final String? errorMessage;

  const CartState({
    this.status = CartStatus.idle,
    this.items = const [],
    this.errorMessage,
  });

  double get total => items.fold(0.0, (sum, item) => sum + item.price);

  CartState copyWith({
    CartStatus? status,
    List<CartItemModel>? items,
    String? errorMessage,
  }) {
    return CartState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
