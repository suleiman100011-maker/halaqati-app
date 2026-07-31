import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../widgets/app_header.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _fmt(DateTime d) {
    const days = ['الأحد','الاثنين','الثلاثاء','الأربعاء','الخميس','الجمعة','السبت'];
    const months = ['يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
    return '${days[d.weekday % 7]} ${d.day} ${months[d.month - 1]} ${d.year}';
  }

  void _copyReport(BuildContext context, AppState s) {
    final today = s.todayKey;
    final todaySess = s.sessions.where((r) => r.date == today && r.status != 'none').toList();
    if (todaySess.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا توجد بيانات مسجلة اليوم', style: TextStyle(fontFamily: 'Tajawal')), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
      return;
    }
    var r = '━━━━━━━━━━━━━━\n📖 تقرير حلقة (${s.settings.halakaName})\n📅 ${_fmt(DateTime.now())}\n━━━━━━━━━━━━━━\n';
    final active = s.students.where((st) => st.active).toList();
    for (int i = 0; i < active.length; i++) {
      final st = active[i];
      final rec = s.getTodaySession(st.id);
      final pts = s.getTodayPoints(st.id);
      r += '${i + 1}️⃣ ${st.name}\n';
      if (rec == null || rec.status == 'none' || rec.status == 'absent') { r += '✖ غائب (غير مبرر)\n'; }
      else if (rec.status == 'absent_excused') { r += '✖ غائب (بعذر)\n'; }
      else {
        r += '✔ حاضر\n';
        if (rec.hifzAmount > 0 || rec.hifzNote.isNotEmpty) {
          var hl = ''; if (rec.hifzAmount > 0) hl += '${rec.hifzAmount} صفحة'; if (rec.hifzNote.isNotEmpty) hl += '. ${rec.hifzNote}'; hl += rec.hifzCompleted ? '. ✅' : '. 🔄';
          r += '📌 الحفظ: $hl\n';
        }
        if (rec.reviewAmount > 0 || rec.reviewNote.isNotEmpty) {
          var rl = ''; if (rec.reviewAmount > 0) rl += '${rec.reviewAmount} صفحة'; if (rec.reviewNote.isNotEmpty) rl += '. ${rec.reviewNote}'; rl += rec.reviewCompleted ? '. ✅' : '. 🔄';
          r += '📖 المراجعة: $rl\n';
        }
        r += '⭐ تقييم: ${rec.rating}\n';
      }
      if (pts > 0) r += '🎯 نقاط اليوم: +$pts نقطة\n';
      else if (pts < 0) r += '🔻 نقاط اليوم: $pts نقطة\n';
      r += '──────────────\n';
    }
    r += 'الحضور: ${s.presentToday}\nالغياب: ${s.absentToday}\n━━━━━━━━━━━━━━';
    Clipboard.setData(ClipboardData(text: r));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ تم نسخ تقرير الجلسة', style: TextStyle(fontFamily: 'Tajawal')), backgroundColor: Color(0xFF059669), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final top3 = [...s.students.where((x) => x.active)]..sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: AppHeader(halakaName: s.settings.halakaName, teacherName: s.settings.teacherName)),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(delegate: SliverChildListDelegate([
            // Stats row
            Row(children: [
              _StatCard('الطلاب', s.totalActive, AppTheme.primary),
              const SizedBox(width: 10),
              _StatCard('حضور اليوم', s.presentToday, AppTheme.blue),
              const SizedBox(width: 10),
              _StatCard('غياب', s.absentToday, AppTheme.red),
            ]),
            const SizedBox(height: 16),

            // Start session banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.greenCard(),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('جلسة اليوم', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, color: Colors.white, fontSize: 18)),
                  Text('سجّل الحضور والقراءة الآن', style: TextStyle(fontFamily: 'Tajawal', color: Colors.white70, fontSize: 12)),
                ]),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  child: const Text('ابدأ الآن', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900)),
                ),
              ]),
            ),
            const SizedBox(height: 16),

            // Copy report
            GestureDetector(
              onTap: () => _copyReport(context, s),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.cardDecoration(),
                child: Row(children: [
                  Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.copy_rounded, color: AppTheme.primary, size: 20)),
                  const SizedBox(width: 12),
                  const Text('نسخ تقرير الواتساب اليومي', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, fontSize: 14)),
                  const Spacer(),
                  const Icon(Icons.chevron_left_rounded, color: Colors.grey),
                ]),
              ),
            ),
            const SizedBox(height: 16),

            // Top students
            if (top3.isNotEmpty) Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.cardDecoration(),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [
                  Text('🏆', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text('المتميزون', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, fontSize: 14)),
                ]),
                const SizedBox(height: 12),
                ...top3.take(3).toList().asMap().entries.map((e) {
                  final medals = ['🥇', '🥈', '🥉'];
                  final st = e.value;
                  return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
                    Text(medals[e.key], style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(st.name, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13)),
                    const Spacer(),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFFEF9C3), borderRadius: BorderRadius.circular(20)),
                      child: Text('${s.getStars(st.totalPoints)} ⭐ · ${st.totalPoints} نقطة', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF854D0E)))),
                  ]));
                }),
              ]),
            ),
            const SizedBox(height: 80),
          ])),
        ),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label; final int value; final Color color;
  const _StatCard(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border(bottom: BorderSide(color: color, width: 3)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]),
    child: Column(children: [
      Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      Text('$value', style: TextStyle(fontFamily: 'Tajawal', fontSize: 24, fontWeight: FontWeight.w900, color: color)),
    ]),
  ));
}
