import 'package:flutter_bloc/flutter_bloc.dart';
import 'cart_event.dart';
import 'cart_state.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/services/cart_service.dart';
import '../../data/services/order_service.dart';
import '../../data/services/auth_service.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartService _cartService;
  final OrderService _orderService;
  final AuthService _authService;

  CartBloc({
    CartService? cartService,
    OrderService? orderService,
    AuthService? authService,
  })  : _cartService = cartService ?? CartService(),
        _orderService = orderService ?? OrderService(),
        _authService = authService ?? AuthService(),
        super(const CartState()) {
    on<CartAddItem>(_onAddItem);
    on<CartRemoveItem>(_onRemoveItem);
    on<CartClear>(_onClear);
    on<CartCheckout>(_onCheckout);
    on<CartLoad>(_onLoadCart);
  }

  Future<void> _onAddItem(CartAddItem event, Emitter<CartState> emit) async {
    emit(state.copyWith(status: CartStatus.adding));

    try {
      final userId = await _authService.getUserId();
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Añadir item al carrito en el backend
      await _cartService.addToCart(
        userId: userId,
        itemId: event.item.itemId,
        itemType: event.item.type.name.toUpperCase(),
        quantity: 1,
        price: event.item.price,
      );

      // Recargar el carrito completo
      final cartData = await _cartService.getCart(userId);
      final items = _parseCartItems(cartData['items'] ?? []);

      emit(state.copyWith(status: CartStatus.idle, items: items));
    } catch (e) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: 'Error añadiendo al carrito: $e',
      ));
      // Volver a idle después de mostrar el error
      await Future.delayed(const Duration(seconds: 2));
      emit(state.copyWith(status: CartStatus.idle));
    }
  }

  Future<void> _onRemoveItem(
    CartRemoveItem event,
    Emitter<CartState> emit,
  ) async {
    emit(state.copyWith(status: CartStatus.removing));

    try {
      final userId = await _authService.getUserId();
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Eliminar item del backend
      await _cartService.removeFromCart(
        userId: userId,
        itemId: event.itemId,
      );

      // Actualizar el estado local
      final updatedItems =
          state.items.where((item) => item.itemId != event.itemId).toList();

      emit(state.copyWith(status: CartStatus.idle, items: updatedItems));
    } catch (e) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: 'Error eliminando del carrito: $e',
      ));
      await Future.delayed(const Duration(seconds: 2));
      emit(state.copyWith(status: CartStatus.idle));
    }
  }

  Future<void> _onClear(CartClear event, Emitter<CartState> emit) async {
    try {
      final userId = await _authService.getUserId();
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      await _cartService.clearCart(userId);
      emit(const CartState());
    } catch (e) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: 'Error limpiando carrito: $e',
      ));
    }
  }

  Future<void> _onCheckout(CartCheckout event, Emitter<CartState> emit) async {
    emit(state.copyWith(status: CartStatus.checkingOut));

    try {
      final userId = await _authService.getUserId();
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Preparar items para la orden
      final orderItems = state.items.map((item) {
        return {
          'itemId': item.itemId,
          'itemType': item.type.name.toUpperCase(),
          'quantity': 1,
          'price': item.price,
        };
      }).toList();

      // Crear orden
      final order = await _orderService.createOrder(
        userId: userId,
        items: orderItems,
        shippingAddress: event.shippingAddress ?? 'Dirección no especificada',
      );

      // Limpiar carrito después de checkout exitoso
      await _cartService.clearCart(userId);

      emit(state.copyWith(
        status: CartStatus.success,
        items: [],
      ));

      // Volver a idle después de mostrar éxito
      await Future.delayed(const Duration(seconds: 1));
      emit(const CartState());
    } catch (e) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: 'Error en checkout: $e',
      ));
      await Future.delayed(const Duration(seconds: 2));
      emit(state.copyWith(status: CartStatus.idle));
    }
  }

  Future<void> _onLoadCart(CartLoad event, Emitter<CartState> emit) async {
    emit(state.copyWith(status: CartStatus.adding));

    try {
      final userId = await _authService.getUserId();
      if (userId == null) {
        emit(const CartState());
        return;
      }

      final cartData = await _cartService.getCart(userId);
      final items = _parseCartItems(cartData['items'] ?? []);

      emit(state.copyWith(status: CartStatus.idle, items: items));
    } catch (e) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: 'Error cargando carrito: $e',
      ));
      await Future.delayed(const Duration(seconds: 2));
      emit(state.copyWith(status: CartStatus.idle));
    }
  }

  List<CartItemModel> _parseCartItems(List<dynamic> items) {
    return items.map((item) {
      return CartItemModel(
        id: item['id'] ?? '',
        itemId: item['itemId'] ?? '',
        type: _parseItemType(item['itemType'] ?? 'PRODUCT'),
        title: item['title'] ?? 'Sin título',
        artistName: item['artistName'] ?? 'Artista desconocido',
        price: (item['price'] is int)
            ? (item['price'] as int).toDouble()
            : (item['price'] ?? 0.0) as double,
        coverUrl: item['coverUrl'] ?? '',
      );
    }).toList();
  }

  CartItemType _parseItemType(String type) {
    switch (type.toUpperCase()) {
      case 'SONG':
        return CartItemType.song;
      case 'ALBUM':
        return CartItemType.album;
      case 'PRODUCT':
      case 'VARIANT':
      default:
        return CartItemType.album; // Por defecto
    }
  }
}
