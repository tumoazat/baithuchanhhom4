# 🧪 Hướng Dẫn Test Tính Năng Lưu Dữ Liệu Firebase

## 📋 Các Test Case

### Test 1: Đăng Ký Tài Khoản Mới
**Mục đích**: Kiểm tra giỏ hàng được khởi tạo khi đăng ký

**Bước**:
1. Mở app
2. Nhấn "Đăng ký"
3. Nhập email (ví dụ: `test@gmail.com`)
4. Nhập password: `123456`
5. Xác nhận password: `123456`
6. Nhấn "Đăng Ký"

**Kết quả mong đợi**:
- ✅ Chuyển sang HomeScreen
- ✅ Giỏ hàng trống (badge = 0)
- ✅ Trong console logs: `✅ Giỏ hàng được khởi tạo sau đăng ký: user-id`

**Kiểm tra Firestore**:
- ✅ Collection `users` có document mới với `uid`, `email`, `createdAt`
- ✅ Collection `carts` chưa có document (vì chưa thêm sản phẩm)

---

### Test 2: Thêm Sản Phẩm Vào Giỏ
**Mục đích**: Kiểm tra giỏ hàng tự động lưu lên Firebase

**Bước**:
1. Từ HomeScreen, tìm sản phẩm bất kỳ
2. Nhấn icon "Thêm vào giỏ"
3. Kiểm tra badge trên icon giỏ hàng (nên là 1)
4. Thêm 1-2 sản phẩm nữa

**Kết quả mong đợi**:
- ✅ Badge hiển thị số lượng sản phẩm (1, 2, 3,...)
- ✅ Trong console logs: `💾 Giỏ hàng đã lưu lên Firebase`

**Kiểm tra Firestore**:
- ✅ Collection `carts` → Document `[userId]`
- ✅ Document có field `items`, `total`, `itemCount`, `updatedAt`

---

### Test 3: Xóa Sản Phẩm Khỏi Giỏ
**Mục đích**: Kiểm tra xóa sản phẩm được lưu

**Bước**:
1. Từ HomeScreen, nhấn icon giỏ hàng
2. Nhấn "X" để xóa một sản phẩm
3. Kiểm tra badge (nên giảm 1)
4. Quay lại HomeScreen

**Kết quả mong đợi**:
- ✅ Badge cập nhật đúng số lượng
- ✅ Trong console logs: `💾 Giỏ hàng đã lưu lên Firebase`

**Kiểm tra Firestore**:
- ✅ Document `carts/[userId]` được cập nhật
- ✅ `itemCount` giảm đi
- ✅ `updatedAt` là timestamp mới

---

### Test 4: Thanh Toán (Tạo Đơn Hàng)
**Mục đích**: Kiểm tra đơn hàng được lưu và giỏ hàng được xóa

**Bước**:
1. Từ HomeScreen, thêm 2-3 sản phẩm vào giỏ
2. Nhấn icon giỏ hàng
3. Nhấn "Thanh toán"
4. Kiểm tra thông tin (tổng tiền, số lượng sản phẩm)
5. Nhấn "Xác nhận thanh toán"

**Kết quả mong đợi**:
- ✅ Badge giỏ hàng trở về 0
- ✅ Chuyển sang OrderHistoryScreen
- ✅ Hiển thị đơn hàng vừa tạo (status: pending)
- ✅ Trong console logs: `✅ Đơn hàng đã tạo thành công: [order-id]`

**Kiểm tra Firestore**:
- ✅ Collection `orders` có document mới với `userId`, `items`, `totalPrice`, `status`
- ✅ Collection `carts/[userId]` được xóa hoặc không có `items`

---

### Test 5: Xem Lịch Sử Đơn Hàng
**Mục đích**: Kiểm tra lịch sử được tải từ Firebase

**Bước**:
1. Từ HomeScreen, nhấn icon lịch sử (hoặc menu)
2. Xem danh sách đơn hàng

**Kết quả mong đợi**:
- ✅ Hiển thị tất cả các đơn hàng đã tạo
- ✅ Thứ tự từ mới nhất đến cũ nhất
- ✅ Mỗi đơn hàng hiển thị: `[ngày] - [tổng tiền] - [trạng thái]`

**Kiểm tra Firestore**:
- ✅ Collection `orders` có tất cả các document
- ✅ Mỗi document có `userId` = user hiện tại

---

### Test 6: Tắt App Và Mở Lại
**Mục đích**: Kiểm tra dữ liệu được giữ lại

**Bước**:
1. Đăng nhập với tài khoản đã có giỏ hàng
2. Thêm 1 sản phẩm vào giỏ (badge = 1)
3. **Tắt app hoàn toàn** (không chỉ minimize)
4. Mở app lại

**Kết quả mong đợi**:
- ✅ App tự động đăng nhập (không cần nhập email/password)
- ✅ HomeScreen hiển thị
- ✅ Badge giỏ hàng vẫn là 1
- ✅ Giỏ hàng vẫn chứa sản phẩm đã thêm
- ✅ Lịch sử đơn hàng vẫn hiển thị
- ✅ Trong console logs:
  ```
  ✅ Khởi tạo CartProvider với userId: [id]
  📦 Tải giỏ hàng thành công: 1 sản phẩm
  📜 Tải lịch sử đơn hàng thành công: [số] đơn hàng
  ```

