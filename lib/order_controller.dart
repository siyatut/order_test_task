import 'package:flutter/foundation.dart';

import 'api_exception.dart';
import 'order.dart';
import 'order_api.dart';

enum OrderState { initial, loading, success, error }

class OrderController extends ChangeNotifier {
  final OrderApi _api;

  OrderController(this._api);

  OrderState state = OrderState.initial;
  Order? order;
  String? errorText;

  Future<void> submitOrder({
    required int userId,
    required int serviceId,
  }) async {
    state = OrderState.loading;
    errorText = null;
    order = null;
    notifyListeners();

    try {
      final created = await _api.createOrder(
        userId: userId,
        serviceId: serviceId,
      );

      order = created;
      state = OrderState.success;
      notifyListeners();
    } on ApiException catch (e) {
      errorText = e.message;
      state = OrderState.error;
      notifyListeners();
    }
  }
}
