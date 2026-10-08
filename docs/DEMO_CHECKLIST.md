# Đối chiếu yêu cầu và kịch bản demo

## Kết luận

Phần ứng dụng đủ chức năng chính và liên quan trong phạm vi demo Accelerometer. Không cần bổ sung đăng nhập, GPS, SMS, backend hoặc AI. Việc đáp ứng rubric cuối cùng do giảng viên đánh giá; bảng dưới chỉ đối chiếu những nội dung cụ thể trong ảnh yêu cầu.

| Yêu cầu | Hiện trạng | Cách chứng minh |
| --- | --- | --- |
| Demo công nghệ chính | Có Accelerometer thật và công thức magnitude | Nghiêng máy, xem X/Y/Z, giải thích trọng lực |
| Demo chức năng chính | Có bật bảo vệ, phát hiện, chuông và tắt chuông | Chờ 3 giây rồi rung tay; UI đổi màu, đếm tăng |
| Chức năng liên quan | Có lịch sử, độ nhạy, reset, ba chuông, nghe thử | Chuyển tab, chọn âm, TEST lại |
| Tài liệu git và document | README, CAI_DAT.md và HTML độc lập | Clone repository, chạy theo hướng dẫn |
| Slide giới thiệu công nghệ | Chưa có trong repository | Nhóm cần chuẩn bị slide riêng |
| Thời lượng 15–20 phút | Có kịch bản gợi ý, chưa xác nhận diễn tập | Nhóm tự bấm giờ và phân công |
| Thành viên tham gia | Không thể xác minh qua source code | Nhóm bảo đảm có mặt và tham gia theo yêu cầu lớp |

## Kịch bản 17 phút

- 0–2 phút: đề tài, bài toán đặt điện thoại và mục tiêu demo cảm biến.
- 2–5 phút: Flutter, sensors_plus, accelerometer X/Y/Z, công thức magnitude; giải thích vì sao máy yên ~9,81 m/s².
- 5–7 phút: cấu trúc 5 file Dart, ChangeNotifier chia sẻ state, subscription và dispose.
- 7–12 phút: demo cảm biến thật, bảo vệ, chuông, tắt, lịch sử, chống đếm lặp.
- 12–14 phút: độ nhạy, chọn chuông, nghe thử, TEST và reset bộ đếm.
- 14–16 phút: clone Git, cách cài/chạy, giới thiệu tài liệu, kết quả kiểm tra.
- 16–17 phút: giới hạn và kết luận; còn khoảng dự phòng cho câu hỏi tùy thời lượng lớp.

## Checklist demo trực tiếp

1. Mở app, giữ máy yên: trạng thái CHƯA BẬT BẢO VỆ; gia tốc tổng gần 9,81 và mức chuyển động gần 0.
2. Nghiêng/xoay máy: chỉ rõ X/Y/Z thay đổi. Không khẳng định chỉ nghiêng là chuông sẽ reo.
3. Chọn độ nhạy Cao nếu muốn dễ demo, đặt máy xuống và nhấn BẬT BẢO VỆ.
4. Chờ hết 3 giây, rung bằng tay có kiểm soát; không làm rơi điện thoại.
5. Khi gia tốc tổng vượt ngưỡng, UI chuyển đỏ và bộ đếm tăng 1. Tiếp tục rung khi chuông reo để chứng minh không đếm lặp.
6. Nhấn TẮT CẢNH BÁO: chuông dừng, bảo vệ còn bật. Chờ cooldown và để máy yên trước lần tiếp theo.
7. TẮT BẢO VỆ; nhấn TEST để chứng minh cùng luồng cảnh báo, bộ đếm và lịch sử.
8. Vào Lịch sử: phân biệt sự kiện cảm biến và TEST thủ công.
9. Cài đặt: chọn từng âm và nghe thử 2 giây. Nghe thử không tăng bộ đếm, không ghi lịch sử.
10. Tắt âm thanh và TEST: UI vẫn cảnh báo nhưng không phát chuông. Tắt cảnh báo rồi bật âm lại.
11. RESET BỘ ĐẾM: số đếm về 0, lịch sử vẫn còn. Chuyển tab/vuốt để giới thiệu animation.

## Câu hỏi nên chuẩn bị

- Accelerometer đo gia tốc, không đo vận tốc hay tọa độ.
- Gia tốc tổng tính bằng `sqrt(x*x + y*y + z*z)`; mức chuyển động hiển thị bằng `abs(magnitude - 9.81)`.
- Ngưỡng thực nghiệm dùng gia tốc tổng: Thấp >18, Trung bình >15, Cao >12 m/s².
- Sensor thật chỉ có trên thiết bị thật; emulator mô phỏng, TEST chỉ gọi hàm cảnh báo.
- Không có bảo vệ nền khi khóa màn hình, không phát hiện mọi chuyển động, không thay thế hệ thống chống trộm.
- Dữ liệu chỉ lưu trong RAM; ngắt tiến trình app sẽ mất lịch sử và cài đặt.

## Bằng chứng kiểm tra

Bốn test hiện có: phản hồi một mẫu sau chuẩn bị và chống đếm lặp/cooldown; các ngưỡng độ nhạy; nghe thử khi tắt âm không tạo cảnh báo; luồng UI chia sẻ state và chọn chuông/reset.

`flutter analyze`, `flutter test`, `flutter build apk --debug` là các lệnh xác minh trước khi nộp. Build thành công không thay thế việc thử rung/lắc và nghe âm trên điện thoại thật. Trong phiên phát triển đã chạy emulator và cài/chạy trên Redmi Note 13 Pro 5G; nhóm vẫn nên diễn tập trên thiết bị sẽ dùng trên lớp.
