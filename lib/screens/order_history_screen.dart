import 'package:baibanhang/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  static const routeName = '/order-history';

  String _formatCurrency(double value) {
    final digits = value.round().toString();
    final reversed = digits.split('').reversed.toList();
    final groups = <String>[];
    for (var i = 0; i < reversed.length; i += 3) {
      final chunk = reversed.skip(i).take(3).toList();
      groups.add(chunk.reversed.join());
    }
    return '${groups.reversed.join('.')} VND';
  }

  String _formatDate(DateTime dateTime) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    final day = twoDigits(dateTime.day);
    final month = twoDigits(dateTime.month);
    final year = dateTime.year;
    final hour = twoDigits(dateTime.hour);
    final minute = twoDigits(dateTime.minute);
    return '$day/$month/$year - $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lich su don hang')),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.history_toggle_off,
                    size: 56,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 10),
                  const Text('Chua co don hang nao.'),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cart.orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final order = cart.orders[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Don hang #${order.id}',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8FFF4),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Da thanh toan',
                            style: TextStyle(
                              color: Color(0xFF0E9F6E),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Thoi gian: ${_formatDate(order.createdAt ?? DateTime.now())}'),
                    Text('So san pham: ${order.items?.length ?? 0}'),
                    const SizedBox(height: 8),
                    Text(
                      'Tong tien: ${_formatCurrency(order.totalPrice ?? 0.0)}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: const Color(0xFFFF6A00),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
