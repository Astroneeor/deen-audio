import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/theme/app_colors.dart';

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}

const _navItems = [
  _NavItem(
    label: 'Library',
    icon: Icons.library_music_outlined,
    activeIcon: Icons.library_music,
    route: AppRoutes.library,
  ),
  _NavItem(
    label: 'Quran',
    icon: Icons.menu_book_outlined,
    activeIcon: Icons.menu_book,
    route: AppRoutes.quran,
  ),
  _NavItem(
    label: 'Adhkar',
    icon: Icons.auto_awesome_outlined,
    activeIcon: Icons.auto_awesome,
    route: AppRoutes.adhkar,
  ),
];

/// Left navigation sidebar — 220px wide, dark background.
class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    return Container(
      width: 220,
      color: AppColors.sidebar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 8),
          for (final item in _navItems)
            _SidebarItem(
              item: item,
              isActive: location.startsWith(item.route),
            ),
          const Spacer(),
          const Divider(height: 1, color: AppColors.divider),
          _buildSettingsButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'د',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.background,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Deen Audio',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return InkWell(
      onTap: () {
        // Settings — Phase 5
      },
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.settings_outlined, size: 18, color: AppColors.textMuted),
            SizedBox(width: 12),
            Text(
              'Settings',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final _NavItem item;
  final bool isActive;

  const _SidebarItem({required this.item, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(item.route),
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.gold.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isActive
              ? Border(
                  left: BorderSide(color: AppColors.gold, width: 2),
                )
              : const Border(
                  left: BorderSide(color: Colors.transparent, width: 2),
                ),
        ),
        child: Row(
          children: [
            Icon(
              isActive ? item.activeIcon : item.icon,
              size: 18,
              color: isActive ? AppColors.gold : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Text(
              item.label,
              style: TextStyle(
                color: isActive ? AppColors.gold : AppColors.textSecondary,
                fontSize: 14,
                fontWeight:
                    isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
