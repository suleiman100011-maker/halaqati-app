import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/models.dart';
import '../widgets/app_header.dart';
import '../theme/app_theme.dart';

class SessionScreen extends StatelessWidget {
  const SessionScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final active = s.students.where((x) => x.active).toList();
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: AppHeader(halakaName: s.settings.halakaName, teacherName: s.settings.teacherName)),
        SliverPadding(padding: const EdgeInsets.all(16), sliver: SliverList(delegate: SliverChildListDelegate([
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('تسجيل الجلسة اليومية', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, fontSize: 18)),
            TextButton.icon(
              onPressed: () => _copyReport(context, s),
              icon: const Icon(Icons.share_rounded, size: 14, color: AppTheme.primary),
              label: const Text('نسخ', style: TextStyle(fontFamily: 'Tajawal', color: AppTheme.primary, fontWeight: FontWeight.w900, fontSize: 12)),
            ),
          ]),
          const SizedBox(height: 8),
          if (active.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(40), child: Column(children: [Text('👤', style: TextStyle(fontSize: 48)), SizedBox(height: 8), Text('لا يوجد طلاب نشطون', style: TextStyle(fontFamily: 'Tajawal', color: Colors.grey))]))),
          ...active.map((st) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _SessionCard(student: st))),
          const SizedBox(height: 80),
        ]))),
      ]),
    );
  }

  void _copyReport(BuildContext context, AppState s) {
    final today = s.todayKey;
    final todaySess = s.sessions.where((r) => r.date == today && r.status != 'none').toList();
    if (todaySess.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا توجد بيانات مسجلة اليوم', style: TextStyle(fontFamily: 'Tajawal')), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating)); return; }
    final active = s.students.where((st) => st.active).toList();
    var r = '━━━━━━━━━━━━━━\n📖 تقرير حلقة (${s.settings.halakaName})\n📅 ${DateTime.now().toLocal()}\n━━━━━━━━━━━━━━\n';
    for (int i = 0; i < active.length; i++) {
      final st = active[i]; final rec = s.getTodaySession(st.id); final pts = s.getTodayPoints(st.id);
      r += '${i + 1}️⃣ ${st.name}\n';
      if (rec == null || rec.status == 'none' || rec.status == 'absent') { r += '✖ غائب (غير مبرر)\n'; }
      else if (rec.status == 'absent_excused') { r += '✖ غائب (بعذر)\n'; }
      else {
        r += '✔ حاضر\n';
        if (rec.hifzAmount > 0 || rec.hifzNote.isNotEmpty) { var hl = ''; if (rec.hifzAmount > 0) hl += '${rec.hifzAmount} صفحة'; if (rec.hifzNote.isNotEmpty) hl += '. ${rec.hifzNote}'; hl += rec.hifzCompleted ? '. ✅' : '. 🔄'; r += '📌 الحفظ: $hl\n'; }
        if (rec.reviewAmount > 0 || rec.reviewNote.isNotEmpty) { var rl = ''; if (rec.reviewAmount > 0) rl += '${rec.reviewAmount} صفحة'; if (rec.reviewNote.isNotEmpty) rl += '. ${rec.reviewNote}'; rl += rec.reviewCompleted ? '. ✅' : '. 🔄'; r += '📖 المراجعة: $rl\n'; }
        r += '⭐ تقييم: ${rec.rating}\n';
      }
      if (pts > 0) r += '🎯 نقاط اليوم: +$pts نقطة\n'; else if (pts < 0) r += '🔻 نقاط اليوم: $pts نقطة\n';
      r += '──────────────\n';
    }
    r += 'الحضور: ${s.presentToday}\nالغياب: ${s.absentToday}\n━━━━━━━━━━━━━━';
    Clipboard.setData(ClipboardData(text: r));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ تم نسخ تقرير الجلسة', style: TextStyle(fontFamily: 'Tajawal')), backgroundColor: AppTheme.primary, behavior: SnackBarBehavior.floating));
  }
}

