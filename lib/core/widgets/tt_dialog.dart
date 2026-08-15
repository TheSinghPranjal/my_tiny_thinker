import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/services/audio_service.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_gradients.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';

class TTDialog extends StatelessWidget {
  const TTDialog({
    super.key,
    required this.title,
    this.message,
    this.emoji,
    this.child,
    this.primaryAction,
    this.primaryLabel = 'OK',
    this.secondaryAction,
    this.secondaryLabel,
    this.showConfetti = false,
  });

  final String title;
  final String? message;
  final String? emoji;
  final Widget? child;
  final VoidCallback? primaryAction;
  final String primaryLabel;
  final VoidCallback? secondaryAction;
  final String? secondaryLabel;
  final bool showConfetti;

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? message,
    String? emoji,
    Widget? child,
    VoidCallback? primaryAction,
    String primaryLabel = 'OK',
    VoidCallback? secondaryAction,
    String? secondaryLabel,
    bool barrierDismissible = false,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => TTDialog(
        title: title,
        message: message,
        emoji: emoji,
        primaryAction: primaryAction,
        primaryLabel: primaryLabel,
        secondaryAction: secondaryAction,
        secondaryLabel: secondaryLabel,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: AppGradients.welcomeCard,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null)
              Text(emoji!, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: context.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (child != null) ...[
              const SizedBox(height: AppSpacing.lg),
              child!,
            ],
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                if (secondaryAction != null && secondaryLabel != null) ...[
                  Expanded(
                    child: TTButton(
                      label: secondaryLabel!,
                      variant: TTButtonVariant.ghost,
                      onPressed: () {
                        Navigator.of(context).pop();
                        secondaryAction!();
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: TTButton(
                    label: primaryLabel,
                    onPressed: () {
                      Navigator.of(context).pop();
                      primaryAction?.call();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TTPauseDialog extends StatelessWidget {
  const TTPauseDialog({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onHome,
    this.onSettings,
  });

  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onHome;
  final FutureOr<void> Function()? onSettings;

  static const Color _navy = Color(0xFF24305E);
  static const Color _muted = Color(0xFF7B8AA6);
  static const Color _outline = Color(0xFFC5D4F0);
  static const Color _actionBlue = Color(0xFF3D7EFF);

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onResume,
    required VoidCallback onRestart,
    required VoidCallback onHome,
    FutureOr<void> Function()? onSettings,
  }) async {
    // Silence game BGM/SFX while paused (no sound on the pause menu).
    final audio = ProviderScope.containerOf(context).read(audioServiceProvider);
    await audio.pauseGameplayAudio();

    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0xCC1A1240),
      builder: (context) => TTPauseDialog(
        onResume: () {
          audio.resumeGameplayAudio();
          onResume();
        },
        onRestart: () {
          // Restart handlers call playGameMusic() again.
          onRestart();
        },
        onHome: () {
          audio.playHomeMusic();
          onHome();
        },
        onSettings: onSettings,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FAFD), Color(0xFFEEF3F9)],
          ),
          border: Border.all(color: const Color(0xFFE4EAF4), width: 1.4),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7B5CFF).withValues(alpha: 0.42),
              blurRadius: 36,
              spreadRadius: 2,
              offset: const Offset(0, 14),
            ),
            BoxShadow(
              color: const Color(0xFF3D7EFF).withValues(alpha: 0.16),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _PauseGlowIcon(),
            const SizedBox(height: 14),
            const _PausedTitle(),
            const SizedBox(height: 6),
            Text(
              'Take a little break!',
              style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _muted,
              ),
            ),
            const SizedBox(height: 22),
            _NeonButton(
              label: 'Home',
              icon: Icons.home_rounded,
              trailing: Icons.chevron_right_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFF7B5CFF), Color(0xFFC45CFF)],
              ),
              glow: const Color(0xFF9B6CFF),
              onPressed: () {
                Navigator.of(context).pop();
                onHome();
              },
            ),
            if (onSettings != null) ...[
              const SizedBox(height: 12),
              _OutlineButton(
                label: 'Settings',
                icon: Icons.settings_rounded,
                trailing: Icons.chevron_right_rounded,
                onPressed: () async {
                  Navigator.of(context).pop();
                  await onSettings!();
                },
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _OutlineButton(
                    label: 'Restart',
                    icon: Icons.refresh_rounded,
                    compact: true,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onRestart();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _NeonButton(
                    label: 'Resume',
                    icon: Icons.play_arrow_rounded,
                    compact: true,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2F8BFF), Color(0xFF5EC8FF)],
                    ),
                    glow: const Color(0xFF3D9BFF),
                    onPressed: () {
                      Navigator.of(context).pop();
                      onResume();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _SproutFooter(),
          ],
        ),
      ),
    );
  }
}

