import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final int count;
  final String countLabel;

  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.countLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  theme.colorScheme.secondary.withAlpha(20),
                  theme.colorScheme.primary.withAlpha(10),
                ]
              : [
                  theme.colorScheme.secondary.withAlpha(12),
                  theme.colorScheme.primary.withAlpha(8),
                ],
        ),
        border: Border.all(
          color: theme.colorScheme.secondary.withAlpha(isDark ? 40 : 25),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 500;
          return isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildCounterWidget(isDark, theme),
                    const SizedBox(height: 20),
                    _buildHeaderText(isDark, true),
                  ],
                )
              : Row(
                  children: [
                    _buildCounterWidget(isDark, theme),
                    const SizedBox(width: 32),
                    Expanded(child: _buildHeaderText(isDark, false)),
                  ],
                );
        },
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildCounterWidget(bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.secondary.withAlpha(isDark ? 20 : 15),
        border: Border.all(
          color: theme.colorScheme.secondary.withAlpha(isDark ? 50 : 30),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.secondary.withAlpha(20),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count.toString(),
            style: GoogleFonts.orbitron(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.secondary,
            ),
          ),
          Text(
            countLabel,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderText(bool isDark, bool center) {
    return Column(
      crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.orbitron(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            color: isDark ? Colors.white : Colors.black87,
            shadows: isDark ? [
              Shadow(color: Colors.white.withAlpha(50), blurRadius: 10),
            ] : [],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: center ? TextAlign.center : TextAlign.left,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: isDark ? Colors.white70 : Colors.black54,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
