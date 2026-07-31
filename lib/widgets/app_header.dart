import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppHeader extends StatelessWidget {
  final String halakaName, teacherName;
  const AppHeader({super.key, required this.halakaName, required this.teacherName});

  String get _todayLabel {
    const days = ['الأحد','الاثنين','الثلاثاء','الأربعاء','الخميس','الجمعة','السبت'];
    const months = ['يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
    final n = DateTime.now();
    return '${days[n.weekday % 7]} ${n.day} ${months[n.month - 1]} ${n.year}';
  }

  @override
  Widget build(BuildContext context) => Container(
    decoration: AppTheme.gradientHeader(),
    padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20, left: 20, right: 20, bottom: 24),
    child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('حَلَقَتي', style: TextStyle(fontFamily: 'Tajawal', fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
          Text('$halakaName · $teacherName', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Colors.white.withOpacity(0.85))),
        ]),
        Container(padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 26)),
      ]),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.13), borderRadius: BorderRadius.circular(16)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(_todayLabel, style: const TextStyle(fontFamily: 'Tajawal', color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
          const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 16),
        ]),
      ),
    ]),
  );
}
