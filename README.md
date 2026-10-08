# Cảnh báo chống trộm bằng cảm biến chuyển động

Ứng dụng Flutter demo Accelerometer cho môn **Lập trình trên thiết bị di động**. Đọc cảm biến thật trên Android, phát hiện rung/lắc vượt ngưỡng và phát chuông cảnh báo. Đây là bài thực hành cảm biến, không phải hệ thống chống trộm chuyên nghiệp.

## Tài liệu

- [Hướng dẫn cài đặt và chạy](docs/CAI_DAT.md)
- [Tài liệu độc lập để tải về và in](docs/HUONG_DAN_CAI_DAT.html) — tải file HTML rồi mở bằng trình duyệt; Ctrl+P để in hoặc lưu PDF.
- [Đối chiếu yêu cầu và kịch bản demo 15–20 phút](docs/DEMO_CHECKLIST.md)

## Chạy nhanh

Cài Git, Flutter SDK và Android Studio trước. Môi trường đã dùng: **Flutter 3.47.4 / Dart 3.13.3**, Windows, Android thật và emulator. `pubspec.yaml` yêu cầu Dart `^3.13.3`; dùng Flutter tương ứng, không hạ SDK constraint để né lỗi.

```bash
git clone https://github.com/Vinh-205/LapTrinhDiDong.git
cd LapTrinhDiDong
flutter pub get
flutter devices
```

Lấy ID Android trong danh sách, thay `ANDROID_DEVICE_ID` ở lệnh sau bằng ID thực:

```bash
flutter run -d ANDROID_DEVICE_ID
```

Trong Android Studio, mở **thư mục LapTrinhDiDong có pubspec.yaml**, chọn thiết bị rồi Run. Không mở riêng thư mục cha hoặc thư mục `android` để chạy Flutter.

## Chức năng chính và liên quan

| Nhóm | Chức năng |
| --- | --- |
| Cảm biến chính | `accelerometerEventStream()`, X/Y/Z realtime, gia tốc tổng |
| Phát hiện | Bật/tắt bảo vệ, 3 giây chuẩn bị, vượt ngưỡng kích hoạt ngay |
| Cảnh báo | UI đổi màu, chuông lặp, TẮT CẢNH BÁO, TẮT BẢO VỆ |
| Demo | TEST CẢNH BÁO dùng chung hàm với cảm biến, bộ đếm chống lặp |
| Lịch sử | Sự kiện sensor, TEST, bật/tắt bảo vệ, tắt chuông trong RAM |
| Cài đặt | Ba độ nhạy, bật/tắt âm thanh, reset bộ đếm |
| Âm thanh | Còi báo động, Chuông ngân, Bíp nhịp nhanh, nghe thử 2 giây |
| Điều hướng | Ba nút nổi trên nền kính mờ; animation trượt và vuốt đổi tab |

## Cách hoạt động

```dart
magnitude = sqrt(x * x + y * y + z * z);
movement = (magnitude - 9.81).abs();
```

**Gia tốc tổng** gồm trọng lực; máy yên thường khoảng 9,81 m/s². **Mức chuyển động** hiển thị độ lệch khỏi trọng lực, gần 0 khi máy yên; đây không phải vận tốc hay vector gia tốc tuyến tính đầy đủ.

Phát hiện dùng **gia tốc tổng**, không so mức chuyển động đã trừ trọng lực với ngưỡng:

| Độ nhạy | Gia tốc tổng kích hoạt |
| --- | --- |
| Thấp | > 18 m/s² |
| Trung bình mặc định | > 15 m/s² |
| Cao | > 12 m/s² |

Sau 3 giây chuẩn bị, một mẫu vượt ngưỡng có thể kích hoạt. Khi chuông đang bật, không tăng bộ đếm lần nữa. Sau tắt cảnh báo có cooldown 2 giây và cần mẫu dưới ngưỡng ít nhất 1 m/s² để nhận lần rung mới. Chuông không tự tắt khi máy nằm yên lại. TEST có thể chạy khi chưa bật bảo vệ và bỏ qua thời gian chuẩn bị/cooldown.

## Kiểm tra và tạo APK

```bash
flutter analyze
flutter test
flutter build apk --debug
```

APK tạo tại `build/app/outputs/flutter-apk/app-debug.apk`, không đưa build/cache vào Git. Bản debug dành cho demo; chưa thiết lập ký phát hành lên cửa hàng.

## Cấu trúc

```text
lib/
  main.dart             # Theme, điều hướng nổi, PageView
  alarm_state.dart      # Sensor, logic bảo vệ, audio, state dùng chung
  home_screen.dart      # Trạng thái, số đo, nút điều khiển
  history_screen.dart   # Lịch sử phiên chạy
  settings_screen.dart  # Độ nhạy, chọn chuông, nghe thử, reset
assets/                 # Ba âm WAV tự tạo, dùng offline
test/widget_test.dart   # Bốn bài test logic và giao diện
docs/                   # Hướng dẫn và checklist trình bày
```

Package: `sensors_plus ^7.1.1`, `audioplayers ^6.8.1`. Không database, backend, đăng nhập hoặc state management package nặng.

## Phạm vi và giới hạn

- Chỉ bảo đảm phạm vi demo khi app đang mở; không có foreground service bảo vệ khi khóa màn hình/chạy nền.
- X/Y/Z dùng sensor vật lý trên điện thoại; emulator cấp sensor mô phỏng. TEST không thay số đo sensor.
- Chỉ nghiêng/xoay hoặc di chuyển chậm có thể không làm gia tốc tổng vượt ngưỡng.
- Một xung do chạm/va đập đủ lớn cũng có thể kích hoạt. Ngưỡng chỉ phục vụ thử nghiệm.
- Lịch sử, bộ đếm, lựa chọn chuông và cài đặt chỉ trong RAM, không lưu sau khi khởi động lại app.
- Âm thanh phụ thuộc âm lượng media của thiết bị.
- Android là nền tảng đã kiểm tra. Thư mục các nền tảng khác là scaffold Flutter, chưa xác nhận hoạt động.

## Kết quả và phần cần chuẩn bị

Đã kiểm tra trong phiên phát triển: analyze, bốn test, build debug, chạy emulator Pixel 7 Android 17 và cài/chạy trên Redmi Note 13 Pro 5G Android 14. Cần diễn tập lại rung/lắc trên điện thoại thật trước buổi học để chọn độ nhạy phù hợp.

**Đủ chức năng cho phần demo chính và liên quan.** Để hoàn tất toàn bộ yêu cầu thuyết trình, nhóm vẫn cần slide giới thiệu công nghệ, phân công người trình bày và diễn tập 15–20 phút. Xem checklist trong `docs`.
