import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_tiny_thinker/core/animations/bounce_animation.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_gradients.dart';

/// On-brand replacement for a plain Material [ChoiceChip], used to pick one
/// of several options on a setup screen (difficulty, theme, category, ...).
class TTOptionPill extends StatelessWidget {
  const TTOptionPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.gradient = AppGradients.bubbleBlue,
  });

  final String label;
  final bool selected;
  final Gradient gradient;
  final VoidCallback onTap;

  static const Color _navy = Color(0xFF3E4A59);

  @override
  Widget build(BuildContext context) {
    return BounceTapWrapper(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? gradient : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
          border: Border.all(
            color: selected
                ? Colors.white
                : AppColors.skyBlue.withValues(alpha: 0.35),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (selected ? AppColors.skyBlueDark : Colors.black)
                  .withValues(alpha: selected ? 0.28 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : _navy,
          ),
        ),
      ),
    );
  }
}
