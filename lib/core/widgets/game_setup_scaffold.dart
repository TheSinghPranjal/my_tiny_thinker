import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/widgets/glossy_play_button.dart';
import 'package:my_tiny_thinker/core/widgets/mascot_widget.dart';
import 'package:my_tiny_thinker/core/widgets/setup_meadow_background.dart';

/// Overflow-safe intro layout used by game setup / skills screens.
///
/// Keeps the back control and Play button visible, while the middle content
/// (title + skills in one glass card) scrolls on short viewports.
class GameSetupScaffold extends StatelessWidget {
  const GameSetupScaffold({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onPlay,
    this.skills = const [],
    this.skillChipColor,
    this.titleColor,
    this.subtitleColor,
    this.titleShadows,
    this.playLabel = 'Play',
    this.showMascot = false,
    this.emojiSize = 64,
    this.backButtonBackground,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onPlay;
  final List<String> skills;
  final Color? skillChipColor;
  final Color? titleColor;
  final Color? subtitleColor;
  final List<Shadow>? titleShadows;
  final String playLabel;
  final bool showMascot;
  final double emojiSize;
  final Color? backButtonBackground;

  static const Color _brown = Color(0xFF6D4C41);
  static const Color _navy = Color(0xFF3E4A59);
  static const Color _chipFill = Color(0xFFF6E4C8);
  static const Color _chipBorder = Color(0xFFB08968);

  @override
  Widget build(BuildContext context) {
    return SetupMeadowBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Material(
                  color: backButtonBackground ?? Colors.white,
                  shape: const CircleBorder(),
                  elevation: 3,
                  shadowColor: Colors.black26,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => context.pop(),
                    child: const SizedBox(
                      width: 44,
                      height: 44,
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 26,
                        color: Color(0xFF455A64),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
                              _InfoCard(
                                emoji: emoji,
                                emojiSize: emojiSize,
                                title: title,
                                subtitle: subtitle,
                                skills: skills,
                                titleColor: titleColor,
                                subtitleColor: subtitleColor,
                                chipColor: skillChipColor,
                              ),
                              if (showMascot) ...[
                                const SizedBox(height: AppSpacing.md),
                                const MascotWidget(size: 64, waving: true),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              GlossyPlayButton(label: playLabel, onPressed: onPlay),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.emoji,
    required this.emojiSize,
    required this.title,
    required this.subtitle,
    required this.skills,
    this.titleColor,
    this.subtitleColor,
    this.chipColor,
  });

  final String emoji;
  final double emojiSize;
  final String title;
  final String subtitle;
  final List<String> skills;
  final Color? titleColor;
  final Color? subtitleColor;
  final Color? chipColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.45),
                blurRadius: 16,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 36, 18, 18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.95),
                    width: 1.6,
                  ),
                ),
                child: Column(
                  children: [
                    _GradientOutlineTitle(
                      text: title,
                      fallbackColor: titleColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        color: subtitleColor ?? GameSetupScaffold._brown,
                      ),
                    ),
                    if (skills.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Skills Developed',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: GameSetupScaffold._navy,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final skill in skills)
                              _SkillPill(
                                label: skill,
                                fill: chipColor ?? GameSetupScaffold._chipFill,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: -22,
          child: Text(
            emoji,
            style: TextStyle(fontSize: emojiSize * 0.55, height: 1),
          ),
        ),
      ],
    );
  }
}

class _GradientOutlineTitle extends StatelessWidget {
  const _GradientOutlineTitle({required this.text, this.fallbackColor});

  final String text;
  final Color? fallbackColor;

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.fredoka(
      fontSize: text.length > 22 ? 26 : 32,
      fontWeight: FontWeight.w700,
      height: 1.05,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 7
              ..strokeJoin = StrokeJoin.round
              ..color = Colors.white,
          ),
        ),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              fallbackColor?.withValues(alpha: 0.95) ?? const Color(0xFFFFB74D),
              fallbackColor ?? const Color(0xFFE64A19),
            ],
          ).createShader(bounds),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: style.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _SkillPill extends StatelessWidget {
  const _SkillPill({required this.label, required this.fill});

  final String label;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: fill.a < 1 ? GameSetupScaffold._chipFill : fill,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: GameSetupScaffold._chipBorder, width: 1.2),
      ),
      child: Text(
        label,
        style: GoogleFonts.nunito(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: GameSetupScaffold._brown,
        ),
      ),
    );
  }
}
