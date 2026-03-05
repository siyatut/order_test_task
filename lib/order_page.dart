import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'order_api.dart';
import 'order_controller.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  late final OrderController controller;
  final int userId = 1;
  final int serviceId = 10;

  @override
  void initState() {
    super.initState();

    controller = OrderController(
      OrderApi(
        client: http.Client(),
        baseUrl: 'https://example.com', // placeholder API URL
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Создать заказ')),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final isLoading = controller.state == OrderState.loading;
          final hasError = controller.state == OrderState.error &&
              (controller.errorText?.isNotEmpty ?? false);
          final isSuccess = controller.state == OrderState.success &&
              controller.order != null;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (hasError)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withValues(alpha: .25)),
                    ),
                    child: Text(
                      controller.errorText!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                if (isSuccess)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withValues(alpha: 0.25)),
                    ),
                    child: Text(
                      'Заказ создан.\n'
                      'ID: ${controller.order!.orderId}\n'
                      'Status: ${controller.order!.status}\n'
                      'Payment: ${controller.order!.paymentUrl ?? "none"}',
                    ),
                  ),

                const Spacer(),

                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () => controller.submitOrder(
                              userId: userId,
                              serviceId: serviceId,
                            ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Создать заказ'),
                  ),
                ),

                if (hasError) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: isLoading
                          ? null
                          : () => controller.submitOrder(
                                userId: userId,
                                serviceId: serviceId,
                              ),
                      child: const Text('Повторить попытку'),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
