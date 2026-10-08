import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

// Ngưỡng gia tốc tổng như bản đầu; phản hồi ngay trong một mẫu.
enum Sensitivity {
  low('Thấp', 18),
  medium('Trung bình', 15),
  high('Cao', 12);

  const Sensitivity(this.label, this.threshold);
  final String label;
  final double threshold;
}

enum AlarmTone {
  siren('Còi báo động', 'Hai âm luân phiên, rõ và mạnh', 'alarm.wav'),
  bell('Chuông ngân', 'Âm chuông sáng, ngân nhẹ', 'bell.wav'),
  pulse('Bíp nhịp nhanh', 'Tiếng bíp ngắn, dứt khoát', 'pulse.wav');

  const AlarmTone(this.label, this.description, this.asset);
  final String label;
  final String description;
  final String asset;
}

class AlarmEvent {
  AlarmEvent(this.message) : time = DateTime.now();
  final DateTime time;
  final String message;
}

// State dùng chung cho ba tab; không cần package quản lý state hay database.
class AlarmState extends ChangeNotifier {
  AlarmState({DateTime Function()? now}) : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  static const gravity = 9.81;
  DateTime? _armingUntil;

  bool get isArming =>
      isProtectionEnabled &&
      _armingUntil != null &&
      _now().isBefore(_armingUntil!);
  int get armingSeconds => isArming
      ? ((_armingUntil!.difference(_now()).inMilliseconds + 999) ~/ 1000)
      : 0;

  StreamSubscription<AccelerometerEvent>? _subscription;
  AudioPlayer? _player;
  AlarmTone selectedTone = AlarmTone.siren;
  bool isPreviewing = false;
  Timer? _previewTimer;
  Future<void> _audioQueue = Future.value();
  bool _disposed = false;
  bool _readyForMovement = true;
  DateTime? _cooldownUntil;
  final List<AlarmEvent> _history = [];

  double x = 0, y = 0, z = 0;
  double magnitude = 0;
  double movement = 0;
  bool hasSensorData = false;
  bool isProtectionEnabled = false;
  bool isAlarmActive = false;
  bool soundEnabled = true;
  int detectionCount = 0;
  Sensitivity sensitivity = Sensitivity.medium;
  String? sensorError;
  String? audioError;

  double get movementThreshold => sensitivity.threshold;
  List<AlarmEvent> get history => List.unmodifiable(_history);

  void startListening() {
    if (_subscription != null || _disposed) return;
    try {
      _subscription =
          accelerometerEventStream(
            samplingPeriod: const Duration(milliseconds: 100),
          ).listen(
            (event) => updateAcceleration(event.x, event.y, event.z),
            onError: (Object error) {
              sensorError =
                  'Không đọc được cảm biến. Bạn vẫn có thể TEST CẢNH BÁO.';
              _notify();
            },
            cancelOnError: true,
          );
    } catch (_) {
      sensorError = 'Thiết bị không hỗ trợ cảm biến. Hãy dùng TEST CẢNH BÁO.';
      _notify();
    }
  }

  void updateAcceleration(double newX, double newY, double newZ) {
    if (_disposed || !newX.isFinite || !newY.isFinite || !newZ.isFinite) return;
    x = newX;
    y = newY;
    z = newZ;
    magnitude = sqrt(x * x + y * y + z * z);
    hasSensorData = true;
    sensorError = null;
    // Đây là độ lệch độ lớn gia tốc khỏi trọng lực, không phải vận tốc
    // hay vector gia tốc tuyến tính. Máy yên thường cho giá trị gần 0.
    movement = (magnitude - gravity).abs();
    final now = _now();
    final cooledDown = _cooldownUntil == null || !now.isBefore(_cooldownUntil!);
    if (magnitude < movementThreshold - 1) _readyForMovement = true;
    // Nhạy như bản đầu: một mẫu vượt ngưỡng là đủ, không chờ 200 ms.
    if (isProtectionEnabled &&
        !isArming &&
        !isAlarmActive &&
        cooledDown &&
        _readyForMovement &&
        magnitude > movementThreshold) {
      triggerAlarm();
    }
    _notify();
  }

