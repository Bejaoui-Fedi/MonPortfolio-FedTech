import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;
import '../services/portfolio_service.dart';
import '../models/skill.dart';

class CompetencesView extends StatelessWidget {
  const CompetencesView({super.key});

  // Categorize skills automatically
  static Map<String, List<Skill>> _categorizeSkills(List<Skill> skills) {
    final Map<String, List<String>> categoryMapping = {
      'Frontend': ['html', 'css', 'js', 'javascript', 'typescript', 'react', 'angular', 'vue', 'flutter', 'flutterflow', 'dart', 'fxml', 'javafx', 'twig'],
      'Backend': ['php', 'python', 'java', 'symfony', 'laravel', 'django', 'node', 'express', 'spring'],
      'Database': ['mysql', 'postgresql', 'postgres', 'mongodb', 'sqlite', 'supabase', 'firebase'],
      'DevOps & Tools': ['git', 'docker', 'kubernetes', 'aws', 'linux', 'bash'],
      'Hardware & IoT': ['arduino', 'raspberry', 'altium', 'iot', 'embedded'],
      'Mobile': ['android', 'ios', 'kotlin', 'swift'],
    };

    final Map<String, List<Skill>> result = {};
    final List<Skill> uncategorized = [];

    for (final skill in skills) {
      final cleanName = skill.name.trim().toLowerCase();
      bool found = false;
      for (final entry in categoryMapping.entries) {
        for (final keyword in entry.value) {
          if (cleanName.contains(keyword)) {
            result.putIfAbsent(entry.key, () => []);
            result[entry.key]!.add(skill);
            found = true;
            break;
          }
        }
        if (found) break;
      }
      if (!found) uncategorized.add(skill);
    }

    if (uncategorized.isNotEmpty) {
      result['Autres'] = uncategorized;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<PortfolioService>(
      builder: (context, portfolio, _) {
        final categories = _categorizeSkills(portfolio.skills);
        final totalSkills = portfolio.skills.length;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 100, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero header with counter
              _buildHeader(context, totalSkills, isDark, theme),
              const SizedBox(height: 48),

              // Category sections
              ...categories.entries.toList().asMap().entries.map((mapEntry) {
                final catIndex = mapEntry.key;
                final category = mapEntry.value.key;
                final skills = mapEntry.value.value;
                return _buildCategorySection(context, category, skills, catIndex, isDark, theme);
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, int totalSkills, bool isDark, ThemeData theme) {
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
                  theme.colorScheme.primary.withAlpha(20),
                  theme.colorScheme.secondary.withAlpha(10),
                ]
              : [
                  theme.colorScheme.primary.withAlpha(12),
                  theme.colorScheme.secondary.withAlpha(8),
                ],
        ),
        border: Border.all(
          color: theme.colorScheme.primary.withAlpha(isDark ? 40 : 25),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 500;
          return isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildCounterWidget(totalSkills, isDark, theme),
                    const SizedBox(height: 20),
                    _buildHeaderText(isDark, theme, true),
                  ],
                )
              : Row(
                  children: [
                    _buildCounterWidget(totalSkills, isDark, theme),
                    const SizedBox(width: 32),
                    Expanded(child: _buildHeaderText(isDark, theme, false)),
                  ],
                );
        },
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1);
  }

  Widget _buildCounterWidget(int count, bool isDark, ThemeData theme) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withAlpha(50),
            theme.colorScheme.secondary.withAlpha(30),
          ],
        ),
        border: Border.all(color: theme.colorScheme.primary.withAlpha(80), width: 2),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withAlpha(30),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$count',
            style: GoogleFonts.orbitron(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.primary,
            ),
          ),
          Text(
            'SKILLS',
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ],
      ),
    ).animate().scale(delay: 200.ms, duration: 500.ms, curve: Curves.easeOutBack);
  }

  Widget _buildHeaderText(bool isDark, ThemeData theme, bool centered) {
    return Column(
      crossAxisAlignment: centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          'COMPÉTENCES',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Technologies et outils que je maîtrise',
          textAlign: centered ? TextAlign.center : TextAlign.left,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: isDark ? Colors.white54 : Colors.black45,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection(BuildContext context, String category, List<Skill> skills, int catIndex, bool isDark, ThemeData theme) {
    final IconData categoryIcon = _getCategoryIcon(category);

    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(isDark ? 25 : 15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(categoryIcon, color: theme.colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                category.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withAlpha(40),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(isDark ? 20 : 12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.primary.withAlpha(40)),
                ),
                child: Text(
                  '${skills.length}',
                  style: GoogleFonts.orbitron(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: (catIndex * 100).ms).slideX(begin: -0.05),
          const SizedBox(height: 20),
          // Skills grid
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: skills.asMap().entries.map((entry) {
              final i = entry.key;
              final skill = entry.value;
              return _PremiumSkillChip(skill: skill, index: i, categoryDelay: catIndex * 100);
            }).toList(),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Frontend':
        return Icons.web_outlined;
      case 'Backend':
        return Icons.dns_outlined;
      case 'Database':
        return Icons.storage_outlined;
      case 'DevOps & Tools':
        return Icons.build_outlined;
      case 'Hardware & IoT':
        return Icons.developer_board_outlined;
      case 'Mobile':
        return Icons.phone_iphone_outlined;
      default:
        return Icons.auto_awesome_outlined;
    }
  }
}

class _PremiumSkillChip extends StatefulWidget {
  final Skill skill;
  final int index;
  final int categoryDelay;

  const _PremiumSkillChip({required this.skill, required this.index, required this.categoryDelay});

  @override
  State<_PremiumSkillChip> createState() => _PremiumSkillChipState();
}

class _PremiumSkillChipState extends State<_PremiumSkillChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final logoUrl = widget.skill.resolvedLogoUrl;
    final delay = (widget.categoryDelay + widget.index * 40).ms;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 110,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        transform: _isHovered
            ? (Matrix4.identity()..translate(0.0, -4.0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: _isHovered
              ? theme.colorScheme.primary.withAlpha(isDark ? 35 : 20)
              : (isDark ? Colors.white.withAlpha(6) : Colors.white),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isHovered
                ? theme.colorScheme.primary.withAlpha(180)
                : theme.colorScheme.primary.withAlpha(isDark ? 30 : 20),
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: [
            if (_isHovered)
              BoxShadow(
                color: theme.colorScheme.primary.withAlpha(30),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            if (!isDark)
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 0 : 5),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo container — white background for max clarity
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: _isHovered ? 56 : 48,
              height: _isHovered ? 56 : 48,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withAlpha(_isHovered ? 40 : 15),
                    blurRadius: _isHovered ? 12 : 6,
                    spreadRadius: _isHovered ? 2 : 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withAlpha(12),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: logoUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: logoUrl.toLowerCase().endsWith('.svg')
                          ? SvgPicture.network(
                              logoUrl,
                              fit: BoxFit.contain,
                              placeholderBuilder: (_) => _buildPlaceholder(theme),
                            )
                          : Image.network(
                              logoUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.code,
                                size: 24,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                    )
                  : Icon(
                      Icons.bolt_outlined,
                      size: 24,
                      color: theme.colorScheme.primary,
                    ),
            ),
            const SizedBox(height: 10),
            // Name
            Text(
              widget.skill.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _isHovered
                    ? theme.colorScheme.primary
                    : (isDark ? Colors.white.withAlpha(200) : Colors.black87),
                letterSpacing: 0.3,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: delay, duration: 300.ms).scale(delay: delay, begin: const Offset(0.9, 0.9), duration: 300.ms);
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 1.5,
        color: theme.colorScheme.primary,
      ),
    );
  }
}
