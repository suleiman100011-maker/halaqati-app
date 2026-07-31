import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const BottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const items = [
      {'icon': Icons.home_rounded, 'label': 'الرئيسية'},
      {'icon': Icons.edit_rounded, 'label': 'الجلسة'},
      {'icon': Icons.people_rounded, 'label': 'الطلاب'},
      {'icon': Icons.bar_chart_rounded, 'label': 'التقارير'},
      {'icon': Icons.settings_rounded, 'label': 'الإعدادات'},
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.10), blurRadius: 24, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final active = currentIndex == i;
              return GestureDetector(
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? AppTheme.primary.withOpacity(0.08) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(items[i]['icon'] as IconData, size: 22,
                      color: active ? AppTheme.primary : Colors.grey[400]),
                    const SizedBox(height: 3),
                    Text(items[i]['label'] as String,
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 10, fontWeight: FontWeight.w900,
                        color: active ? AppTheme.primary : Colors.grey[400])),
                  ]),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
