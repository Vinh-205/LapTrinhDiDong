import 'package:flutter/material.dart';

import 'alarm_state.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.state});
  final AlarmState state;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: state,
    builder: (context, _) {
      final events = state.history;
      if (events.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Chưa có sự kiện.\nBật bảo vệ hoặc TEST CẢNH BÁO để bắt đầu.',
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Sự kiện mới nhất ở trên. Lịch sử chỉ lưu trong phiên chạy hiện tại.',
              ),
            );
          }
          final event = events[index - 1];
          final t = event.time;
          String two(int n) => n.toString().padLeft(2, '0');
          return Card(
            child: ListTile(
              leading: const Icon(Icons.history),
              title: Text(event.message),
              subtitle: Text(
                '${two(t.hour)}:${two(t.minute)}:${two(t.second)} • ${two(t.day)}/${two(t.month)}',
              ),
            ),
          );
        },
      );
    },
  );
}
