import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../widgets/app_header.dart';
import '../theme/app_theme.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});
  @override State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _search = '';
  String _filter = 'all';
  String _sort   = 'name';
  bool _adding   = false;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    var list = [...s.students];
    if (_search.isNotEmpty) list = list.where((st) => st.name.contains(_search)).toList();
    if (_filter == 'active')   list = list.where((st) => st.active).toList();
    if (_filter == 'inactive') list = list.where((st) => !st.active).toList();
    list.sort((a, b) {
      if (_sort == 'points_desc') return b.totalPoints.compareTo(a.totalPoints);
      if (_sort == 'points_asc')  return a.totalPoints.compareTo(b.totalPoints);
      return a.name.compareTo(b.name);
    });

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: AppHeader(halakaName: s.settings.halakaName, teacherName: s.settings.teacherName)),
        SliverPadding(padding: const EdgeInsets.all(16), sliver: SliverList(delegate: SliverChildListDelegate([
          // Add form
          Container(padding: const EdgeInsets.all(18), decoration: AppTheme.cardDecoration(), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('إضافة طالب جديد', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(controller: _nameCtrl, style: const TextStyle(fontFamily: 'Tajawal'), decoration: const InputDecoration(hintText: 'اسم الطالب الكامل...')),
            const SizedBox(height: 8),
            TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone, textDirection: TextDirection.ltr, style: const TextStyle(fontFamily: 'Tajawal'), decoration: const InputDecoration(hintText: 'رقم ولي الأمر (اختياري)')),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: _adding ? null : () async {
                final name = _nameCtrl.text.trim(); if (name.isEmpty) return;
                setState(() => _adding = true);
                await context.read<AppState>().addStudent(name, _phoneCtrl.text.trim());
                _nameCtrl.clear(); _phoneCtrl.clear(); setState(() => _adding = false);
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ تم إضافة الطالب', style: TextStyle(fontFamily: 'Tajawal')), backgroundColor: AppTheme.primary, behavior: SnackBarBehavior.floating));
              },
              child: Text(_adding ? 'جاري الإضافة...' : 'إضافة الطالب', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900)),
            )),
          ])),
          const SizedBox(height: 16),

          // Search
          TextField(onChanged: (v) => setState(() => _search = v),
            style: const TextStyle(fontFamily: 'Tajawal'),
            decoration: InputDecoration(hintText: 'ابحث باسم الطالب...', prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey), fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none), filled: true)),
          const SizedBox(height: 10),

          // Filters
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
            ...[{'k':'all','l':'الكل'},{'k':'active','l':'🟢 نشط'},{'k':'inactive','l':'⛔ غير نشط'}].map((f) => Padding(padding: const EdgeInsets.only(left: 6), child: _Chip(f['l']!, _filter == f['k']!, AppTheme.primary, () => setState(() => _filter = f['k']!)))),
            Container(width: 1, height: 24, color: Colors.grey.shade200, margin: const EdgeInsets.symmetric(horizontal: 6)),
            ...[{'k':'name','l':'أ-ي'},{'k':'points_desc','l':'⬆ النقاط'},{'k':'points_asc','l':'⬇ النقاط'}].map((f) => Padding(padding: const EdgeInsets.only(left: 6), child: _Chip(f['l']!, _sort == f['k']!, AppTheme.blue, () => setState(() => _sort = f['k']!)))),
          ])),
          const SizedBox(height: 12),

          Text('قائمة الطلاب (${list.length})', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 8),
          if (list.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('لا يوجد طلاب مطابقون', style: TextStyle(fontFamily: 'Tajawal', color: Colors.grey)))),
          ...list.map((st) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Container(
            padding: const EdgeInsets.all(14), decoration: AppTheme.cardDecoration(radius: 20),
            child: Row(children: [
              CircleAvatar(radius: 22, backgroundColor: st.active ? AppTheme.primary.withOpacity(0.12) : Colors.grey[100],
                child: Text(st.name[0], style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, color: st.active ? AppTheme.primary : Colors.grey))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(st.name, style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, fontSize: 14, color: st.active ? AppTheme.textDark : Colors.grey, decoration: st.active ? null : TextDecoration.lineThrough)),
                if (st.phone.isNotEmpty) Text(st.phone, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Colors.grey)),
              ])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), margin: const EdgeInsets.only(left: 6),
                decoration: BoxDecoration(color: const Color(0xFFFEF9C3), borderRadius: BorderRadius.circular(20)),
                child: Text('⭐ ${st.totalPoints}', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF854D0E)))),
              IconButton(onPressed: () => context.read<AppState>().toggleActive(st.id),
                icon: Icon(st.active ? Icons.pause_circle_rounded : Icons.play_circle_rounded, color: st.active ? Colors.orange : AppTheme.primary)),
              IconButton(onPressed: () async {
                final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
                  title: const Text('حذف الطالب', style: TextStyle(fontFamily: 'Tajawal')),
                  content: Text('هل أنت متأكد من حذف ${st.name}؟', style: const TextStyle(fontFamily: 'Tajawal')),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Tajawal'))),
                    ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('حذف', style: TextStyle(fontFamily: 'Tajawal'))),
                  ],
                ));
                if (ok == true && context.mounted) context.read<AppState>().deleteStudent(st.id);
              }, icon: const Icon(Icons.delete_rounded, color: Colors.red)),
            ]),
          ))),
          const SizedBox(height: 80),
        ]))),
      ]),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label; final bool active; final Color color; final VoidCallback onTap;
  const _Chip(this.label, this.active, this.color, this.onTap);
  @override Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: active ? color : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: active ? color : Colors.grey.shade200)),
    child: Text(label, style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w900, color: active ? Colors.white : Colors.grey)),
  ));
}
