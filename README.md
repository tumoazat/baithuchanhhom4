# APP BÁN HÀNG (TH4)

Ứng dụng mini e-commerce viết bằng Flutter cho bài thực hành TH4. Dự án mô phỏng luồng mua hàng cơ bản gồm danh sách sản phẩm, giỏ hàng, checkout và lịch sử đơn hàng.

## Công nghệ sử dụng

- Flutter (Dart)
- Provider (state management)
- HTTP (gọi API sản phẩm/đơn hàng)
- SharedPreferences (lưu dữ liệu cục bộ)

## Cấu trúc thư mục chính

```text
lib/
 ┣ models/
 ┣ providers/
 ┣ services/
 ┣ screens/
 ┣ widgets/
 ┗ main.dart
```

## Mô hình dùng chung trong nhóm

- Product: `lib/models/product.dart` – class `Product`
- CartItem: `lib/models/cart_item.dart` – class `CartItem`
- Order: `lib/models/order.dart` – class `Order`

## Các màn hình chính

- HomeScreen: `lib/screens/home_screen.dart`
- ProductDetailScreen: `lib/screens/product_detail_screen.dart`
- CartScreen: `lib/screens/cart_screen.dart`
- CheckoutScreen: `lib/screens/checkout_screen.dart`
- OrderHistoryScreen: `lib/screens/order_history_screen.dart`

## Hướng dẫn chạy app

1. Cài Flutter SDK và cấu hình môi trường.
2. Mở project:
	```bash
	cd app_ban_hang
	```
3. Cài dependencies:
	```bash
	flutter pub get
	```
4. Chạy ứng dụng:
	```bash
	flutter run
	```

## Phân công công việc (5 người)

- Người 1: Product model + ProductService + HomeScreen.
- Người 2: ProductDetailScreen + logic thêm vào giỏ.
- Người 3: CartItem model + CartProvider + CartScreen.
- Người 4: Tích hợp dữ liệu cục bộ/API, hoàn thiện điều hướng.
- Người 5: CheckoutScreen + OrderHistoryScreen + tài liệu README.

## Trạng thái hiện tại

- Checkout và Order History đang dùng mock data để phát triển độc lập.
- Bước tiếp theo: nối dữ liệu thật từ CartProvider, Product và luồng tạo đơn hàng.
