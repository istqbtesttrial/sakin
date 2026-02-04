import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavBar(
      {super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // 1. Determine Theme Mode
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 2. Define Dynamic Colors
    final backgroundColor = theme.cardColor;
    final unselectedColor = isDark ? Colors.white54 : Colors.grey;
    final shadowOpacity = isDark ? 0.3 : 0.08;

    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: shadowOpacity),
              blurRadius: 10,
              offset: const Offset(0, 5)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: backgroundColor,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: unselectedColor,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedHome01,
                color: unselectedColor,
              ),
              activeIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedHome01,
                color: AppTheme.primaryColor,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedTask01,
                color: unselectedColor,
              ),
              activeIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedTask01,
                color: AppTheme.primaryColor,
              ),
              label: 'Habits',
            ),
            BottomNavigationBarItem(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedTime01,
                color: unselectedColor,
              ),
              activeIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedTime01,
                color: AppTheme.primaryColor,
              ),
              label: 'Prayer',
            ),
            BottomNavigationBarItem(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedSettings01,
                color: unselectedColor,
              ),
              activeIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedSettings01,
                color: AppTheme.primaryColor,
              ),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
