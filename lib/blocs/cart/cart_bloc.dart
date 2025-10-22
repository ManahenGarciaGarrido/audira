import 'package:audira/data/models/cart_item_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<CartAddItem>(_onAddItem);
    on<CartRemoveItem>(_onRemoveItem);
    on<CartClear>(_onClear);
    on<CartCheckout>(_onCheckout);
  }

  Future<void> _onAddItem(CartAddItem event, Emitter<CartState> emit) async {
    emit(state.copyWith(status: CartStatus.adding));

    await Future.delayed(const Duration(milliseconds: 300));

    final updatedItems = List<CartItemModel>.from(state.items);

    // Verificar si el item ya existe
    final existingIndex = updatedItems.indexWhere(
      (item) => item.itemId == event.item.itemId,
    );

    if (existingIndex == -1) {
      updatedItems.add(event.item);
    }

    emit(state.copyWith(status: CartStatus.idle, items: updatedItems));
  }

  Future<void> _onRemoveItem(
    CartRemoveItem event,
    Emitter<CartState> emit,
  ) async {
    emit(state.copyWith(status: CartStatus.removing));

    await Future.delayed(const Duration(milliseconds: 200));

    final updatedItems =
        state.items.where((item) => item.itemId != event.itemId).toList();

    emit(state.copyWith(status: CartStatus.idle, items: updatedItems));
  }

  Future<void> _onClear(CartClear event, Emitter<CartState> emit) async {
    emit(const CartState());
  }

  Future<void> _onCheckout(CartCheckout event, Emitter<CartState> emit) async {
    emit(state.copyWith(status: CartStatus.checkingOut));

    await Future.delayed(const Duration(seconds: 2));

    emit(state.copyWith(status: CartStatus.success));

    await Future.delayed(const Duration(milliseconds: 500));

    emit(const CartState());
  }
}
