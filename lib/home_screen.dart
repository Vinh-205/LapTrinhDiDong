import 'package:flutter/material.dart';

import 'alarm_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.state});
  final AlarmState state;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: state,
    builder: (context, _) {
      final alarm = state.isAlarmActive;
      final enabled = state.isProtectionEnabled;
      final accent = alarm ? const Color(0xFFC63E40) : const Color(0xFF087F6C);
      final status = alarm
          ? 'PHÁT HIỆN CHUYỂN ĐỘNG'
          : enabled
          ? (state.isArming ? 'ĐANG CHUẨN BỊ' : 'ĐANG BẢO VỆ')
          : 'CHƯA BẬT BẢO VỆ';
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const Text(
            'AN TÂM TRONG TỪNG CHUYỂN ĐỘNG',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6D828A),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: alarm
                    ? [const Color(0xFF8C2637), const Color(0xFFC44B41)]
                    : [const Color(0xFF142E3A), const Color(0xFF17695E)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .13),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        alarm
                            ? Icons.notifications_active_rounded
                            : enabled
                            ? Icons.shield_rounded
                            : Icons.shield_outlined,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .13),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        alarm
                            ? 'CẢNH BÁO'
                            : enabled
                            ? 'ĐÃ KÍCH HOẠT'
                            : 'SẴN SÀNG',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .7,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  alarm
                      ? 'Nhấn tắt cảnh báo để dừng chuông.'
                      : enabled
                      ? (state.isArming
                            ? 'Đặt máy nằm yên • Chờ ${state.armingSeconds} giây'
                            : 'Đang theo dõi chuyển động của thiết bị.')
                      : 'Đặt điện thoại xuống rồi bật bảo vệ.',
                  style: const TextStyle(
                    color: Color(0xFFD9EAE6),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Mức chuyển động',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.sensors,
                        size: 20,
                        color: state.hasSensorData ? accent : Colors.blueGrey,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.end,
                    spacing: 8,
                    children: [
                      Text(
                        state.hasSensorData
                            ? state.movement.toStringAsFixed(2)
                            : '—',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: accent,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 9),
                        child: Text(
                          'm/s²',
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (state.movement / 10).clamp(0, 1),
                    color: accent,
                    backgroundColor: const Color(0xFFEDF2F3),
                    minHeight: 7,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Gia tốc tổng: ${state.hasSensorData ? state.magnitude.toStringAsFixed(2) : '—'} m/s²',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF536B75),
                    ),
                  ),
                  const Text(
                    'Độ lệch khỏi trọng lực • Gần 0 khi máy nằm yên',
                    style: TextStyle(fontSize: 11, color: Color(0xFF536B75)),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Color(0xFFE7EEEF)),
                  ),
                  Row(
                    children: [
                      for (final axis in [
                        ('X', state.x),
                        ('Y', state.y),
                        ('Z', state.z),
                      ])
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TRỤC ${axis.$1}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 1,
                                  color: Color(0xFF536B75),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                state.hasSensorData
                                    ? axis.$2.toStringAsFixed(2)
                                    : '—',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Badge(
                icon: Icons.radar,
                label: 'Đã phát hiện: ${state.detectionCount} lần',
              ),
              _Badge(
                icon: Icons.tune,
                label: 'Độ nhạy: ${state.sensitivity.label}',
              ),
            ],
          ),
          for (final error in [state.sensorError, state.audioError])
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(error, style: const TextStyle(color: Colors.red)),
              ),
          const SizedBox(height: 20),
          if (alarm) ...[
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: accent),
              onPressed: state.stopAlarm,
              icon: const Icon(Icons.notifications_off_outlined),
              label: const Text('TẮT CẢNH BÁO'),
            ),
            const SizedBox(height: 10),
          ],
          FilledButton.icon(
            onPressed: state.toggleProtection,
            icon: Icon(
              enabled ? Icons.lock_open_rounded : Icons.shield_outlined,
            ),
            label: Text(enabled ? 'TẮT BẢO VỆ' : 'BẬT BẢO VỆ'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: alarm ? null : () => state.triggerAlarm(isTest: true),
            icon: const Icon(Icons.volume_up_outlined),
            label: const Text('TEST CẢNH BÁO'),
          ),
          const SizedBox(height: 14),
          const Text(
            'Giữ ứng dụng mở khi bảo vệ. Bộ đếm bao gồm lần TEST.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Color(0xFF536B75)),
          ),
        ],
      );
    },
  );
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE3EAED)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF087F6C)),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}
