import 'package:flutter/material.dart';
import 'package:app_ban_hang/models/order.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late final List<Order> _orders;

  @override
  void initState() {
    super.initState();
    _orders = _mockOrders();
  }

  List<Order> _mockOrders() {
    return [
      Order(
        id: 'OD1001',
        items: const [],
        totalAmount: 320000,
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        address: 'Hà Nội',
      ),
      Order(
        id: 'OD1002',
        items: const [],
        totalAmount: 540000,
        status: 'shipping',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        address: 'TP.HCM',
      ),
      Order(
        id: 'OD1003',
        items: const [],
        totalAmount: 280000,
        status: 'completed',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        address: 'Đà Nẵng',
      ),
      Order(
        id: 'OD1004',
        items: const [],
        totalAmount: 150000,
        status: 'canceled',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        address: 'Cần Thơ',
      ),
    ];
  }

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  List<Order> _ordersByStatus(String status) {
    return _orders.where((order) => order.status == status).toList();
  }

  Widget _buildOrderList(String status) {
    final filteredOrders = _ordersByStatus(status);

    if (filteredOrders.isEmpty) {
      return const Center(child: Text('Chưa có đơn hàng'));
    }

    return ListView.builder(
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: ListTile(
            title: Text('Mã đơn: ${order.id}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Số lượng sản phẩm: ${order.items.length}'),
                Text('Tổng tiền: ${order.totalAmount.toStringAsFixed(0)} đ'),
                Text('Ngày tạo: ${_formatDate(order.createdAt)}'),
                Text('Trạng thái: ${order.status}'),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lịch sử đơn hàng'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Chờ xác nhận'),
              Tab(text: 'Đang giao'),
              Tab(text: 'Đã giao'),
              Tab(text: 'Đã hủy'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrderList('pending'),
            _buildOrderList('shipping'),
            _buildOrderList('completed'),
            _buildOrderList('canceled'),
          ],
        ),
      ),
    );
  }
}
