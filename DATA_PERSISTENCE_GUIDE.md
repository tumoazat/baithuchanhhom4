# 📱 Hướng dẫn Lưu Dữ Liệu Trên Firebase

## 🎯 Tổng Quan

Ứng dụng hiện tại tự động lưu **giỏ hàng** và **lịch sử mua hàng** lên Firebase Firestore. Khi tắt app, dữ liệu sẽ được giữ lại và tải lại khi mở app tiếp theo.

---

## 📊 Dữ Liệu Được Lưu

### 1. **Giỏ Hàng** (`carts` collection)
- **Nơi lưu**: Firestore `carts` collection
- **Document ID**: User ID
- **Dữ liệu**:
  ```json
  {
    "userId": "user-id-123",
    "items": [
      {
        "product": { "id", "name", "price", "image", "category" },
        "quantity": 2,
        "totalPrice": 100000
      }
    ],
    "total": 250000,
    "itemCount": 3,
    "updatedAt": "2026-03-19T10:30:00Z"
  }
  ```

### 2. **Lịch Sử Đơn Hàng** (`orders` collection)
- **Nơi lưu**: Firestore `orders` collection
- **Document ID**: Auto-generated
- **Dữ liệu**:
  ```json
  {
    "userId": "user-id-123",
    "items": [...],
    "totalPrice": 250000,
    "status": "pending",
    "createdAt": "2026-03-19T10:30:00Z",
    "deliveryAddress": "123 Đường ABC",
    "phoneNumber": "0912345678",
    "paymentMethod": "COD",
    "notes": "Giao vào sáng mai"
  }
  ```

---

## 🔄 Luồng Hoạt Động

### 1️⃣ **Đăng Nhập / Đăng Ký**
```
User → LoginScreen/SignupScreen
    ↓
AuthService.signInWithEmail() / signUpWithEmail()
    ↓
Firebase Authentication (tạo tài khoản)
    ↓
UserService.saveOrUpdateUser() (lưu profile)
    ↓
CartProvider.initializeWithUser(userId) (tải giỏ hàng cũ)
    ↓
HomeScreen (hiển thị sản phẩm + giỏ hàng cũ)
```

### 2️⃣ **Thêm Vào Giỏ**
```
User → Nhấn "Thêm vào giỏ"
    ↓
CartProvider.addProduct()
    ↓
_saveCartToFirebase() (lưu async)
    ↓
Firestore carts collection (cập nhật real-time)
```

### 3️⃣ **Thanh Toán**
```
User → Checkout
    ↓
CartProvider.checkout() (tạo Order)
    ↓
OrderService.createOrder() (lưu vào Firestore)
    ↓
CartService.clearCart() (xóa giỏ)
    ↓
OrderHistoryScreen (hiển thị đơn hàng mới)
```

### 4️⃣ **Tắt/Mở Lại App**
```
App tắt
    ↓
Người dùng mở app lại
    ↓
LoginScreen → _restoreSession()
    ↓
AuthService.isLoggedIn() (kiểm tra session)
    ↓
Nếu logged in → HomeScreen
    ↓
HomeScreen._initializeCart() → CartProvider.loadCartFromFirebase()
    ↓
Giỏ hàng cũ được hiển thị
```

### 5️⃣ **Đăng Xuất**
```
User → Logout
    ↓
AuthService.signOut() (xóa Firebase session)
    ↓
CartProvider.logout() (xóa dữ liệu local)
    ↓
LoginScreen
```

---

## 🛠️ Các Phương Thức Chính

### **CartProvider**

#### `initializeWithUser(String userId)`
- **Chức năng**: Khởi tạo CartProvider khi user đăng nhập
- **Tác vụ**: 
  - Tải giỏ hàng từ Firestore
  - Tải lịch sử đơn hàng
- **Gọi từ**: LoginScreen, SignupScreen, HomeScreen

```dart
final cartProvider = context.read<CartProvider>();
await cartProvider.initializeWithUser(userId);
```

#### `addProduct(Product product)`
- **Chức năng**: Thêm sản phẩm vào giỏ
- **Tác vụ**: 
  - Thêm vào memory (`_items`)
  - Gọi `_saveCartToFirebase()` (async, không chặn UI)

#### `removeProduct(String productId)`
- **Chức năng**: Xóa sản phẩm khỏi giỏ
- **Tác vụ**: 
  - Xóa từ memory
  - Lưu lên Firebase

#### `checkout()`
- **Chức năng**: Thanh toán (tạo đơn hàng)
- **Returns**: Order object hoặc null
- **Tác vụ**:
  - Tạo đơn hàng
  - Lưu vào `orders` collection
  - Xóa giỏ hàng
  - **Yêu cầu**: User phải đăng nhập

```dart
try {
  final order = await cartProvider.checkout();
  if (order != null) {
    // Thanh toán thành công
    Navigator.pushNamed(context, OrderHistoryScreen.routeName);
  }
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e.toString()))
  );
}
```

