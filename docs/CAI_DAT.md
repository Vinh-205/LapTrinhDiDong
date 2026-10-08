# Hướng dẫn cài đặt

## 1 Chuẩn bị

- Git: https://git-scm.com/downloads
- Flutter SDK: https://docs.flutter.dev/install
- Android Studio: https://developer.android.com/studio
- Hướng dẫn Android chính thức: https://docs.flutter.dev/platform-integration/android/setup

Môi trường đã build: Windows, Flutter 3.47.4, Dart 3.13.3. Cài Flutter vào đường dẫn đơn giản, ví dụ `C:\src\flutter`, thêm `C:\src\flutter\bin` vào PATH rồi mở lại terminal. Android Studio cần plugin Flutter/Dart; cài plugin không thay cho cài SDK.

Trong SDK Manager cài Android SDK Platform, Build Tools, Platform Tools và Command-line Tools. Project dùng SDK do Flutter chọn; plugin có thể yêu cầu thêm Platform 35. Chấp nhận cài thành phần còn thiếu khi Gradle thông báo. Dùng Java đi kèm Android Studio và kiểm tra đường dẫn Java bằng `flutter doctor -v`.

```bash
git --version
flutter --version
flutter doctor -v
flutter doctor --android-licenses
```

Đọc và chấp nhận giấy phép được yêu cầu; sửa lỗi Android toolchain trước. Cảnh báo Visual Studio cho Windows desktop không chặn demo Android.

## 2 Clone project

Chạy trong thư mục bạn muốn lưu mã nguồn:

```bash
git clone https://github.com/Vinh-205/LapTrinhDiDong.git
cd LapTrinhDiDong
flutter pub get
```

Nếu đã clone, cập nhật bằng `git pull --ff-only` khi không có chỉnh sửa chưa lưu. Không cần GitHub token để clone repository công khai.

Mở thư mục `LapTrinhDiDong` chứa `pubspec.yaml` bằng Android Studio hoặc VS Code. Chọn Flutter SDK của máy hiện tại, không sao chép `android/local.properties` từ máy khác.

Đường dẫn trong Git Bash dùng dấu `/`, ví dụ:

```bash
cd /d/AndroidStudioProjects/LapTrinhDiDong
```

PowerShell dùng:

```powershell
cd D:\AndroidStudioProjects\LapTrinhDiDong
```

Đổi đường dẫn nếu bạn clone ở vị trí khác. Không cần tạo lại project bằng `flutter create`.

## 3 Chạy trên điện thoại Android thật

1. Bật Tùy chọn nhà phát triển trên điện thoại và bật USB debugging.
2. Cắm cáp có truyền dữ liệu, mở khóa và chấp nhận thông báo cho phép gỡ lỗi USB.
3. Với Xiaomi/Redmi, bật Install via USB nếu thiết bị yêu cầu; chấp nhận hộp thoại cài app.
4. Chạy `flutter devices`; tìm điện thoại có trạng thái kết nối, không chọn emulator nếu muốn sensor thật.
5. Thay ID thực vào lệnh sau, không gõ nguyên chữ `ANDROID_DEVICE_ID`:

```bash
flutter run -d ANDROID_DEVICE_ID
```

App tự build, cài và mở. Trong terminal Flutter, `r` hot reload, `R` hot restart, `q` kết thúc phiên chạy. Có thể dùng nút Run của Android Studio sau khi chọn điện thoại.

## 4 Chạy trên Android Emulator

Tạo Android Virtual Device bằng Android Studio → Device Manager → Create Device. Cài system image phù hợp máy tính rồi khởi động máy ảo.

```bash
flutter emulators
flutter emulators --launch EMULATOR_ID
flutter devices
flutter run -d emulator-5554
```

Thay `EMULATOR_ID` bằng ID từ lệnh đầu và thay `emulator-5554` nếu máy ảo dùng ID khác. Extended Controls → Virtual Sensors → Device Pose để đổi Pitch/Roll/Yaw. X/Y/Z sẽ đổi nhưng gia tốc tổng có thể vẫn gần 9,81, vì thế dùng TEST CẢNH BÁO để demo chuông ổn định.

## 5 Build và cài APK

```bash
flutter analyze
flutter test
flutter build apk --debug
```

Kết quả: `build/app/outputs/flutter-apk/app-debug.apk`. Có thể chép file này sang điện thoại và mở để cài; Android có thể yêu cầu cho phép ứng dụng quản lý file cài APK. Chỉ cấp cho nguồn file bạn đang dùng. APK debug phục vụ demo, chưa phải bản phát hành cửa hàng.

## 6 Lỗi thường gặp

| Hiện tượng | Cách xử lý |
| --- | --- |
| `flutter` không nhận lệnh | Thêm thư mục Flutter `bin` vào PATH và mở lại terminal |
| Dart SDK is not configured | Mở đúng thư mục có pubspec.yaml và cấu hình Flutter SDK trong IDE |
| SDK constraint không thỏa | Dùng Flutter kèm Dart đáp ứng `^3.13.3`; không tự hạ constraint |
| Chỉ thấy Windows/Chrome/emulator | Bật USB debugging, kiểm tra cáp dữ liệu và driver OEM Android trên Windows |
| `unauthorized` trong ADB | Mở khóa điện thoại, chấp nhận khóa RSA của máy tính |
| `INSTALL_FAILED_USER_RESTRICTED` | Cho phép Install via USB trên điện thoại và xác nhận hộp thoại cài đặt |
| Kotlin `different roots` ổ C và D | Project đã đặt `kotlin.incremental=false` trong android/gradle.properties |
| Thiếu SDK/license | Xem flutter doctor, SDK Manager và chấp nhận license theo hướng dẫn |
| Máy yên ~9,81 m/s² | Đây là gia tốc tổng gồm trọng lực, không phải mức chuyển động |
| Chuông vẫn reo khi đặt yên | Nhấn TẮT CẢNH BÁO; app giữ cảnh báo đến khi người dùng xác nhận |
| Không nghe chuông | Bật Âm thanh cảnh báo, tăng âm lượng media, kiểm tra thiết bị Bluetooth |

Nếu nghi cache build hỏng, thử `flutter clean`, `flutter pub get`, rồi build lại. Không tự đổi Gradle/Kotlin nếu chưa đọc nguyên nhân từ log. Không cần xóa toàn bộ cache trên máy.

## 7 Tài liệu độc lập

Tải `docs/HUONG_DAN_CAI_DAT.html`, mở bằng Edge/Chrome. File không cần mạng để đọc. Nhấn Ctrl+P và chọn Save as PDF để nộp bản PDF nếu giảng viên yêu cầu.

Tài liệu tham khảo: https://git-scm.com/docs/git-clone và https://developer.android.com/studio/run/device
