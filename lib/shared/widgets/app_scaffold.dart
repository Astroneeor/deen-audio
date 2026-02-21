import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../features/library/ui/player_bar.dart';
import 'sidebar.dart';

/// Shell widget that wraps every screen with the sidebar on the left,
/// main content in the centre, and the persistent [PlayerBar] at the bottom.
class AppScaffold extends StatelessWidget {
  final Widget child;

  const AppScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                const Sidebar(),
                const VerticalDivider(width: 1, color: AppColors.divider),
                Expanded(child: child),
              ],
            ),
          ),
          const PlayerBar(),
        ],
      ),
    );
  }
}
