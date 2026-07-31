import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../widgets/app_header.dart';
import '../theme/app_theme.dart';
import 'student_profile_screen.dart';

const _monthsAr = ['يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _tab = 0; // 0=points, 1=monthly
  int _monthlyView = 0; // 0=halaqa, 1=individual
  int _filterMode = 0; // 0=month, 1=range
  int _selMonth = DateTime.now().month - 1;
  int _selYear  = DateTime.now().year;
  String _dateFrom = () { final d = DateTime.now(); return '${d.year}-${d.month.toString().padLeft(2,"0")}-01'; }();
  String _dateTo   = DateTime.now().toIso8601String().split('T')[0];

  String get _periodLabel => _filterMode == 0 ? '${_monthsAr[_selMonth]} $_selYear' : '$_dateFrom — $_dateTo';

  String get _fromKey => _filterMode == 0
    ? '$_selYear-${(_selMonth + 1).toString().padLeft(2,"0")}-01'
    : _dateFrom;

  String get _toKey => _filterMode == 0
    ? '$_selYear-${(_selMonth + 1).toString().padLeft(2,"0")}-31'
    : _dateTo;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final active = s.students.where((x) => x.active).toList();

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: AppHeader(halakaName: s.settings.halakaName, teacherName: s.settings.teacherName)),
        SliverPadding(padding: const EdgeInsets.all(16), sliver: SliverList(delegate: SliverChildListDelegate([
          const Text('التقارير', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 12),

          // Main tabs
          _SegBtn(items: const ['الأرصدة والنجوم', '📅 التقرير الشهري'], selected: _tab, onChanged: (i) => setState(() => _tab = i)),
          const SizedBox(height: 16),

          if (_tab == 0) ..._buildPointsTab(context, s, active),
          if (_tab == 1) ..._buildMonthlyTab(context, s, active),

          const SizedBox(height: 80),
        ]))),
      ]),
    );
  }

  // ── Points Tab ──────────────────────────────────────────────
  List<Widget> _buildPointsTab(BuildContext context, AppState s, List active) => [
    Container(padding: const EdgeInsets.all(18), decoration: AppTheme.cardDecoration(), child: Column(children: [
      Row(children: [
        const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 20), const SizedBox(width: 8),
        const Text('أرصدة الطلاب', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, fontSize: 15)), const Spacer(),
        TextButton.icon(onPressed: () => _copyPointsReport(context, s, active),
          icon: const Icon(Icons.copy_rounded, size: 14, color: AppTheme.primary),
          label: const Text('نسخ', style: TextStyle(fontFamily: 'Tajawal', color: AppTheme.primary, fontWeight: FontWeight.w900))),
      ]),
      const Divider(),
      ...active.map((st) => ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StudentProfileScreen(studentId: st.id))),
        leading: CircleAvatar(backgroundColor: AppTheme.primary.withOpacity(0.1), child: Text(st.name[0], style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, color: AppTheme.primary))),
        title: Text(st.name, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700)),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('${st.totalPoints} نقطة', style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Colors.grey)),
          const SizedBox(width: 6),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xFFFEF9C3), borderRadius: BorderRadius.circular(20)),
            child: Text('${s.getStars(st.totalPoints)} ⭐', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, color: Color(0xFF854D0E), fontSize: 12))),
        ]),
      )),
    ])),
  ];

  // ── Monthly Tab ─────────────────────────────────────────────
  List<Widget> _buildMonthlyTab(BuildContext context, AppState s, List active) {
    final periodSessions = s.getSessionsInPeriod(_fromKey, _toKey);
    final sessionDays = periodSessions.map((s) => s.date).toSet().toList()..sort();
    final statsMap = {for (final st in active) st.id: s.getStudentStats(st.id, periodSessions)};

    return [
      // Period selector
      Container(padding: const EdgeInsets.all(16), decoration: AppTheme.cardDecoration(), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('الفترة الزمنية', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, fontSize: 14)),
        const SizedBox(height: 10),
        _SegBtn(items: const ['شهر محدد', 'من تاريخ ← إلى تاريخ'], selected: _filterMode, onChanged: (i) => setState(() => _filterMode = i)),
        const SizedBox(height: 10),
        if (_filterMode == 0) Row(children: [
          Expanded(child: DropdownButtonFormField<int>(
            value: _selMonth,
            decoration: InputDecoration(filled: true, fillColor: const Color(0xFFF9FAFB), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
            style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, color: AppTheme.textDark),
            items: List.generate(12, (i) => DropdownMenuItem(value: i, child: Text(_monthsAr[i], style: const TextStyle(fontFamily: 'Tajawal')))),
            onChanged: (v) { if (v != null) setState(() => _selMonth = v); },
          )),
          const SizedBox(width: 8),
          SizedBox(width: 100, child: DropdownButtonFormField<int>(
            value: _selYear,
            decoration: InputDecoration(filled: true, fillColor: const Color(0xFFF9FAFB), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
            style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, color: AppTheme.textDark),
            items: [_selYear - 1, _selYear, _selYear + 1].map((y) => DropdownMenuItem(value: y, child: Text('$y', style: const TextStyle(fontFamily: 'Tajawal')))).toList(),
            onChanged: (v) { if (v != null) setState(() => _selYear = v); },
          )),
        ]),
        if (_filterMode == 1) Column(children: [
          Row(children: [const SizedBox(width: 28, child: Text('من', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w700))), Expanded(child: TextField(controller: TextEditingController(text: _dateFrom), onChanged: (v) => setState(() => _dateFrom = v), keyboardType: TextInputType.datetime, style: const TextStyle(fontFamily: 'Tajawal'), decoration: const InputDecoration(hintText: 'YYYY-MM-DD')))]),
          const SizedBox(height: 6),
          Row(children: [const SizedBox(width: 28, child: Text('إلى', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w700))), Expanded(child: TextField(controller: TextEditingController(text: _dateTo), onChanged: (v) => setState(() => _dateTo = v), keyboardType: TextInputType.datetime, style: const TextStyle(fontFamily: 'Tajawal'), decoration: const InputDecoration(hintText: 'YYYY-MM-DD')))]),
        ]),
        const SizedBox(height: 8),
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: sessionDays.isNotEmpty ? AppTheme.primary.withOpacity(0.08) : Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
          child: Text(sessionDays.isNotEmpty ? '✅ ${sessionDays.length} جلسة مسجلة في هذه الفترة' : 'لا توجد جلسات مسجلة في هذه الفترة',
            textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: sessionDays.isNotEmpty ? AppTheme.primary : Colors.grey))),
      ])),
      const SizedBox(height: 12),

      // View toggle
      _SegBtn(items: const ['👥 تقرير الحلقة', '👤 تقرير فردي'], selected: _monthlyView, onChanged: (i) => setState(() => _monthlyView = i)),
      const SizedBox(height: 12),

      if (_monthlyView == 0) ..._buildHalaqaView(context, s, active, statsMap, sessionDays, periodSessions),
      if (_monthlyView == 1) ..._buildIndividualView(context, s, active, statsMap),
    ];
  }

  List<Widget> _buildHalaqaView(BuildContext context, AppState s, List active, Map statsMap, List sessionDays, List periodSessions) {
    final totalPresent = active.fold(0, (sum, st) => sum + (statsMap[st.id]['present'] as int));
    final totalAbsent  = active.fold(0, (sum, st) => sum + (statsMap[st.id]['absent'] as int));
    final totalHifz    = active.fold(0.0, (sum, st) => sum + (statsMap[st.id]['hifzPages'] as double));
    final totalReview  = active.fold(0.0, (sum, st) => sum + (statsMap[st.id]['reviewPages'] as double));

    return [
      Container(padding: const EdgeInsets.all(16), decoration: AppTheme.cardDecoration(), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('إجمالي الحلقة — $_periodLabel', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, fontSize: 14)),
        const SizedBox(height: 12),

        // Summary stats
        Row(children: [
          Expanded(child: _MiniStat('إجمالي الحضور', '$totalPresent', AppTheme.primary)),
          const SizedBox(width: 8),
          Expanded(child: _MiniStat('إجمالي الغياب', '$totalAbsent', AppTheme.red)),
          const SizedBox(width: 8),
          Expanded(child: _MiniStat('عدد الجلسات', '${sessionDays.length}', AppTheme.blue)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _MiniStat('📖 صفحات حفظ', '${totalHifz.toStringAsFixed(1)}', AppTheme.primary)),
          const SizedBox(width: 8),
          Expanded(child: _MiniStat('🔁 صفحات مراجعة', '${totalReview.toStringAsFixed(1)}', AppTheme.indigo)),
        ]),
        const SizedBox(height: 14),

        // Per student
        ...active.map((st) {
          final stats = statsMap[st.id] as Map;
          final rate  = stats['rate'] as int;
          return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(st.name, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, fontSize: 13)),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: rate >= 75 ? AppTheme.primary.withOpacity(0.1) : rate >= 50 ? AppTheme.amber.withOpacity(0.1) : AppTheme.red.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text('$rate%', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, fontSize: 11, color: rate >= 75 ? AppTheme.primary : rate >= 50 ? AppTheme.amber : AppTheme.red))),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                Text('✔ ${stats['present']}', style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w700)),
                const SizedBox(width: 12),
                Text('✖ ${stats['absent']}', style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: AppTheme.red, fontWeight: FontWeight.w700)),
                const SizedBox(width: 12),
                Text('📝 ${stats['excused']}', style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w700)),
              ]),
              if ((stats['hifzPages'] as double) > 0 || (stats['reviewPages'] as double) > 0)
                Padding(padding: const EdgeInsets.only(top: 6), child: Row(children: [
                  if ((stats['hifzPages'] as double) > 0) _Tag('📖 حفظ: ${stats['hifzPages']} ص', AppTheme.primary),
                  if ((stats['reviewPages'] as double) > 0) ...[const SizedBox(width: 6), _Tag('🔁 مراجعة: ${stats['reviewPages']} ص', AppTheme.indigo)],
                ])),
            ]));
        }),
        const SizedBox(height: 8),

        // Action buttons
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: () => _copyHalaqaReport(context, s, active, statsMap, sessionDays),
            icon: const Icon(Icons.copy_rounded, size: 15, color: AppTheme.primary),
            label: const Text('نسخ التقرير', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, color: AppTheme.primary, fontSize: 13)),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)),
          )),
        ]),
      ])),
    ];
  }

  List<Widget> _buildIndividualView(BuildContext context, AppState s, List active, Map statsMap) => active.map((st) {
    final stats = statsMap[st.id] as Map;
    final rate  = stats['rate'] as int;
    return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: AppTheme.cardDecoration(), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          CircleAvatar(radius: 18, backgroundColor: AppTheme.primary.withOpacity(0.1), child: Text(st.name[0], style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, color: AppTheme.primary))),
          const SizedBox(width: 10),
          Text(st.name, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, fontSize: 14)),
        ]),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: rate >= 75 ? AppTheme.primary.withOpacity(0.1) : rate >= 50 ? AppTheme.amber.withOpacity(0.1) : AppTheme.red.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: Text('$rate%', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, fontSize: 12, color: rate >= 75 ? AppTheme.primary : rate >= 50 ? AppTheme.amber : AppTheme.red))),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _MiniStat('حاضر', '${stats['present']}', AppTheme.primary)),
        const SizedBox(width: 8),
        Expanded(child: _MiniStat('غائب', '${stats['absent']}', AppTheme.red)),
        const SizedBox(width: 8),
        Expanded(child: _MiniStat('بعذر', '${stats['excused']}', Colors.grey)),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: _MiniStat('📖 حفظ مقبول', '${stats['hifzPages']} ص', AppTheme.primary)),
        const SizedBox(width: 8),
        Expanded(child: _MiniStat('🔁 مراجعة مقبولة', '${stats['reviewPages']} ص', AppTheme.indigo)),
      ]),
      if ((stats['hifzList'] as List).isNotEmpty) ...[
        const SizedBox(height: 8),
        const Text('📖 تفاصيل الحفظ:', style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey)),
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(10)),
          child: Text((stats['hifzList'] as List).join(' · '), style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: AppTheme.textGrey))),
      ],
      if ((stats['reviewList'] as List).isNotEmpty) ...[
        const SizedBox(height: 6),
        const Text('🔁 تفاصيل المراجعة:', style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey)),
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(10)),
          child: Text((stats['reviewList'] as List).join(' · '), style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: AppTheme.textGrey))),
      ],
      const SizedBox(height: 10),
      SizedBox(width: double.infinity, child: OutlinedButton.icon(
        onPressed: () => _copyStudentReport(context, st, stats),
        icon: const Icon(Icons.copy_rounded, size: 14, color: AppTheme.primary),
        label: Text('نسخ تقرير ${st.name}', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, color: AppTheme.primary, fontSize: 12)),
        style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 10)),
      )),
    ]));
  }).toList();

  void _copyPointsReport(BuildContext context, AppState s, List active) {
    final today = DateTime.now().toLocal().toString().split(' ')[0];
    var r = '━━━━━━━━━━━━━━\n🌟 تقرير أرصدة الطلاب والنجوم\n📅 $today\n━━━━━━━━━━━━━━\n';
    for (int i = 0; i < active.length; i++) {
      final st = active[i]; final pts = st.totalPoints; final stars = s.getStars(pts); final rem = pts > 0 ? pts % 10 : pts;
      r += '${i + 1}️⃣ ${st.name}\n';
      r += stars > 0 ? 'الرصيد: $stars نجمة و $rem نقطة\n' : 'الرصيد: $pts نقطة\n';
      r += '──────────────\n';
    }
    r += '━━━━━━━━━━━━━━';
    Clipboard.setData(ClipboardData(text: r));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ تم نسخ تقرير الأرصدة', style: TextStyle(fontFamily: 'Tajawal')), backgroundColor: AppTheme.primary, behavior: SnackBarBehavior.floating));
  }

  void _copyHalaqaReport(BuildContext context, AppState s, List active, Map statsMap, List sessionDays) {
    var r = '━━━━━━━━━━━━━━\n📋 التقرير الشهري الإجمالي للحلقة\n📅 $_periodLabel\n🏫 ${s.settings.halakaName}\n━━━━━━━━━━━━━━\nعدد الجلسات: ${sessionDays.length} يوم\n──────────────\n';
    for (int i = 0; i < active.length; i++) {
      final st = active[i]; final stats = statsMap[st.id] as Map;
      r += '${i + 1}️⃣ ${st.name}\n✔ حضر: ${stats['present']} | ✖ غاب: ${stats['absent']} | 📝 بعذر: ${stats['excused']}\nنسبة الحضور: ${stats['rate']}%\n';
      if ((stats['hifzPages'] as double) > 0) r += '📖 إجمالي الحفظ المقبول: ${stats['hifzPages']} صفحة\n';
      if ((stats['reviewPages'] as double) > 0) r += '🔁 إجمالي المراجعة المقبولة: ${stats['reviewPages']} صفحة\n';
      r += '──────────────\n';
    }
    final totalPresent = active.fold(0, (sum, st) => sum + (statsMap[st.id]['present'] as int));
    final totalHifz = active.fold(0.0, (sum, st) => sum + (statsMap[st.id]['hifzPages'] as double));
    final totalReview = active.fold(0.0, (sum, st) => sum + (statsMap[st.id]['reviewPages'] as double));
    r += 'إجمالي الحضور: $totalPresent\n';
    if (totalHifz > 0) r += '📖 إجمالي حفظ الحلقة: $totalHifz صفحة\n';
    if (totalReview > 0) r += '🔁 إجمالي مراجعة الحلقة: $totalReview صفحة\n';
    r += '━━━━━━━━━━━━━━';
    Clipboard.setData(ClipboardData(text: r));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ تم نسخ التقرير الشهري', style: TextStyle(fontFamily: 'Tajawal')), backgroundColor: AppTheme.primary, behavior: SnackBarBehavior.floating));
  }

  void _copyStudentReport(BuildContext context, dynamic st, Map stats) {
    var r = '━━━━━━━━━━━━━━\n📋 التقرير الشهري للطالب\n👤 ${st.name}\n📅 $_periodLabel\n━━━━━━━━━━━━━━\n✔ الحضور: ${stats['present']} يوم\n✖ الغياب: ${stats['absent']} يوم\n📝 الغياب بعذر: ${stats['excused']} يوم\n📊 نسبة الحضور: ${stats['rate']}%\n──────────────\n';
    if ((stats['hifzPages'] as double) > 0) r += '📖 إجمالي الحفظ المقبول: ${stats['hifzPages']} صفحة\n';
    if ((stats['reviewPages'] as double) > 0) r += '🔁 إجمالي المراجعة المقبولة: ${stats['reviewPages']} صفحة\n';
    if ((stats['hifzList'] as List).isNotEmpty) { r += '\nتفاصيل الحفظ:\n'; for (int i = 0; i < (stats['hifzList'] as List).length; i++) r += '${i + 1}. ${stats['hifzList'][i]}\n'; }
    if ((stats['reviewList'] as List).isNotEmpty) { r += '\nتفاصيل المراجعة:\n'; for (int i = 0; i < (stats['reviewList'] as List).length; i++) r += '${i + 1}. ${stats['reviewList'][i]}\n'; }
    r += '━━━━━━━━━━━━━━';
    Clipboard.setData(ClipboardData(text: r));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ تم نسخ تقرير ${st.name}', style: const TextStyle(fontFamily: 'Tajawal')), backgroundColor: AppTheme.primary, behavior: SnackBarBehavior.floating));
  }
}

class _SegBtn extends StatelessWidget {
  final List<String> items; final int selected; final ValueChanged<int> onChanged;
  const _SegBtn({required this.items, required this.selected, required this.onChanged});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(14)),
    child: Row(children: List.generate(items.length, (i) => Expanded(child: GestureDetector(onTap: () => onChanged(i),
      child: AnimatedContainer(duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(color: selected == i ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(10),
          boxShadow: selected == i ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)] : []),
        child: Text(items[i], textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w900, color: selected == i ? AppTheme.primary : Colors.grey)),
      ))))));
}

class _MiniStat extends StatelessWidget {
  final String label, value; final Color color;
  const _MiniStat(this.label, this.value, this.color);
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: color.withOpacity(0.07), borderRadius: BorderRadius.circular(12)),
    child: Column(children: [Text(value, style: TextStyle(fontFamily: 'Tajawal', fontSize: 18, fontWeight: FontWeight.w900, color: color)), Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w700), textAlign: TextAlign.center)]));
}

class _Tag extends StatelessWidget {
  final String text; final Color color;
  const _Tag(this.text, this.color);
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
    child: Text(text, style: TextStyle(fontFamily: 'Tajawal', fontSize: 10, fontWeight: FontWeight.w900, color: color)));
}