---

### Test 7: Đăng Xuất
**Mục đích**: Kiểm tra dữ liệu được xóa khi đăng xuất

**Bước**:
1. Từ HomeScreen, nhấn menu
2. Nhấn "Đăng xuất"
3. Kiểm tra màn hình quay về LoginScreen

**Kết quả mong đợi**:
- ✅ Chuyển sang LoginScreen
- ✅ Tất cả dữ liệu local bị xóa
- ✅ Trong console logs: `🚪 Đã đăng xuất`

---

### Test 8: Đăng Nhập Với Tài Khoản Cũ
**Mục đích**: Kiểm tra giỏ hàng cũ được tải

**Bước**:
1. Từ LoginScreen, nhập email + password của tài khoản cũ
2. Nhấn "Dang nhap Email"
3. Chờ tải dữ liệu

**Kết quả mong đợi**:
- ✅ HomeScreen hiển thị
- ✅ Badge giỏ hàng hiển thị đúng số lượng sản phẩm cũ
- ✅ Giỏ hàng chứa tất cả sản phẩm đã thêm trước đó
- ✅ Lịch sử đơn hàng hiển thị tất cả các đơn hàng cũ
- ✅ Trong console logs:
  ```
  ✅ Khởi tạo CartProvider với userId: [id]
  📦 Tải giỏ hàng thành công: [số] sản phẩm
  📜 Tải lịch sử đơn hàng thành công: [số] đơn hàng
  ```

---

### Test 9: Thay Đổi Số Lượng Sản Phẩm
**Mục đích**: Kiểm tra cập nhật số lượng được lưu

**Bước**:
1. Từ CartScreen, nhấn "+" hoặc "-" để thay đổi số lượng
2. Kiểm tra tổng tiền cập nhật
3. Quay lại HomeScreen

**Kết quả mong đợi**:
- ✅ Tổng tiền cập nhật đúng
- ✅ Badge giỏ hàng cập nhật
- ✅ Trong console logs: `💾 Giỏ hàng đã lưu lên Firebase`

**Kiểm tra Firestore**:
- ✅ Document `carts/[userId]` → `items[].quantity` được cập nhật

---

### Test 10: Kiểm Tra Security Rules
**Mục đích**: Đảm bảo chỉ user có thể truy cập dữ liệu của mình

**Bước**:
1. Đăng nhập 2 tài khoản khác nhau
2. Kiểm tra trong Firestore Console
3. Cố gắng cập nhật dữ liệu của user khác (nếu có công cụ)

**Kết quả mong đợi**:
- ✅ Mỗi user chỉ thấy dữ liệu của mình
- ✅ Không thể truy cập dữ liệu user khác
- ✅ Firestore rules deny các request không hợp lệ

---

## 🔍 Debug Checklist

- [ ] Kiểm tra Firebase project ID trong `google-services.json`
- [ ] Kiểm tra Firestore Security Rules hợp lệ
- [ ] Kiểm tra internet connection
- [ ] Kiểm tra console logs để xem các lỗi
- [ ] Kiểm tra Firestore database có tồn tại
- [ ] Kiểm tra user được tạo trong Firebase Authentication
- [ ] Kiểm tra document carts/[userId] trong Firestore
- [ ] Kiểm tra document orders trong Firestore

---

## 🚀 Lệnh Test Nhanh

### Run app với logs
```bash
flutter run -v
```

### Xem logs chỉ từ app (bỏ qua logs Flutter framework)
```bash
flutter run 2>&1 | findstr "✅\|❌\|💾\|📦\|📜\|🚪"
```

### Clean build
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📊 Firestore Collections Structure

### `carts` Collection
```
carts/
├── [userId-1]/
│   ├── userId: "user-1"
│   ├── items: [
│   │   {
│   │     "product": { "id", "name", "price", ... },
│   │     "quantity": 2,
│   │     "totalPrice": 200000
│   │   }
│   │ ]
│   ├── total: 200000
│   ├── itemCount: 1
│   └── updatedAt: (timestamp)
└── [userId-2]/
    └── ...
```

### `orders` Collection
```
orders/
├── [orderId-1]/
│   ├── userId: "user-1"
│   ├── items: [...]
│   ├── totalPrice: 500000
│   ├── status: "pending"
│   ├── createdAt: (timestamp)
│   ├── deliveryAddress: "123 ABC Street"
│   ├── phoneNumber: "0912345678"
│   ├── paymentMethod: "COD"
│   └── notes: ""
└── [orderId-2]/
    └── ...
```

---

## 💡 Mẹo

1. **Cần reset app**: Xóa app data trong Settings → Apps → [App Name] → Storage → Clear Data
2. **Xem Firestore**: Vào Firebase Console → Firestore Database → Data
3. **Xem logs**: Bật Flutter DevTools (F5 trong VS Code)
4. **Test offline**: Tắt internet để kiểm tra local data vẫn hiển thị
5. **Kiểm tra timestamps**: Firestore timestamps tính bằng milliseconds

---

**Tạo ngày**: 19/03/2026  
**Trạng thái**: ✅ Sẵn sàng test
