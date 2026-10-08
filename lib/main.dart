import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import 'alarm_state.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Cảnh báo chống trộm',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF16856B)),
      scaffoldBackgroundColor: const Color(0xFFF3F6F8),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Color(0xFFF3F6F8),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: Color(0xFF142D36),
          fontSize: 23,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Color(0xFFE3EAED)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    ),
    home: const MainScreen(),
  );
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final AlarmState _state;
  late final List<Widget> _screens;
  int _selectedIndex = 0;
  final _pages = PageController();

  @override
  void initState() {
    super.initState();
    _state = AlarmState()..startListening();
    _screens = [
      HomeScreen(state: _state),
      HistoryScreen(state: _state),
      SettingsScreen(state: _state),
    ];
  }

  @override
  void dispose() {
    _pages.dispose();
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        ['Cảnh báo chống trộm', 'Lịch sử', 'Cài đặt'][_selectedIndex],
      ),
    ),
    extendBody: true,
    body: SafeArea(
      child: PageView(
        controller: _pages,
        onPageChanged: (index) {
          _state.stopPreview();
          setState(() => _selectedIndex = index);
        },
        children: _screens,
      ),
    ),
    bottomNavigationBar: SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x18142D36),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .74),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withValues(alpha: .85)),
              ),
              child: Row(
                children: [
                  for (var index = 0; index < 3; index++) ...[
                    if (index > 0) const SizedBox(width: 10),
                    Expanded(child: _navigationButton(index)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _navigationButton(int index) {
    final selected = _selectedIndex == index;
    final label = ['Trang chủ', 'Lịch sử', 'Cài đặt'][index];
    final icon = [
      Icons.home_rounded,
      Icons.history_rounded,
      Icons.settings_rounded,
    ][index];
    return Semantics(
      selected: selected,
      child: AnimatedSlide(
        offset: selected ? const Offset(0, -.04) : Offset.zero,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        child: ElevatedButton(
          onPressed: () {
            _state.stopPreview();
            if (MediaQuery.disableAnimationsOf(context)) {
              _pages.jumpToPage(index);
            } else {
              _pages.animateToPage(
                index,
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeInOutCubic,
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: selected ? const Color(0xFF087F6C) : Colors.white,
            foregroundColor: selected ? Colors.white : const Color(0xFF536B75),
            surfaceTintColor: Colors.transparent,
            shadowColor: const Color(0x33142D36),
            elevation: selected ? 6 : 3,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            minimumSize: const Size(48, 64),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24),
              const SizedBox(height: 5),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
