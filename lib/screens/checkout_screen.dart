import 'package:baibanhang/providers/cart_provider.dart';
import 'package:baibanhang/screens/order_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  static const routeName = '/checkout';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          // Checkout tiep tuc doc gio hang truc tiep tu CartProvider (khong truyen tay).
          if (cart.isEmpty) {
            return const Center(
              child: Text('Khong co san pham nao de thanh toan.'),
            );
          }

          final items = cart.items.values.toList(growable: false);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.product.name),
                        subtitle: Text('So luong: ${item.quantity}'),
                        trailing: Text(
                          '${item.totalPrice.toStringAsFixed(0)} VND',
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                Row(
                  children: [
                    const Text('Tong thanh toan:'),
                    const Spacer(),
                    Text(
                      '${cart.totalAmount.toStringAsFixed(0)} VND',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      // checkout() vua tao order vua clear gio hang.
                      final order = context.read<CartProvider>().checkout();
                      if (order == null) {
                        return;
                      }
                      // Order moi duoc luu vao CartProvider.orders de OrderHistory hien thi.

                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(content: Text('Dat hang thanh cong')),
                        );

                      // Dung pushReplacement de tranh quay lai man checkout rong.
                      Navigator.pushReplacementNamed(
                        context,
                        OrderHistoryScreen.routeName,
                      );
                    },
                    child: const Text('Xac nhan dat hang'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
