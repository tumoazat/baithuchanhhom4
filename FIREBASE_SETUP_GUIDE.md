## Firebase Google Sign-In Setup Guide

### ⚠️ Lỗi: `FirebaseAuthHostApi.signInWithCredential`

Lỗi này xảy ra khi Google Sign-In không được cấu hình đúng. Hãy làm theo các bước sau:

---

## 🔧 Cách khắc phục

### 1️⃣ **Kiểm tra Firebase Console cấu hình**

1. Truy cập [Firebase Console](https://console.firebase.google.com)
2. Chọn project của bạn
3. Vào **Authentication** → **Sign-in method**
4. Bật **Google** provider
5. Chọn **Support email** (public project email)
6. **Save** thay đổi

### 2️⃣ **Lấy SHA-1 Fingerprint cho debug.keystore**

Chạy lệnh này trong PowerShell:
```powershell
keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

Sao chép **SHA1** fingerprint

### 3️⃣ **Thêm SHA-1 vào Firebase Console**

1. Firebase Console → Project Settings
2. Chọn tab **Users and permissions** hoặc **General**
3. Cuộn xuống **Your apps** → chọn Android app
4. Click **Add fingerprint**
5. Dán SHA-1 fingerprint
6. **Save** thay đổi

### 4️⃣ **Cấu hình OAuth Consent Screen (quan trọng!)**

1. Vào [Google Cloud Console](https://console.cloud.google.com)
2. Chọn project Firebase của bạn
3. Vào **APIs & Services** → **OAuth consent screen**
4. Chọn **External** user type
5. Điền form:
   - App name: `Baibanhang` (hoặc tên app của bạn)
   - User support email: Gmail của bạn
   - Thêm scopes: `email`, `profile`, `openid`
6. **Save and Continue**
7. Thêm test users (Gmail của bạn)
8. **Save and Continue**

### 5️⃣ **Kiểm tra google-services.json**

File này phải có trong: `android/app/google-services.json`

Nội dung cần có:
```json
{
  "project_info": {
    "project_id": "your-project-id",
    ...
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "...",
        "android_client_info": {
          "package_name": "com.example.app_ban_hang"
        }
      },
      ...
    }
  ]
}
```

### 6️⃣ **Xóa build cache và chạy lại**

```bash
flutter clean
flutter pub get
flutter run
```

---

## ✅ Test Google Sign-In

Sau khi cấu hình xong:

1. Chạy app: `flutter run`
2. Nhấn nút "Sign in with Google"
3. Chọn Gmail account (phải là test user)
4. Kiểm tra logs trong Flutter console để xem:
   - `🔵 Dang nhap Google thanh cong`
   - `🔑 Lay token Google thanh cong`
   - `🔐 Tao credential Firebase`
   - `✅ Dang nhap Firebase thanh cong`

---

## 🐛 Troubleshooting

### **Error: `operation-not-allowed`**
→ Google Sign-In chưa được bật trong Firebase Console

### **Error: `invalid-credential`**  
→ SHA-1 fingerprint không khớp hoặc chưa thêm vào Firebase

### **Error: Token vô hiệu hoặc hết hạn**
→ Xóa app data: `adb shell pm clear com.example.app_ban_hang`
→ Hoặc gỡ và cài lại app

### **Error: `CONFIGURATION_PROBLEM`**
→ File `google-services.json` không hợp lệ
→ Tải lại từ Firebase Console

---

## 📝 Checklist

- [ ] Google Sign-In enabled trong Firebase Console
- [ ] SHA-1 fingerprint được thêm vào Firebase
- [ ] OAuth consent screen được cấu hình
- [ ] Test user Gmail được thêm
- [ ] google-services.json đúng vị trí
- [ ] build.gradle.kts có Google Services plugin
- [ ] Chạy `flutter clean` trước khi test
- [ ] Logs cho thấy các bước 🔵🔑🔐✅

---

## 📞 Hỗ trợ

Nếu vẫn gặp lỗi, kiểm tra:
1. Email trong Firebase OAuth consent screen có là test user không?
2. SHA-1 fingerprint có khớp với debug keystore không?
3. google-services.json có từ đúng project Firebase không?
4. Mạng internet ổn định không?

---

**Được tạo:** 2026-03-19
**Version:** 1.0
