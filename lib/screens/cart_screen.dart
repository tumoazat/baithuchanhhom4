import 'package:baibanhang/models/cart_item.dart';
import 'package:baibanhang/providers/cart_provider.dart';
import 'package:baibanhang/screens/checkout_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gio hang')),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          // Cart la diem giua luong du lieu: nhan item tu Detail va gui sang Checkout.
          if (cart.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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

          // Chuyen Map trong provider thanh list de render danh sach san pham.
          final items = cart.items.values.toList(growable: false);

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _CartItemRow(item: item);
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
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
                        const Text('Tong cong:'),
                        const Spacer(),
                        Text(
                          '${cart.totalAmount.toStringAsFixed(0)} VND',
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
                              // Sang Checkout voi du lieu hien tai van doc truc tiep tu CartProvider.
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
  const _CartItemRow({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    // read() dung de goi method tang/giam, khong can rebuild theo tung thay doi.
    final cart = context.read<CartProvider>();

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(item.product.name),
      subtitle: Text(
        '${item.product.price.toStringAsFixed(0)} VND x ${item.quantity} = ${item.totalPrice.toStringAsFixed(0)} VND',
      ),
      trailing: SizedBox(
        width: 130,
        child: Row(
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
      ),
    );
  }
}