class _SessionCard extends StatefulWidget {
  final Student student;
  const _SessionCard({required this.student});
  @override State<_SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<_SessionCard> {
  final _hifzCtrl   = TextEditingController();
  final _hifzNoteCtrl = TextEditingController();
  final _reviewCtrl = TextEditingController();
  final _reviewNoteCtrl = TextEditingController();
  bool _synced = false;

  @override void dispose() { _hifzCtrl.dispose(); _hifzNoteCtrl.dispose(); _reviewCtrl.dispose(); _reviewNoteCtrl.dispose(); super.dispose(); }

  void _sync(Session? rec) {
    if (_synced) return; _synced = true;
    if (rec != null) {
      _hifzCtrl.text    = rec.hifzAmount > 0 ? rec.hifzAmount.toString() : '';
      _hifzNoteCtrl.text  = rec.hifzNote;
      _reviewCtrl.text  = rec.reviewAmount > 0 ? rec.reviewAmount.toString() : '';
      _reviewNoteCtrl.text= rec.reviewNote;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s   = context.watch<AppState>();
    final rec = s.getTodaySession(widget.student.id);
    final pts = s.getTodayPoints(widget.student.id);
    _sync(rec);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            CircleAvatar(radius: 20, backgroundColor: AppTheme.primary.withOpacity(0.12),
              child: Text(widget.student.name[0], style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, color: AppTheme.primary))),
            const SizedBox(width: 10),
            Text(widget.student.name, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, fontSize: 15, color: AppTheme.textDark)),
          ]),
          // Points control
          Container(
            decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              GestureDetector(onTap: () => context.read<AppState>().addTx(widget.student.id, 1, 'add', 'إضافة يومية'),
                child: Container(padding: const EdgeInsets.all(7), child: const Icon(Icons.add, size: 16, color: AppTheme.primary))),
              SizedBox(width: 26, child: Center(child: Text('$pts', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, fontSize: 14, color: pts < 0 ? AppTheme.red : pts > 0 ? AppTheme.primary : Colors.grey)))),
              GestureDetector(onTap: () => context.read<AppState>().addTx(widget.student.id, -1, 'deduct', 'خصم يومي'),
                child: Container(padding: const EdgeInsets.all(7), child: const Icon(Icons.remove, size: 16, color: AppTheme.red))),
            ]),
          ),
        ]),
        const SizedBox(height: 12),
        // Status buttons
        Row(children: [
          _StatusBtn('حاضر', rec?.status == 'present', AppTheme.primary, () => context.read<AppState>().updateSessionField(widget.student.id, 'status', 'present')),
          const SizedBox(width: 6),
          _StatusBtn('غائب', rec?.status == 'absent', AppTheme.red, () => context.read<AppState>().updateSessionField(widget.student.id, 'status', 'absent')),
          const SizedBox(width: 6),
          _StatusBtn('بعذر', rec?.status == 'absent_excused', AppTheme.orange, () => context.read<AppState>().updateSessionField(widget.student.id, 'status', 'absent_excused')),
        ]),
        // Details when present
        if (rec?.status == 'present') ...[
          const SizedBox(height: 12), const Divider(height: 1),
          const SizedBox(height: 12),
          // Hifz
          _RecordField(label: '📖 الحفظ', amountCtrl: _hifzCtrl, noteCtrl: _hifzNoteCtrl,
            completed: rec!.hifzCompleted,
            onAmountChanged: (v) { final n = double.tryParse(v); context.read<AppState>().updateSessionField(widget.student.id, 'hifz_amount', n ?? 0); },
            onNoteChanged: (v) => context.read<AppState>().updateSessionField(widget.student.id, 'hifz_note', v),
            onCompletedToggle: () => context.read<AppState>().updateSessionField(widget.student.id, 'hifz_completed', !rec.hifzCompleted),
          ),
          const SizedBox(height: 10),
          // Review
          _RecordField(label: '🔁 المراجعة', amountCtrl: _reviewCtrl, noteCtrl: _reviewNoteCtrl,
            completed: rec.reviewCompleted,
            onAmountChanged: (v) { final n = double.tryParse(v); context.read<AppState>().updateSessionField(widget.student.id, 'review_amount', n ?? 0); },
            onNoteChanged: (v) => context.read<AppState>().updateSessionField(widget.student.id, 'review_note', v),
            onCompletedToggle: () => context.read<AppState>().updateSessionField(widget.student.id, 'review_completed', !rec.reviewCompleted),
          ),
          const SizedBox(height: 10),
          // Rating
          Row(children: [
            const Text('التقييم: ', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w700)),
            DropdownButton<String>(
              value: rec.rating.isEmpty ? 'جيد' : rec.rating,
              underline: const SizedBox(), isDense: true,
              style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, color: AppTheme.primary, fontSize: 13),
              onChanged: (v) { if (v != null) context.read<AppState>().updateSessionField(widget.student.id, 'rating', v); },
              items: ['ممتاز', 'جيد جداً', 'جيد', 'يحتاج متابعة'].map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontFamily: 'Tajawal')))).toList(),
            ),
          ]),
        ],
      ]),
    );
  }
}

