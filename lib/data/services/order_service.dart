import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../../core/network/dio_client.dart';

/// Servicio de órdenes (Commerce Service)
class OrderService {
  final DioClient _dioClient = DioClient();

  /// Crear nueva orden
  Future<Map<String, dynamic>> createOrder({
    required String userId,
    required List<Map<String, dynamic>> items,
    required String shippingAddress,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.orders,
        data: {
          'userId': userId,
          'items': items,
          'shippingAddress': shippingAddress,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error creando orden');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtener orden por ID
  Future<Map<String, dynamic>> getOrder(String orderId) async {
    try {
      final response = await _dioClient.get(ApiConfig.orderById(orderId));

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error obteniendo orden');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtener orden por número de orden
  Future<Map<String, dynamic>> getOrderByNumber(String orderNumber) async {
    try {
      final response = await _dioClient.get(ApiConfig.orderByNumber(orderNumber));

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error obteniendo orden');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtener todas las órdenes
  Future<List<Map<String, dynamic>>> getAllOrders() async {
    try {
      final response = await _dioClient.get(ApiConfig.orders);

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Error obteniendo órdenes');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtener órdenes del usuario
  Future<List<Map<String, dynamic>>> getOrdersByUser(String userId) async {
    try {
      final response = await _dioClient.get(ApiConfig.ordersByUser(userId));

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Error obteniendo órdenes del usuario');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtener órdenes por estado
  Future<List<Map<String, dynamic>>> getOrdersByStatus(String status) async {
    try {
      final response = await _dioClient.get(ApiConfig.ordersByStatus(status));

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Error obteniendo órdenes por estado');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Actualizar estado de orden
  Future<Map<String, dynamic>> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      final response = await _dioClient.put(
        ApiConfig.updateOrderStatus(orderId),
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error actualizando estado de orden');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Cancelar orden
  Future<Map<String, dynamic>> cancelOrder(String orderId) async {
    try {
      final response = await _dioClient.post(ApiConfig.cancelOrder(orderId));

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error cancelando orden');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Eliminar orden
  Future<void> deleteOrder(String orderId) async {
    try {
      final response = await _dioClient.delete(ApiConfig.orderById(orderId));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error eliminando orden');
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
          return Exception('Orden no encontrada');
        default:
          return Exception(data['message'] ?? 'Error del servidor');
      }
    } else {
      return Exception('Error de conexión');
    }
  }
}
