import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../widgets/bottom_nav.dart';
import 'dashboard_screen.dart';
import 'session_screen.dart';
import 'students_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (!state.isReady) {
      return Scaffold(
        backgroundColor: const Color(0xFF059669),
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('📖', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 16),
          const Text('حَلَقَتي', style: TextStyle(fontFamily: 'Tajawal', fontSize: 38, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text('جاري تحميل قاعدة البيانات...', style: TextStyle(fontFamily: 'Tajawal', color: Colors.white.withOpacity(0.8), fontSize: 14)),
          const SizedBox(height: 28),
          const CircularProgressIndicator(color: Colors.white),
        ])),
      );
    }

    final screens = [
      const DashboardScreen(),
      const SessionScreen(),
      const StudentsScreen(),
      const ReportsScreen(),
      const SettingsScreen(),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: screens[_tab],
        bottomNavigationBar: BottomNav(currentIndex: _tab, onTap: (i) => setState(() => _tab = i)),
      ),
    );
  }
}
