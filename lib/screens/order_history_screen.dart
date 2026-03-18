import 'package:baibanhang/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  static const routeName = '/order-history';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lich su don hang')),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.orders.isEmpty) {
            return const Center(child: Text('Chua co don hang nao.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cart.orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final order = cart.orders[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Don hang #${order.id}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text('Thoi gian: ${order.createdAt}'),
                      Text('So san pham: ${order.items.length}'),
                      const SizedBox(height: 6),
                      Text(
                        'Tong tien: ${order.totalAmount.toStringAsFixed(0)} VND',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
