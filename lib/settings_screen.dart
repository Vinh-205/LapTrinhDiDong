import 'package:flutter/material.dart';

import 'alarm_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.state});
  final AlarmState state;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: state,
    builder: (context, _) => ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ĐỘ NHẠY',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<Sensitivity>(
                    showSelectedIcon: false,
                    segments: [
                      for (final value in Sensitivity.values)
                        ButtonSegment(value: value, label: Text(value.label)),
                    ],
                    selected: {state.sensitivity},
                    onSelectionChanged: (values) =>
                        state.setSensitivity(values.single),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Độ nhạy cao dễ kích hoạt hơn. Trung bình phù hợp để bắt đầu demo.',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: SwitchListTile(
            title: const Text('Âm thanh cảnh báo'),
            subtitle: const Text('Tắt mục này để chỉ hiển thị cảnh báo.'),
            value: state.soundEnabled,
            onChanged: state.setSoundEnabled,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CHỌN ÂM THANH',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                for (final tone in AlarmTone.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Semantics(
                      selected: state.selectedTone == tone,
                      child: Material(
                        color: state.selectedTone == tone
                            ? const Color(0xFFE2F2EC)
                            : const Color(0xFFF5F7F8),
                        borderRadius: BorderRadius.circular(14),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          leading: Icon(
                            state.selectedTone == tone
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: const Color(0xFF087F6C),
                          ),
                          title: Text(tone.label),
                          subtitle: Text(
                            tone.description,
                            style: const TextStyle(fontSize: 12),
                          ),
                          onTap: () => state.setTone(tone),
                        ),
                      ),
                    ),
                  ),
                OutlinedButton.icon(
                  onPressed: state.soundEnabled && !state.isAlarmActive
                      ? state.previewTone
                      : null,
                  icon: Icon(
                    state.isPreviewing
                        ? Icons.stop_rounded
                        : Icons.play_arrow_rounded,
                  ),
                  label: Text(
                    state.isPreviewing ? 'DỪNG NGHE THỬ' : 'NGHE THỬ · 2 GIÂY',
                  ),
                ),
                if (!state.soundEnabled)
                  const Text('Bật âm thanh cảnh báo để nghe thử.'),
                if (state.isAlarmActive)
                  const Text(
                    'Cảnh báo đang bật. Chọn âm để đổi chuông đang phát.',
                  ),
                if (state.audioError != null)
                  Text(
                    state.audioError!,
                    style: const TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: () {
            state.resetCounter();
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Đã reset bộ đếm')));
          },
          icon: const Icon(Icons.restart_alt),
          label: const Text('RESET BỘ ĐẾM'),
        ),
        const SizedBox(height: 16),
        const Text(
          'Demo cảm biến chuyển động\nLịch sử và cài đặt không lưu sau khi đóng ứng dụng.',
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
