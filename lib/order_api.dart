import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_exception.dart';
import 'order.dart';

class OrderApi {
  final http.Client _client;
  final Uri _baseUri;

  OrderApi({
    required http.Client client,
    required String baseUrl, 
  })  : _client = client,
        _baseUri = Uri.parse(baseUrl);

  Future<Order> createOrder({
    required int userId,
    required int serviceId,
  }) async {
    final url = _baseUri.replace(path: '/api/orders');

    try {
      final response = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'userId': userId,
              'serviceId': serviceId,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return Order.fromJson(decoded);
        }
        throw const ApiException('Некорректный формат ответа сервера');
      }

      if (response.statusCode >= 400) {
        final message = _extractErrorMessage(response.body) ??
            'Ошибка сервера (${response.statusCode})';
        throw ApiException(message, statusCode: response.statusCode);
      }

      throw ApiException(
        'Неожиданный ответ сервера (${response.statusCode})',
        statusCode: response.statusCode,
      );
    } on TimeoutException {
      throw const ApiException('Превышено время ожидания ответа (10 секунд)');
    } on SocketException {
      throw const ApiException('Нет интернета. Проверьте подключение');
    } on FormatException {
      throw const ApiException('Не удалось обработать ответ сервера');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Неизвестная ошибка. Попробуйте ещё раз');
    }
  }

  String? _extractErrorMessage(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return null;

    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) {
        final msg = decoded['message'] ?? decoded['error'] ?? decoded['detail'];
        if (msg is String && msg.trim().isNotEmpty) return msg.trim();
      }
    } catch (_) { }

    return trimmed.isNotEmpty ? trimmed : null;
  }
}
