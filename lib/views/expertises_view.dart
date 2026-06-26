import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' as ui;
import '../services/portfolio_service.dart';
import '../models/work_service.dart';

class ExpertisesView extends StatelessWidget {
  const ExpertisesView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<PortfolioService>(
      builder: (context, portfolio, _) {
        final services = portfolio.services;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 100, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero header
              _buildHeader(context, services.length, isDark, theme),
              const SizedBox(height: 48),

              // Services grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth < 500
                      ? 1
                      : constraints.maxWidth < 900
                          ? 2
                          : 3;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: crossAxisCount == 1 ? 1.2 : (crossAxisCount == 2 ? 0.9 : 0.85),
                    ),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      return _PremiumExpertiseCard(
                        service: services[index],
                        index: index,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, int totalExpertises, bool isDark, ThemeData theme) {
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
                    _buildCounterWidget(totalExpertises, isDark, theme),
                    const SizedBox(height: 20),
                    _buildHeaderText(isDark, theme, true),
                  ],
                )
              : Row(
                  children: [
                    _buildCounterWidget(totalExpertises, isDark, theme),
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
            theme.colorScheme.secondary.withAlpha(50),
            theme.colorScheme.primary.withAlpha(30),
          ],
        ),
        border: Border.all(color: theme.colorScheme.secondary.withAlpha(80), width: 2),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.secondary.withAlpha(30),
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
              color: theme.colorScheme.secondary,
            ),
          ),
          Text(
            'EXPERT',
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
          'EXPERTISES',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Domaines de spécialisation et services proposés',
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
}

class _PremiumExpertiseCard extends StatefulWidget {
  final WorkService service;
  final int index;

  const _PremiumExpertiseCard({required this.service, required this.index});

  @override
  State<_PremiumExpertiseCard> createState() => _PremiumExpertiseCardState();
}

class _PremiumExpertiseCardState extends State<_PremiumExpertiseCard> {
  bool _isHovered = false;

  String _extractImageUrl(String url) {
    if (url.contains('google.com/imgres')) {
      try {
        final uri = Uri.parse(url);
        final imgUrl = uri.queryParameters['imgurl'];
        if (imgUrl != null) return imgUrl;
      } catch (_) {}
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final String processedUrl = _extractImageUrl(widget.service.iconName);
    final bool isImageUrl = processedUrl.startsWith('http');
    final delay = (widget.index * 120).ms;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        transform: _isHovered
            ? (Matrix4.identity()..translate(0.0, -8.0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? theme.colorScheme.primary.withAlpha(isDark ? 40 : 30)
                  : Colors.black.withAlpha(isDark ? 20 : 10),
              blurRadius: _isHovered ? 24 : 12,
              spreadRadius: _isHovered ? 2 : 0,
              offset: Offset(0, _isHovered ? 12 : 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Background (Photo or Fallback Icon)
              if (isImageUrl)
                AnimatedScale(
                  scale: _isHovered ? 1.08 : 1.0,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  child: Image.network(
                    processedUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildFallbackIcon(theme, isDark),
                  ),
                )
              else
                _buildFallbackIcon(theme, isDark),

              // 2. Top-right gradient for number visibility
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topRight,
                      radius: 1.5,
                      colors: [
                        Colors.black.withAlpha(120),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Number indicator
              Positioned(
                top: 20,
                right: 20,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(100),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withAlpha(30)),
                      ),
                      child: Text(
                        '0${widget.index + 1}',
                        style: GoogleFonts.orbitron(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 4. Bottom Content area with Glassmorphism
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withAlpha(160),
                            Colors.black.withAlpha(240),
                          ],
                        ),
                        border: Border(
                          top: BorderSide(
                            color: Colors.white.withAlpha(20),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Accent line
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 4,
                            width: _isHovered ? 60 : 30,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.secondary,
                                ],
                              ),
                              boxShadow: _isHovered
                                  ? [
                                      BoxShadow(
                                        color: theme.colorScheme.primary.withAlpha(100),
                                        blurRadius: 8,
                                      ),
                                    ]
                                  : [],
                            ),
                          ),
                          // Title
                          Text(
                            widget.service.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Description
                          Text(
                            widget.service.description,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white70,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: delay, duration: 400.ms).slideY(delay: delay, begin: 0.1, duration: 400.ms);
  }

  Widget _buildFallbackIcon(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withAlpha(isDark ? 30 : 20),
            theme.colorScheme.secondary.withAlpha(isDark ? 15 : 10),
          ],
        ),
      ),
      child: Center(
        child: AnimatedScale(
          scale: _isHovered ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 400),
          child: Icon(
            _getIconData(widget.service.iconName),
            size: 72,
            color: theme.colorScheme.primary.withAlpha(150),
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name.toLowerCase()) {
      case 'mobile_friendly':
      case 'mobile':
      case 'phone':
      case 'app':
        return Icons.mobile_friendly;
      case 'design_services':
      case 'design':
      case 'ui':
      case 'ux':
      case 'palette':
        return Icons.palette_outlined;
      case 'code':
      case 'developer':
      case 'programming':
      case 'software':
        return Icons.code_rounded;
      case 'web':
      case 'browser':
      case 'website':
        return Icons.language_rounded;
      case 'cloud':
      case 'server':
      case 'hosting':
        return Icons.cloud_queue_rounded;
      case 'iot':
      case 'router':
      case 'hardware':
      case 'sensors':
        return Icons.settings_input_component_rounded;
      case 'security':
      case 'lock':
      case 'cyber':
      case 'shield':
        return Icons.security_rounded;
      case 'database':
      case 'sql':
      case 'storage':
      case 'data':
        return Icons.storage_rounded;
      case 'ai':
      case 'brain':
      case 'machine_learning':
      case 'smart':
        return Icons.psychology_rounded;
      case 'terminal':
      case 'console':
      case 'cli':
      case 'backend':
        return Icons.terminal_rounded;
      case 'analytics':
      case 'chart':
      case 'stats':
        return Icons.analytics_rounded;
      case 'network':
      case 'wifi':
      case 'connection':
        return Icons.network_check_rounded;
      case 'electric':
      case 'bolt':
      case 'fast':
        return Icons.bolt_rounded;
      default:
        return Icons.auto_awesome_rounded;
    }
  }
}
