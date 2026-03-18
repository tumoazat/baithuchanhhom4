import 'package:baibanhang/models/cart_item.dart';
import 'package:baibanhang/providers/cart_provider.dart';
import 'package:baibanhang/screens/checkout_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static const routeName = '/cart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gio hang cua ban')),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 56,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 12),
                  const Text('Gio hang dang trong.'),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Quay lai mua hang'),
                  ),
                ],
              ),
            );
          }

          final items = cart.items.values.toList(growable: false);

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _CartItemRow(item: item, formatCurrency: _formatCurrency);
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Tong cong:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Text(
                          _formatCurrency(cart.totalAmount),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: cart.clearCart,
                            child: const Text('Xoa gio hang'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                CheckoutScreen.routeName,
                              );
                            },
                            child: const Text('Thanh toan'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  const _CartItemRow({required this.item, required this.formatCurrency});

  final CartItem item;
  final String Function(double) formatCurrency;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: const Icon(Icons.shopping_bag_outlined),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${formatCurrency(item.product.price)} x ${item.quantity}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  formatCurrency(item.totalPrice),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: const Color(0xFFFF6A00),
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => cart.decreaseQuantity(item.product.id),
                icon: const Icon(Icons.remove_circle_outline),
                tooltip: 'Giam',
              ),
              Text(item.quantity.toString()),
              IconButton(
                onPressed: () => cart.addProduct(item.product),
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Tang',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