class _PauseGlowIcon extends StatelessWidget {
  const _PauseGlowIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      width: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8EC8FF).withValues(alpha: 0.55),
                  blurRadius: 22,
                  spreadRadius: 6,
                ),
                BoxShadow(
                  color: const Color(0xFF7B5CFF).withValues(alpha: 0.28),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.85),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFBFDFFF).withValues(alpha: 0.9),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF8B6CFF), Color(0xFF4A8CFF)],
              ),
            ),
            child: const Icon(
              Icons.pause_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const Positioned(left: 8, top: 18, child: _TinySparkle(size: 8)),
          const Positioned(right: 6, top: 22, child: _TinySparkle(size: 7)),
          const Positioned(right: 18, bottom: 10, child: _TinySparkle(size: 5)),
          const Positioned(
            left: 20,
            bottom: 14,
            child: _TinyDot(color: Color(0xFFC9B6FF)),
          ),
        ],
      ),
    );
  }
}

class _TinySparkle extends StatelessWidget {
  const _TinySparkle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _SparklePainter(const Color(0xFFC9B6FF)),
    );
  }
}

class _TinyDot extends StatelessWidget {
  const _TinyDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _SparklePainter extends CustomPainter {
  const _SparklePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final path = Path();
    for (var i = 0; i < 4; i++) {
      final a = -math.pi / 2 + i * math.pi / 2;
      final outer = Offset(c.dx + math.cos(a) * r, c.dy + math.sin(a) * r);
      final innerA = a + math.pi / 4;
      final inner = Offset(
        c.dx + math.cos(innerA) * r * 0.28,
        c.dy + math.sin(innerA) * r * 0.28,
      );
      if (i == 0) {
        path.moveTo(outer.dx, outer.dy);
      } else {
        path.lineTo(outer.dx, outer.dy);
      }
      path.lineTo(inner.dx, inner.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PausedTitle extends StatelessWidget {
  const _PausedTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: _FadeLine(left: true)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'Paused',
            style: GoogleFonts.fredoka(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: TTPauseDialog._navy,
              height: 1,
            ),
          ),
        ),
        const Expanded(child: _FadeLine(left: false)),
      ],
    );
  }
}

class _FadeLine extends StatelessWidget {
  const _FadeLine({required this.left});

  final bool left;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: left
              ? const [Color(0x007B5CFF), Color(0x667B5CFF)]
              : const [Color(0x667B5CFF), Color(0x007B5CFF)],
        ),
      ),
    );
  }
}

class _NeonButton extends StatelessWidget {
  const _NeonButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.glow,
    required this.onPressed,
    this.trailing,
    this.compact = false,
  });

  final String label;
  final IconData icon;
  final IconData? trailing;
  final Gradient gradient;
  final Color glow;
  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: glow.withValues(alpha: 0.45),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16),
            child: compact
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: Colors.white, size: 22),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: GoogleFonts.fredoka(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Icon(icon, color: Colors.white, size: 22),
                      Expanded(
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.fredoka(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Icon(
                        trailing ?? Icons.chevron_right_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.trailing,
    this.compact = false,
  });

  final String label;
  final IconData icon;
  final IconData? trailing;
  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: TTPauseDialog._outline, width: 1.4),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3D7EFF).withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 16),
            child: compact
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: TTPauseDialog._actionBlue, size: 22),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: GoogleFonts.fredoka(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: TTPauseDialog._actionBlue,
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Icon(icon, color: TTPauseDialog._actionBlue, size: 22),
                      Expanded(
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.fredoka(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: TTPauseDialog._actionBlue,
                          ),
                        ),
                      ),
                      Icon(
                        trailing ?? Icons.chevron_right_rounded,
                        color: TTPauseDialog._actionBlue,
                        size: 22,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _SproutFooter extends StatelessWidget {
  const _SproutFooter();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: _FadeLine(left: true)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(
            Icons.eco_rounded,
            size: 14,
            color: TTPauseDialog._muted.withValues(alpha: 0.55),
          ),
        ),
        const Expanded(child: _FadeLine(left: false)),
      ],
    );
  }
}