#### `loadCartFromFirebase()`
- **Chức năng**: Tải giỏ hàng từ Firestore
- **Được gọi**: Khi `initializeWithUser()` hoặc sau khi thanh toán

#### `loadOrdersFromFirebase()`
- **Chức năng**: Tải lịch sử đơn hàng từ Firestore
- **Được gọi**: Khi `initializeWithUser()`

#### `logout()`
- **Chức năng**: Xóa dữ liệu khi đăng xuất
- **Tác vụ**:
  - Xóa `_userId`
  - Xóa `_items` (giỏ hàng)
  - Xóa `_orders` (lịch sử)

---

## 🔐 Firestore Security Rules

Chỉ user có thể truy cập dữ liệu của chính mình:

### Giỏ Hàng (`carts`)
```firestore
match /carts/{document=**} {
  allow read, write: if request.auth.uid == resource.data.userId;
}
```

### Đơn Hàng (`orders`)
```firestore
match /orders/{document=**} {
  allow read, create: if request.auth.uid == resource.data.userId;
  allow update, delete: if isAdmin();
}
```

---

## ⚠️ Xử Lý Lỗi

### Lỗi Đăng Nhập
```dart
try {
  await _authService.signInWithEmail(email: email, password: password);
} catch (e) {
  // "Email này chưa được đăng ký."
  // "Mật khẩu không chính xác."
  // "Lỗi đăng nhập: ..."
  print('Lỗi: $e');
}
```

### Lỗi Tải Giỏ Hàng
```dart
try {
  await cartProvider.initializeWithUser(userId);
} catch (e) {
  print('❌ Lỗi tải dữ liệu từ Firebase: $e');
  // App sẽ hiển thị giỏ hàng trống, user vẫn có thể shopping
}
```

### Lỗi Thanh Toán
```dart
try {
  final order = await cartProvider.checkout();
} catch (e) {
  // "Vui lòng đăng nhập để thanh toán"
  // "Lỗi tạo đơn hàng: ..."
  print('Lỗi: $e');
}
```

---

## 📝 Logs Để Debug

Mở **Flutter DevTools** hoặc console để xem logs:

```
✅ Khởi tạo CartProvider với userId: user-123
📦 Tải giỏ hàng thành công: 3 sản phẩm
📜 Tải lịch sử đơn hàng thành công: 5 đơn hàng
💾 Giỏ hàng đã lưu lên Firebase
🗑️ Giỏ hàng đã xóa khỏi Firebase
✅ Đơn hàng đã tạo thành công: 1711612200000
🚪 Đã đăng xuất
```

---

## 🚀 Cách Sử Dụng

### 1. **Đăng Ký Tài Khoản Mới**
- Nhấn "Đăng ký" trên LoginScreen
- Nhập email + password
- Nhấn "Đăng Ký"
- ✅ Giỏ hàng sẽ được khởi tạo trống

### 2. **Thêm Sản Phẩm Vào Giỏ**
- Trên HomeScreen, nhấn icon "Thêm vào giỏ" trên sản phẩm
- Dữ liệu tự động lưu lên Firebase
- Kiểm tra badge số lượng trên icon giỏ hàng

### 3. **Xem Giỏ Hàng**
- Nhấn icon giỏ hàng (góc trên phải)
- Xem danh sách sản phẩm đã thêm
- Có thể xóa hoặc thay đổi số lượng

### 4. **Thanh Toán**
- Trên CartScreen, nhấn "Thanh toán"
- Kiểm tra thông tin đơn hàng
- Nhấn "Xác nhận thanh toán"
- ✅ Đơn hàng được lưu, giỏ hàng được xóa

### 5. **Xem Lịch Sử Mua Hàng**
- Nhấn icon lịch sử (hoặc menu)
- Xem tất cả đơn hàng đã tạo
- Dữ liệu được lưu vĩnh viễn trên Firebase

### 6. **Tắt Và Mở Lại App**
- Tắt app
- Mở app lại
- ✅ Nếu còn session, app tự động đăng nhập
- ✅ Giỏ hàng cũ được hiển thị
- ✅ Lịch sử mua hàng được hiển thị

---

## 🐛 Troubleshooting

| Vấn Đề | Nguyên Nhân | Giải Pháp |
|--------|-----------|----------|
| Giỏ hàng không được lưu | Không đăng nhập | Đăng nhập trước |
| Thanh toán thất bại | Không có internet | Kiểm tra kết nối |
| Dữ liệu không tải | Lỗi Firestore | Kiểm tra Security Rules |
| Dữ liệu bị mất | Xóa app cache | Xóa app, cài lại |
| Giỏ hàng trống | User mới | Bình thường, thêm sản phẩm |

---

## 📞 Liên Hệ Hỗ Trợ

Nếu có lỗi hoặc câu hỏi:
1. Kiểm tra console logs (F12 hoặc Dart DevTools)
2. Kiểm tra Firestore trong Firebase Console
3. Kiểm tra Security Rules
4. Kiểm tra internet connection

---

**Phiên bản**: 1.0  
**Cập nhật**: 19/03/2026  
**Trạng thái**: ✅ Hoạt động tốt
