import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giỏ hàng')),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.itemCount == 0) {
            return const Center(child: Text('Giỏ hàng trống'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return Dismissible(
                      key: ValueKey(item.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.redAccent,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => cart.removeItem(item.id),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: item.isChecked,
                                  onChanged: (_) => cart.toggleCheck(item.id),
                                ),
                                SizedBox(
                                  width: 64,
                                  height: 64,
                                  child: Image.network(
                                    item.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stack) =>
                                        const Icon(
                                          Icons.broken_image,
                                          size: 40,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text('Size: ${item.selectedSize}'),
                                      Text('Color: ${item.selectedColor}'),
                                      const SizedBox(height: 4),
                                      Text(
                                        '₫${item.price.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                      onPressed: () =>
                                          cart.increaseQuantity(item.id),
                                    ),
                                    Text(item.quantity.toString()),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                      onPressed: () {
                                        if (item.quantity <= 1) {
                                          showDialog<void>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text('Xóa sản phẩm'),
                                              content: const Text(
                                                'Bạn có muốn xoá sản phẩm này khỏi giỏ hàng?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(ctx).pop(),
                                                  child: const Text('Hủy'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    cart.removeItem(item.id);
                                                    Navigator.of(ctx).pop();
                                                  },
                                                  child: const Text('Xóa'),
                                                ),
                                              ],
                                            ),
                                          );
                                          return;
                                        }
                                        cart.decreaseQuantity(item.id);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              _CartBottomBar(),
            ],
          );
        },
      ),
    );
  }
}

class _CartBottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: cart.isAllSelected,
            onChanged: (value) {
              if (value != null) {
                cart.toggleCheckAll(value);
              }
            },
          ),
          const Text('Chọn tất cả'),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Tổng: ₫${cart.totalSelectedPrice.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('(${cart.totalSelectedQuantity} món)'),
            ],
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: cart.totalSelectedQuantity == 0
                ? null
                : () {
                    // Thực hiện mua hàng (demo).
                    debugPrint('Checkout: total=${cart.totalSelectedPrice}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã gửi đơn hàng (demo)')),
                    );
                  },
            child: const Text('Mua hàng'),
          ),
        ],
      ),
    );
  }
}