  void toggleProtection() {
    isProtectionEnabled = !isProtectionEnabled;
    _readyForMovement = false;
    _armingUntil = isProtectionEnabled
        ? _now().add(const Duration(seconds: 3))
        : null;
    if (!isProtectionEnabled) {
      _previewTimer?.cancel();
      isPreviewing = false;
      isAlarmActive = false;
      _syncAudio();
    }
    _addEvent(isProtectionEnabled ? 'Bật chế độ bảo vệ' : 'Tắt chế độ bảo vệ');
    _notify();
  }

  // Nút TEST và cảm biến cùng đi qua hàm này; một cảnh báo chỉ đếm một lần.
  void triggerAlarm({bool isTest = false}) {
    if (isAlarmActive || _disposed) return;
    _previewTimer?.cancel();
    isPreviewing = false;
    isAlarmActive = true;
    _readyForMovement = false;
    detectionCount++;
    _addEvent(
      isTest
          ? 'Test cảnh báo (thủ công)'
          : 'Phát hiện chuyển động mạnh (gia tốc ${magnitude.toStringAsFixed(2)} m/s²)',
    );
    _syncAudio();
    _notify();
  }

  void stopAlarm() {
    _previewTimer?.cancel();
    isPreviewing = false;
    isAlarmActive = false;
    _readyForMovement = false;
    _cooldownUntil = _now().add(const Duration(seconds: 2));
    _addEvent('Tắt cảnh báo');
    _syncAudio();
    _notify();
  }

  void setSensitivity(Sensitivity value) {
    sensitivity = value;
    _notify();
  }

  void setSoundEnabled(bool value) {
    soundEnabled = value;
    if (!value) {
      _previewTimer?.cancel();
      isPreviewing = false;
    }
    _syncAudio();
    _notify();
  }

  void setTone(AlarmTone tone) {
    selectedTone = tone;
    // Đổi chuông đang phát mà không tạo sự kiện hay tăng bộ đếm.
    _syncAudio();
    _notify();
  }

  void previewTone() {
    if (_disposed || isAlarmActive || !soundEnabled) return;
    if (isPreviewing) {
      stopPreview();
      return;
    }
    isPreviewing = true;
    _previewTimer?.cancel();
    _syncAudio();
    _previewTimer = Timer(const Duration(seconds: 2), stopPreview);
    _notify();
  }

  void stopPreview() {
    _previewTimer?.cancel();
    if (!isPreviewing) return;
    isPreviewing = false;
    _syncAudio();
    _notify();
  }

  void resetCounter() {
    detectionCount = 0;
    _notify();
  }

  void _addEvent(String message) => _history.insert(0, AlarmEvent(message));

  // Tuần tự hóa lệnh audio để bấm TEST rồi TẮT nhanh vẫn dừng chuông đúng.
  void _syncAudio() {
    _audioQueue = _audioQueue.then((_) async {
      if (_disposed) return;
      try {
        if ((isAlarmActive || isPreviewing) && soundEnabled) {
          final player = _player ??= AudioPlayer();
          await player.setReleaseMode(ReleaseMode.loop);
          if (_disposed || (!isAlarmActive && !isPreviewing) || !soundEnabled) {
            return;
          }
          await player.play(AssetSource(selectedTone.asset));
        } else {
          await _player?.stop();
        }
        audioError = null;
      } catch (_) {
        audioError = 'Không phát được âm thanh. Kiểm tra âm lượng và thử lại.';
      }
      _notify();
    });
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _previewTimer?.cancel();
    unawaited(_subscription?.cancel());
    unawaited(_audioQueue.then((_) async => _player?.dispose()));
    super.dispose();
  }
}
