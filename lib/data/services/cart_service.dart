import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../../core/network/dio_client.dart';

/// Servicio de carrito de compras (Commerce Service)
class CartService {
  final DioClient _dioClient = DioClient();

  /// Obtener carrito del usuario
  Future<Map<String, dynamic>> getCart(String userId) async {
    try {
      final response = await _dioClient.get(ApiConfig.cart(userId));

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error obteniendo carrito');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Añadir item al carrito
  ///
  /// itemType: 'PRODUCT' o 'VARIANT'
  Future<Map<String, dynamic>> addToCart({
    required String userId,
    required String itemId,
    required String itemType, // PRODUCT o VARIANT
    required int quantity,
    required double price,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.cartItems(userId),
        data: {
          'itemId': itemId,
          'itemType': itemType,
          'quantity': quantity,
          'price': price,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Error añadiendo al carrito');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Actualizar cantidad de item en carrito
  Future<Map<String, dynamic>> updateCartItem({
    required String userId,
    required String itemId,
    required int quantity,
  }) async {
    try {
      final response = await _dioClient.put(
        ApiConfig.cartItem(userId, itemId),
        data: {'quantity': quantity},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error actualizando item del carrito');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Eliminar item del carrito
  Future<void> removeFromCart({
    required String userId,
    required String itemId,
  }) async {
    try {
      final response = await _dioClient.delete(
        ApiConfig.cartItem(userId, itemId),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error eliminando item del carrito');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Vaciar carrito
  Future<void> clearCart(String userId) async {
    try {
      final response = await _dioClient.delete(ApiConfig.cart(userId));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error vaciando carrito');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtener número de items en carrito
  Future<int> getCartCount(String userId) async {
    try {
      final response = await _dioClient.get(ApiConfig.cartCount(userId));

      if (response.statusCode == 200) {
        return response.data as int;
      } else {
        throw Exception('Error obteniendo cantidad de items');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtener total del carrito
  Future<double> getCartTotal(String userId) async {
    try {
      final response = await _dioClient.get(ApiConfig.cartTotal(userId));

      if (response.statusCode == 200) {
        final total = response.data;
        return (total is int) ? total.toDouble() : total as double;
      } else {
        throw Exception('Error obteniendo total del carrito');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Manejo de errores
  Exception _handleError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;

      switch (statusCode) {
        case 400:
          return Exception('Datos inválidos');
        case 401:
          return Exception('No autorizado');
        case 403:
          return Exception('Acceso denegado');
        case 404:
          return Exception('Carrito no encontrado');
        default:
          return Exception(data['message'] ?? 'Error del servidor');
      }
    } else {
      return Exception('Error de conexión');
    }
  }
}
