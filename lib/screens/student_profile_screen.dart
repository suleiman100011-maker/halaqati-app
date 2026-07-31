import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class StudentProfileScreen extends StatefulWidget {
  final String studentId;
  const StudentProfileScreen({super.key, required this.studentId});
  @override State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final _ptsCtrl     = TextEditingController();
  final _noteCtrl    = TextEditingController();
  final _redeemCtrl  = TextEditingController();
  final _redeemNoteCtrl = TextEditingController();

  String _fmt(String iso) {
    final d = DateTime.parse(iso);
    return '${d.day}/${d.month}/${d.year}  ${d.hour.toString().padLeft(2,"0")}:${d.minute.toString().padLeft(2,"0")}';
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final student = s.students.where((x) => x.id == widget.studentId).firstOrNull;
    if (student == null) return const Scaffold(body: Center(child: Text('الطالب غير موجود', style: TextStyle(fontFamily: 'Tajawal'))));
    final points = student.totalPoints;
    final stars  = s.getStars(points);
    final txList = s.transactions.where((t) => t.studentId == widget.studentId).toList();

    return Directionality(textDirection: TextDirection.rtl, child: Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        title: Text('ملف ${student.name}', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, color: Colors.white)),
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white)),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // Stars card
        Container(padding: const EdgeInsets.all(24), decoration: AppTheme.greenCard(), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(student.name, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, color: Colors.white, fontSize: 20)),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('رصيد النجوم المتاح', style: TextStyle(fontFamily: 'Tajawal', color: Colors.white.withOpacity(0.8), fontSize: 12)),
              Row(children: [
                Text('$stars', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, color: Colors.white, fontSize: 42)),
                const SizedBox(width: 8),
                const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 30),
              ]),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('إجمالي النقاط', style: TextStyle(fontFamily: 'Tajawal', color: Colors.white.withOpacity(0.8), fontSize: 11)),
              Text('$points نقطة', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, color: Colors.white, fontSize: 22)),
            ]),
          ]),
        ])),
        const SizedBox(height: 14),

        // Add/deduct
        Container(padding: const EdgeInsets.all(16), decoration: AppTheme.cardDecoration(), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [Icon(Icons.bolt_rounded, color: AppTheme.primary, size: 18), SizedBox(width: 6), Text('إضافة / خصم نقاط', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, fontSize: 14))]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: _ptsCtrl, keyboardType: TextInputType.number, textDirection: TextDirection.ltr, style: const TextStyle(fontFamily: 'Tajawal'), decoration: const InputDecoration(hintText: 'عدد النقاط'))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: _noteCtrl, style: const TextStyle(fontFamily: 'Tajawal'), decoration: const InputDecoration(hintText: 'ملاحظة'))),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: ElevatedButton(
              onPressed: () async {
                final n = int.tryParse(_ptsCtrl.text); if (n == null || n <= 0) return;
                await context.read<AppState>().addTx(widget.studentId, n, 'add', _noteCtrl.text.isEmpty ? 'إضافة نقاط' : _noteCtrl.text);
                _ptsCtrl.clear(); _noteCtrl.clear();
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ تم إضافة $n نقطة', style: const TextStyle(fontFamily: 'Tajawal')), backgroundColor: AppTheme.primary, behavior: SnackBarBehavior.floating));
              },
              child: const Text('+ إضافة', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900)),
            )),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton(
              style: OutlinedButton.styleFrom(foregroundColor: AppTheme.red, side: const BorderSide(color: AppTheme.red), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              onPressed: () async {
                final n = int.tryParse(_ptsCtrl.text); if (n == null || n <= 0) return;
                await context.read<AppState>().addTx(widget.studentId, -n, 'deduct', _noteCtrl.text.isEmpty ? 'خصم نقاط' : _noteCtrl.text);
                _ptsCtrl.clear(); _noteCtrl.clear();
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم خصم $n نقطة', style: const TextStyle(fontFamily: 'Tajawal')), backgroundColor: AppTheme.red, behavior: SnackBarBehavior.floating));
              },
              child: const Text('− خصم', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900)),
            )),
          ]),
        ])),
        const SizedBox(height: 14),

        // Redeem
        Container(padding: const EdgeInsets.all(16), decoration: AppTheme.cardDecoration(), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [Icon(Icons.card_giftcard_rounded, color: AppTheme.orange, size: 18), SizedBox(width: 6), Text('صرف رحلة أو هدية', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, fontSize: 14))]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: _redeemCtrl, keyboardType: TextInputType.number, textDirection: TextDirection.ltr, style: const TextStyle(fontFamily: 'Tajawal'), decoration: InputDecoration(hintText: 'من $stars نجمة'))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: _redeemNoteCtrl, style: const TextStyle(fontFamily: 'Tajawal'), decoration: const InputDecoration(hintText: 'اسم الهدية/الرحلة'))),
          ]),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.orange),
            onPressed: () async {
              final n = int.tryParse(_redeemCtrl.text); if (n == null || n <= 0) return;
              if (n > stars) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('رصيد غير كافٍ! لديك $stars نجمة فقط', style: const TextStyle(fontFamily: 'Tajawal')), backgroundColor: AppTheme.red, behavior: SnackBarBehavior.floating)); return; }
              final note = _redeemNoteCtrl.text;
              await context.read<AppState>().addTx(widget.studentId, -(n * 10), 'redeem', 'صرف $n نجمة${note.isNotEmpty ? ": $note" : ""}');
              _redeemCtrl.clear(); _redeemNoteCtrl.clear();
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ تم صرف $n نجمة', style: const TextStyle(fontFamily: 'Tajawal')), backgroundColor: AppTheme.orange, behavior: SnackBarBehavior.floating));
            },
            child: const Text('تأكيد الصرف', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900)),
          )),
        ])),
        const SizedBox(height: 14),

        // Transactions
        Container(padding: const EdgeInsets.all(16), decoration: AppTheme.cardDecoration(), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [Icon(Icons.history_rounded, color: AppTheme.blue, size: 18), SizedBox(width: 6), Text('سجل حركات الرصيد', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, fontSize: 14))]),
          const SizedBox(height: 10),
          if (txList.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('لا يوجد حركات مسجلة', style: TextStyle(fontFamily: 'Tajawal', color: Colors.grey)))),
          ...txList.map((tx) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: tx.type == 'add' ? const Color(0xFFECFDF5) : tx.type == 'redeem' ? const Color(0xFFFFF7ED) : const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(10)),
              child: Icon(tx.type == 'add' ? Icons.add_rounded : tx.type == 'redeem' ? Icons.card_giftcard_rounded : Icons.remove_rounded, size: 16,
                color: tx.type == 'add' ? AppTheme.primary : tx.type == 'redeem' ? AppTheme.orange : AppTheme.red)),
            title: Text(tx.note.isEmpty ? 'حركة نقاط' : tx.note, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13)),
            subtitle: Text(_fmt(tx.createdDate), style: const TextStyle(fontFamily: 'Tajawal', fontSize: 10, color: Colors.grey)),
            trailing: Text('${tx.pointsChange > 0 ? "+" : ""}${tx.pointsChange} نقطة', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, color: tx.pointsChange > 0 ? AppTheme.primary : AppTheme.red, fontSize: 13)),
          )),
        ])),
        const SizedBox(height: 80),
      ]),
    ));
  }
}
