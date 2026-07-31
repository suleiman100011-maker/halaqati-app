import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../widgets/app_header.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _teacherCtrl;
  bool _init = false, _saving = false;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    if (!_init) {
      _nameCtrl    = TextEditingController(text: s.settings.halakaName);
      _teacherCtrl = TextEditingController(text: s.settings.teacherName);
      _init = true;
    }

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: AppHeader(halakaName: s.settings.halakaName, teacherName: s.settings.teacherName)),
        SliverPadding(padding: const EdgeInsets.all(16), sliver: SliverList(delegate: SliverChildListDelegate([
          // Backup
          Container(padding: const EdgeInsets.all(18), decoration: AppTheme.cardDecoration(radius: 24, color: const Color(0xFFEFF6FF)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [Icon(Icons.shield_rounded, color: AppTheme.blue, size: 18), SizedBox(width: 6), Text('النسخ الاحتياطي المحلي', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, fontSize: 15, color: AppTheme.blue))]),
            const SizedBox(height: 6),
            const Text('بياناتك مخزنة محلياً على هذا الجهاز فقط. صدّر نسخة احتياطية لنقلها لجهاز آخر.',
              style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFFDE68A))),
              child: const Text('⚠️ لا يوجد نسخ سحابي — الاحتفاظ بنسخة احتياطية مسؤوليتك',
                textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFF92400E), fontWeight: FontWeight.w700))),
            const SizedBox(height: 14),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(
              onPressed: () async {
                try {
                  final json = s.exportJson();
                  final dir  = await getApplicationDocumentsDirectory();
                  final key  = DateTime.now().toIso8601String().split('T')[0];
                  final file = File('${dir.path}/halaqati_backup_$key.json');
                  await file.writeAsString(json);
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ تم حفظ النسخة:\n${file.path}', style: const TextStyle(fontFamily: 'Tajawal')), backgroundColor: AppTheme.blue, behavior: SnackBarBehavior.floating));
                } catch (e) {
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e', style: const TextStyle(fontFamily: 'Tajawal')), backgroundColor: AppTheme.red, behavior: SnackBarBehavior.floating));
                }
              },
              icon: const Icon(Icons.download_rounded),
              label: const Text('تصدير نسخة احتياطية', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900)),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.blue),
            )),
          ])),
          const SizedBox(height: 14),

          // Settings form
          Container(padding: const EdgeInsets.all(18), decoration: AppTheme.cardDecoration(), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('بيانات الحلقة', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, fontSize: 16)),
            const SizedBox(height: 16),
            const Text('اسم الحلقة', style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            TextField(controller: _nameCtrl, style: const TextStyle(fontFamily: 'Tajawal')),
            const SizedBox(height: 12),
            const Text('اسم المشرف / الشيخ', style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            TextField(controller: _teacherCtrl, style: const TextStyle(fontFamily: 'Tajawal')),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: _saving ? null : () async {
                setState(() => _saving = true);
                await context.read<AppState>().saveSettings(_nameCtrl.text.trim(), _teacherCtrl.text.trim());
                setState(() => _saving = false);
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ تم حفظ الإعدادات بنجاح', style: TextStyle(fontFamily: 'Tajawal')), backgroundColor: AppTheme.primary, behavior: SnackBarBehavior.floating));
              },
              child: Text(_saving ? 'جاري الحفظ...' : 'حفظ الإعدادات', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900)),
            )),
          ])),
          const SizedBox(height: 14),

          // Danger zone
          Container(padding: const EdgeInsets.all(16), decoration: AppTheme.cardDecoration(radius: 24, color: const Color(0xFFFFF5F5)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [Icon(Icons.delete_rounded, color: AppTheme.red, size: 18), SizedBox(width: 6), Text('منطقة الخطر', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.red))]),
            const SizedBox(height: 6),
            const Text('حذف كل البيانات المحلية نهائياً من هذا الجهاز.', style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: OutlinedButton(
              style: OutlinedButton.styleFrom(foregroundColor: AppTheme.red, side: const BorderSide(color: AppTheme.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: () async {
                final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
                  title: const Text('⚠️ تحذير!', style: TextStyle(fontFamily: 'Tajawal', color: AppTheme.red)),
                  content: const Text('سيتم حذف كل البيانات نهائياً ولا يمكن التراجع. هل أنت متأكد؟', style: TextStyle(fontFamily: 'Tajawal')),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Tajawal'))),
                    ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red), child: const Text('مسح الكل', style: TextStyle(fontFamily: 'Tajawal'))),
                  ],
                ));
                if (ok == true && context.mounted) {
                  await context.read<AppState>().clearAll();
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم مسح كل البيانات', style: TextStyle(fontFamily: 'Tajawal')), backgroundColor: AppTheme.red, behavior: SnackBarBehavior.floating));
                }
              },
              child: const Text('مسح كل البيانات', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900)),
            )),
          ])),
          const SizedBox(height: 24),
          const Center(child: Text('حَلَقَتي v2.0 · SQLite · بدون إنترنت', style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Colors.grey))),
          const SizedBox(height: 80),
        ]))),
      ]),
    );
  }
}
