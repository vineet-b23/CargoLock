import 'package:http/http.dart' as http;
import 'dart:convert';

const String BASE_URL = 'http://172.16.44.245:3000/api';
class ApiService {
  
  static Future<List> getCustomerOrders(String walletAddress) async {
    try {
      final res = await http.get(Uri.parse('$BASE_URL/orders/customer/$walletAddress'));
      final data = jsonDecode(res.body);
      return data is List ? data : data['orders'] ?? [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> createOrder(
    String driverAddress, 
    String cargoDetails, 
    String amount, 
    {String? deliveryTime} 
  ) async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      return {'success': true, 'orderId': 'CRGO-${DateTime.now().millisecondsSinceEpoch}'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  static Future<Map> confirmDelivery(String orderId) async {
    try {
      final res = await http.post(
        Uri.parse('$BASE_URL/order/confirm'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'orderId': orderId}),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  static Future<Map> raiseDispute(String orderId) async {
    try {
      final res = await http.post(
        Uri.parse('$BASE_URL/order/dispute'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'orderId': orderId}),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  static Future<List> getDriverOrders(String walletAddress) async {
    try {
      final res = await http.get(Uri.parse('$BASE_URL/orders/driver/$walletAddress'));
      final data = jsonDecode(res.body);
      return data is List ? data : data['orders'] ?? [];
    } catch (e) {
      return [];
    }
  }

  static Future<List> getSupplierOrders(String walletAddress) async {
    try {
      final res = await http.get(Uri.parse('$BASE_URL/orders/supplier/$walletAddress'));
      final data = jsonDecode(res.body);
      return data is List ? data : data['orders'] ?? [];
    } catch (e) {
      return [];
    }
  }

  static Future<List> getAdminOrders() async {
    try {
      final res = await http.get(Uri.parse('$BASE_URL/orders/admin'));
      final data = jsonDecode(res.body);
      return data is List ? data : data['orders'] ?? [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map> assignDriver(String orderId, String driverAddress) async {
    try {
      final res = await http.post(
        Uri.parse('$BASE_URL/order/assign-driver'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'orderId': orderId, 'driverAddress': driverAddress}),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}