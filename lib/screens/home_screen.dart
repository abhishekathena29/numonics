import 'package:flutter/material.dart';
import '../theme.dart';
import 'home_tab.dart';
import 'courses_screen.dart';
import 'mathy_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _tabs = [
    _TabSpec('Home', Icons.home_outlined, Icons.home_rounded),
    _TabSpec('Courses', Icons.menu_book_outlined, Icons.menu_book_rounded),
    _TabSpec('Mathy', Icons.auto_awesome_outlined, Icons.auto_awesome),
    _TabSpec('Progress', Icons.bar_chart_outlined, Icons.bar_chart_rounded),
    _TabSpec('Profile', Icons.person_outline, Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _index,
          children: const [
            HomeTab(),
            CoursesScreen(),
            MathyScreen(),
            ProgressScreen(),
            ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: _NavBar(
        index: _index,
        tabs: _tabs,
        onChanged: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _TabSpec {
  const _TabSpec(this.label, this.icon, this.activeIcon);
  final String label;
  final IconData icon;
  final IconData activeIcon;
}

class _NavBar extends StatelessWidget {
  const _NavBar(
      {required this.index, required this.tabs, required this.onChanged});
  final int index;
  final List<_TabSpec> tabs;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.stroke)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF17211E).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Row(
            children: List.generate(tabs.length, (i) {
              // The center tab (Mathy) gets a prominent pill treatment.
              if (i == 2) {
                return Expanded(
                  child: _CenterTab(
                    tab: tabs[i],
                    active: i == index,
                    onTap: () => onChanged(i),
                  ),
                );
              }
              return Expanded(
                child: _NavTab(
                  tab: tabs[i],
                  active: i == index,
                  onTap: () => onChanged(i),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({required this.tab, required this.active, required this.onTap});
  final _TabSpec tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.inkFaint;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(active ? tab.activeIcon : tab.icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            tab.label,
            style: TextStyle(
              color: color,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterTab extends StatelessWidget {
  const _CenterTab(
      {required this.tab, required this.active, required this.onTap});
  final _TabSpec tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 34,
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.32),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            tab.label,
            style: TextStyle(
              color: active ? AppColors.primary : AppColors.inkSoft,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
