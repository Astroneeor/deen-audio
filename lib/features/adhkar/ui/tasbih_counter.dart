import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Full-screen tasbih counter dialog.
/// Show via [showTasbihCounter].
void showTasbihCounter(BuildContext context) {
  showGeneralDialog<void>(
    context: context,
    barrierColor: AppColors.background.withValues(alpha: 0.95),
    barrierDismissible: false,
    transitionDuration: const Duration(milliseconds: 200),
    transitionBuilder: (_, anim, __, child) => FadeTransition(
      opacity: anim,
      child: child,
    ),
    pageBuilder: (ctx, _, __) => const _TasbihPage(),
  );
}

class _TasbihPage extends StatefulWidget {
  const _TasbihPage();
  @override
  State<_TasbihPage> createState() => _TasbihPageState();
}

class _TasbihPageState extends State<_TasbihPage>
    with SingleTickerProviderStateMixin {
  int _count = 0;
  int _target = 33;
  bool _reached = false;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  static const _presets = [33, 99, 1000];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _increment() {
    setState(() {
      _count++;
      _reached = _count >= _target;
    });
    _pulseCtrl.forward(from: 0);
  }

  void _reset() {
    setState(() {
      _count = 0;
      _reached = false;
    });
  }

  void _setTarget(int t) {
    setState(() {
      _target = t;
      _count = 0;
      _reached = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_count / _target).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: _reached ? null : _increment,
        behavior: HitTestBehavior.opaque,
        child: SizedBox.expand(
          child: Column(
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    color: AppColors.textMuted,
                    iconSize: 22,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),

              const Spacer(),

              // Count display
              ScaleTransition(
                scale: _pulseAnim,
                child: Text(
                  '$_count',
                  style: TextStyle(
                    fontSize: 96,
                    fontWeight: FontWeight.w300,
                    color: _reached ? AppColors.gold : AppColors.textPrimary,
                    letterSpacing: -4,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.gold),
                    minHeight: 3,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                _reached ? 'Complete! Tap reset to continue.' : 'Tap anywhere to count',
                style: TextStyle(
                  color: _reached ? AppColors.gold : AppColors.textMuted,
                  fontSize: 13,
                ),
              ),

              const Spacer(),

              // Target + reset controls
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 40, 48),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Target presets
                    for (final t in _presets) ...[
                      _TargetChip(
                        label: t == 1000 ? '∞' : '$t',
                        selected: _target == t,
                        onTap: () => _setTarget(t),
                      ),
                      const SizedBox(width: 8),
                    ],
                    const SizedBox(width: 8),
                    // Reset
                    TextButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Reset'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textMuted,
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TargetChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TargetChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.gold.withValues(alpha: 0.15)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? AppColors.gold : Colors.transparent),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.gold : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
