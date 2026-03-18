import 'package:flutter/material.dart';
import 'package:app_ban_hang/models/cart_item.dart';
import 'package:app_ban_hang/models/order.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> selectedItems;

  const CheckoutScreen({
    super.key,
    required this.selectedItems,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _receiverNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String _paymentMethod = 'COD';

  @override
  void dispose() {
    _receiverNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String _itemName(CartItem item) {
    final dynamic rawItem = item;
    if (rawItem.product?.name != null) return rawItem.product.name.toString();
    if (rawItem.name != null) return rawItem.name.toString();
    return 'Sản phẩm';
  }

  int _itemQuantity(CartItem item) {
    final dynamic rawItem = item;
    final qty = rawItem.quantity;
    if (qty is num) return qty.toInt();
    return 1;
  }

  double _itemPrice(CartItem item) {
    final dynamic rawItem = item;
    final totalPrice = rawItem.totalPrice;
    if (totalPrice is num) return totalPrice.toDouble();

    final unitPrice = rawItem.price ?? rawItem.product?.price;
    if (unitPrice is num) {
      return unitPrice.toDouble() * _itemQuantity(item);
    }
    return 0;
  }

  double get _totalAmount {
    return widget.selectedItems.fold(0, (sum, item) => sum + _itemPrice(item));
  }

  void _placeOrder() {
    if (!_formKey.currentState!.validate()) return;

    final mockOrder = Order(
      id: 'OD${DateTime.now().millisecondsSinceEpoch}',
      items: widget.selectedItems,
      totalAmount: _totalAmount,
      status: 'pending',
      createdAt: DateTime.now(),
      address: _addressController.text.trim(),
    );

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thành công'),
        content: Text(
          'Đặt hàng thành công (mock)\nMã đơn: ${mockOrder.id}\n'
          'Người nhận: ${_receiverNameController.text.trim()}\n'
          'SĐT: ${_phoneController.text.trim()}\n'
          'Thanh toán: $_paymentMethod',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đặt hàng thành công (mock)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      body: widget.selectedItems.isEmpty
          ? const Center(child: Text('Chưa có sản phẩm được chọn'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sản phẩm đang thanh toán',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ...widget.selectedItems.map(
                    (item) => Card(
                      child: ListTile(
                        title: Text(_itemName(item)),
                        subtitle: Text('Số lượng: ${_itemQuantity(item)}'),
                        trailing: Text('${_itemPrice(item).toStringAsFixed(0)} đ'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tổng tiền: ${_totalAmount.toStringAsFixed(0)} đ',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _receiverNameController,
                          decoration: const InputDecoration(
                            labelText: 'Tên người nhận',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                                  ? 'Vui lòng nhập tên người nhận'
                                  : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Số điện thoại',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                                  ? 'Vui lòng nhập số điện thoại'
                                  : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: 'Địa chỉ nhận hàng',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                                  ? 'Vui lòng nhập địa chỉ'
                                  : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _paymentMethod,
                          decoration: const InputDecoration(
                            labelText: 'Phương thức thanh toán',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'COD',
                              child: Text('COD'),
                            ),
                            DropdownMenuItem(
                              value: 'Momo',
                              child: Text('Momo'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _paymentMethod = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _placeOrder,
                            child: const Text('Đặt hàng'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
