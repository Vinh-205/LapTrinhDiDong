import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_canhbaochongtrom/alarm_state.dart';
import 'package:demo_canhbaochongtrom/home_screen.dart';
import 'package:demo_canhbaochongtrom/history_screen.dart';
import 'package:demo_canhbaochongtrom/settings_screen.dart';

void main() {
  test(
    'Original sensitivity reacts to one brief movement after preparation',
    () {
      var now = DateTime(2026);
      final state = AlarmState(now: () => now)..setSoundEnabled(false);
      addTearDown(state.dispose);
      state.toggleProtection();
      state.updateAcceleration(0, 0, 20);
      expect(state.detectionCount, 0);
      state.updateAcceleration(0, 0, 9.82);
      now = now.add(const Duration(seconds: 4));
      for (var i = 0; i < 600; i++) {
        state.updateAcceleration(0, 0, 9.82);
      }
      expect(state.movement, closeTo(.01, .001));
      expect(state.detectionCount, 0);
      state.updateAcceleration(0, 0, 16);
      expect(state.detectionCount, 1);
      state.updateAcceleration(0, 0, 20);
      expect(state.detectionCount, 1);
      state.stopAlarm();
      state.updateAcceleration(0, 0, 9.82);
      state.updateAcceleration(0, 0, 20);
      expect(state.isAlarmActive, false);
      now = now.add(const Duration(seconds: 3));
      state.updateAcceleration(0, 0, 20);
      expect(state.detectionCount, 2);
      state.toggleProtection();
      expect(state.isAlarmActive, false);
    },
  );

  test('All original thresholds use total acceleration', () {
    for (final sensitivity in Sensitivity.values) {
      var now = DateTime(2026);
      final state = AlarmState(now: () => now)..setSoundEnabled(false);
      state.setSensitivity(sensitivity);
      state.toggleProtection();
      state.updateAcceleration(0, 0, 9.82);
      now = now.add(const Duration(seconds: 4));
      state.updateAcceleration(0, 0, sensitivity.threshold);
      expect(state.isAlarmActive, false);
      state.updateAcceleration(0, 0, sensitivity.threshold + .1);
      expect(state.isAlarmActive, true);
      state.dispose();
    }
  });

  test('Muted previews do not trigger an alarm or add history', () {
    final state = AlarmState()..setSoundEnabled(false);
    addTearDown(state.dispose);
    state.setTone(AlarmTone.pulse);
    state.previewTone();
    expect(state.isPreviewing, false);
    expect(state.isAlarmActive, false);
    expect(state.detectionCount, 0);
    expect(state.history, isEmpty);
    expect(state.selectedTone.asset, 'pulse.wav');
  });

  testWidgets('Demo controls, history and settings share state', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final state = AlarmState()..setSoundEnabled(false);
    addTearDown(state.dispose);
    Future<void> show(Widget screen) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: screen)));
      await tester.pump();
    }

    await show(HomeScreen(state: state));
    expect(find.text('CHƯA BẬT BẢO VỆ'), findsOneWidget);
    await tester.tap(find.text('BẬT BẢO VỆ'));
    await tester.pump();
    expect(find.text('ĐANG CHUẨN BỊ'), findsOneWidget);
    await tester.ensureVisible(find.text('TEST CẢNH BÁO'));
    await tester.tap(find.text('TEST CẢNH BÁO'));
    await tester.pump();
    expect(find.text('PHÁT HIỆN CHUYỂN ĐỘNG'), findsOneWidget);
    expect(state.detectionCount, 1);
    await tester.ensureVisible(find.text('TẮT CẢNH BÁO'));
    await tester.tap(find.text('TẮT CẢNH BÁO'));
    await tester.pump();
    expect(state.isAlarmActive, false);
    await show(HistoryScreen(state: state));
    expect(find.text('Test cảnh báo (thủ công)'), findsOneWidget);
    await show(SettingsScreen(state: state));
    await tester.tap(find.text('Cao'));
    await tester.pump();
    expect(state.movementThreshold, 12);
    await tester.ensureVisible(find.text('Chuông ngân'));
    await tester.tap(find.text('Chuông ngân'));
    await tester.pump();
    expect(state.selectedTone, AlarmTone.bell);
    expect(state.detectionCount, 1);
    await tester.ensureVisible(find.text('RESET BỘ ĐẾM'));
    await tester.tap(find.text('RESET BỘ ĐẾM'));
    await tester.pump();
    expect(state.detectionCount, 0);
    expect(tester.takeException(), isNull);
  });
}