class _RecordField extends StatelessWidget {
  final String label; final TextEditingController amountCtrl, noteCtrl;
  final bool completed; final VoidCallback onCompletedToggle;
  final ValueChanged<String> onAmountChanged, onNoteChanged;
  const _RecordField({required this.label, required this.amountCtrl, required this.noteCtrl, required this.completed, required this.onCompletedToggle, required this.onAmountChanged, required this.onNoteChanged});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: completed ? const Color(0xFFECFDF5) : const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(16),
      border: Border.all(color: completed ? AppTheme.primary.withOpacity(0.3) : Colors.grey.shade100)),
    child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
        GestureDetector(onTap: onCompletedToggle, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: completed ? AppTheme.primary : Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(completed ? Icons.check_circle_rounded : Icons.cancel_rounded, size: 12, color: completed ? Colors.white : Colors.grey),
            const SizedBox(width: 4),
            Text(completed ? 'مقبول' : 'إعادة', style: TextStyle(fontFamily: 'Tajawal', fontSize: 10, fontWeight: FontWeight.w900, color: completed ? Colors.white : Colors.grey)),
          ]))),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        SizedBox(width: 80, child: TextField(controller: amountCtrl, onChanged: onAmountChanged, keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.primary),
          decoration: InputDecoration(hintText: '0', hintStyle: const TextStyle(color: Colors.grey), contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            suffix: const Text('ص', style: TextStyle(fontFamily: 'Tajawal', fontSize: 10, color: Colors.grey))))),
        const SizedBox(width: 8),
        Expanded(child: TextField(controller: noteCtrl, onChanged: onNoteChanged,
          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: AppTheme.textDark),
          decoration: InputDecoration(hintText: 'ملاحظة سريعة... (مثال: من سورة عم)', hintStyle: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Colors.grey), contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)))),
      ]),
    ]),
  );
}

class _StatusBtn extends StatelessWidget {
  final String label; final bool active; final Color color; final VoidCallback onTap;
  const _StatusBtn(this.label, this.active, this.color, this.onTap);
  @override
  Widget build(BuildContext context) => Expanded(child: GestureDetector(onTap: onTap, child: AnimatedContainer(
    duration: const Duration(milliseconds: 150),
    padding: const EdgeInsets.symmetric(vertical: 9),
    decoration: BoxDecoration(color: active ? color : Colors.grey[100], borderRadius: BorderRadius.circular(12)),
    child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, fontSize: 12, color: active ? Colors.white : Colors.grey)),
  )));
}
