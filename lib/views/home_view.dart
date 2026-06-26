import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;
import '../services/portfolio_service.dart';
import '../services/theme_provider.dart';
import '../widgets/section_header.dart';
import '../widgets/service_card.dart';
import '../widgets/project_card.dart';
import '../widgets/experience_tile.dart';
import '../models/education.dart';
import '../models/iot_design.dart';
import '../models/skill.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HeroSection().animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack),
          SizedBox(height: 40),
          Center(
            child: const StatsBar().animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
          ),
          SizedBox(height: 80),
        ],
      ),
    );
  }
}

class BackgroundDecorations extends StatelessWidget {
  const BackgroundDecorations({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withAlpha(isDark ? 15 : 10),
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          left: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.secondary.withAlpha(isDark ? 15 : 10),
            ),
          ),
        ),
      ],
    );
  }
}

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Consumer<PortfolioService>(
          builder: (context, portfolio, _) {
            final isMobile = constraints.maxWidth < 600;
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;

            if (isMobile) {
              return Column(
                children: [
                  ProfilePicture(size: 160, imageUrl: portfolio.profileImageUrl)
                    .animate().fadeIn(duration: 800.ms).scale(curve: Curves.easeOutBack),
                  SizedBox(height: 32),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 30, height: 2, color: theme.colorScheme.primary),
                          SizedBox(width: 8),
                          const HeroWelcomeText(),
                          SizedBox(width: 8),
                          Container(width: 30, height: 2, color: theme.colorScheme.primary),
                        ],
                      ),
                      SizedBox(height: 24),
                      Text(
                        portfolio.name,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: isDark ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87) : Colors.black87,
                          height: 1.1,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        portfolio.headline,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                          fontSize: 20,
                        ),
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
                      SizedBox(height: 32),
                      Text(
                        portfolio.bio,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16, 
                          color: isDark ? (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87) : Colors.black87, 
                          height: 1.6
                        ),
                      ).animate().fadeIn(delay: 600.ms),
                    ],
                  ),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(width: 40, height: 2, color: theme.colorScheme.primary),
                          SizedBox(width: 8),
                          const HeroWelcomeText(),
                        ],
                      ),
                      SizedBox(height: 24),
                      Text(
                        portfolio.name,
                        style: GoogleFonts.inter(
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                          color: isDark ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87) : Colors.black87,
                          height: 1.1,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        portfolio.headline,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                          fontSize: 28,
                        ),
                      ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0),
                      SizedBox(height: 32),
                      Text(
                        portfolio.bio,
                        style: TextStyle(
                          fontSize: 16, 
                          color: isDark ? (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87) : Colors.black87, 
                          height: 1.6
                        ),
                      ).animate().fadeIn(delay: 600.ms),
                    ],
                  ),
                ),
                SizedBox(width: 60),
                ProfilePicture(size: 220, imageUrl: portfolio.profileImageUrl)
                  .animate().fadeIn(duration: 800.ms).scale(curve: Curves.easeOutBack),
              ],
            );
          },
        );
      },
    );
  }
}

class HeroWelcomeText extends StatelessWidget {
  const HeroWelcomeText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'WELCOME TO MY DIGITAL WORLD',
      style: GoogleFonts.inter(
        color: Theme.of(context).colorScheme.primary,
        letterSpacing: 2,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class ProfilePicture extends StatelessWidget {
  final double size;
  final String imageUrl;
  const ProfilePicture({super.key, required this.size, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glow
          Container(
            width: size * 0.8,
            height: size * 0.8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withAlpha(50),
                  blurRadius: 50,
                  spreadRadius: 10,
                ),
                BoxShadow(
                  color: secondaryColor.withAlpha(50),
                  blurRadius: 50,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          
          // Outer HUD Ring 1
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryColor.withAlpha(30),
                width: 1,
              ),
            ),
          ).animate(onPlay: (c) => c.repeat()).rotate(duration: 10.seconds),

          // Outer HUD Ring 2 (Dashed/Arc)
          SizedBox(
            width: size * 0.95,
            height: size * 0.95,
            child: CustomPaint(
              painter: CyberRingPainter(color: primaryColor, strokeWidth: 2),
            ),
          ).animate(onPlay: (c) => c.repeat()).rotate(duration: 15.seconds, begin: 1, end: 0),

          // Profile Image with Border
          Container(
            width: size * 0.8,
            height: size * 0.8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryColor,
                width: 2,
              ),
              image: DecorationImage(
                image: imageUrl.isEmpty 
                  ? const NetworkImage('https://placehold.co/400.png') as ImageProvider
                  : (imageUrl.startsWith('http') 
                      ? NetworkImage(imageUrl) as ImageProvider
                      : AssetImage(imageUrl)),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withAlpha(100),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
          
          // Scanning Effect Overlay
          ClipRRect(
            borderRadius: BorderRadius.circular(size),
            child: Container(
              width: size * 0.8,
              height: size * 0.8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    primaryColor.withAlpha(50),
                    Colors.transparent,
                  ],
                  stops: const [0.4, 0.5, 0.6],
                ),
              ),
            ).animate(onPlay: (c) => c.repeat()).moveY(begin: -size, end: size, duration: 3.seconds),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 1.seconds).scale(begin: const Offset(0.8, 0.8));
  }
}

class CyberRingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  CyberRingPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withAlpha(200)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rect = Offset.zero & size;
    
    // Top-left arc
    canvas.drawArc(rect, 3.14 + 0.5, 1.0, false, paint);
    // Bottom-right arc
    canvas.drawArc(rect, 0.5, 1.0, false, paint);
    
    // Add small dots
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width, size.height / 2), 2, paint);
    canvas.drawCircle(Offset(0, size.height / 2), 2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
class StatsBar extends StatelessWidget {
  const StatsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PortfolioService>(
      builder: (context, portfolio, _) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0A0E21).withAlpha(160) : Colors.white.withAlpha(200),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: theme.colorScheme.primary.withAlpha(isDark ? 80 : 50),
                    width: 1.5,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withAlpha(isDark ? 40 : 20),
                      Colors.transparent,
                      theme.colorScheme.secondary.withAlpha(isDark ? 40 : 20),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withAlpha(isDark ? 30 : 15),
                      blurRadius: 40,
                      spreadRadius: -10,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;
                    return Wrap(
                      alignment: WrapAlignment.spaceEvenly,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: 40,
                      spacing: isMobile ? 20 : 40,
                      children: [
                        _StatItem(
                          title: 'PROJETS RÉALISÉS',
                          value: portfolio.projects.length,
                          icon: Icons.rocket_launch_rounded,
                          delay: 0,
                        ),
                        if (!isMobile) _buildDivider(theme),
                        _StatItem(
                          title: 'EXPERTISES',
                          value: portfolio.services.length,
                          icon: Icons.bolt_rounded,
                          delay: 100,
                        ),
                        if (!isMobile) _buildDivider(theme),
                        _StatItem(
                          title: 'COMPÉTENCES',
                          value: portfolio.skills.length,
                          icon: Icons.code_rounded,
                          delay: 200,
                        ),
                        if (!isMobile) _buildDivider(theme),
                        _StatItem(
                          title: 'CONCEPTIONS IoT',
                          value: portfolio.iotDesigns.length,
                          icon: Icons.developer_board_rounded,
                          delay: 300,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Container(
      height: 60,
      width: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            theme.colorScheme.primary.withAlpha(100),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatefulWidget {
  final String title;
  final int value;
  final IconData icon;
  final int delay;

  const _StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.delay,
  });

  @override
  State<_StatItem> createState() => _StatItemState();
}

class _StatItemState extends State<_StatItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        transform: Matrix4.translationValues(0, _isHovered ? -10 : 0, 0),
        child: Container(
          width: 140,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.all(_isHovered ? 18 : 14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withAlpha(_isHovered ? 150 : 40),
                      theme.colorScheme.secondary.withAlpha(_isHovered ? 150 : 20),
                    ],
                  ),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withAlpha(100),
                            blurRadius: 20,
                            spreadRadius: 2,
                          )
                        ]
                      : [],
                  border: Border.all(
                    color: theme.colorScheme.primary.withAlpha(_isHovered ? 200 : 50),
                    width: _isHovered ? 2 : 1,
                  ),
                ),
                child: Icon(
                  widget.icon,
                  color: _isHovered ? Colors.white : theme.colorScheme.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: widget.value),
                duration: const Duration(seconds: 2),
                curve: Curves.easeOutQuart,
                builder: (context, value, child) {
                  return Text(
                    '+$value',
                    style: GoogleFonts.inter(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black87,
                      height: 1,
                      shadows: _isHovered ? [
                        Shadow(
                          color: theme.colorScheme.primary.withAlpha(100),
                          blurRadius: 10,
                        )
                      ] : null,
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: _isHovered 
                      ? theme.colorScheme.primary 
                      : (isDark ? Colors.white60 : Colors.black54),
                ),
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: widget.delay.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack);
  }
}

class SkillTag extends StatefulWidget {
  final Skill skill;
  const SkillTag({super.key, required this.skill});

  @override
  State<SkillTag> createState() => _SkillTagState();
}

class _SkillTagState extends State<SkillTag> {
  bool _isHovered = false;
  String? _logoUrl;
  bool _hasFallbackTriggered = false;

  @override
  void initState() {
    super.initState();
    _logoUrl = widget.skill.resolvedLogoUrl;
  }

  @override
  void didUpdateWidget(SkillTag oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.skill.logoUrl != widget.skill.logoUrl || oldWidget.skill.name != widget.skill.name) {
      setState(() {
        _logoUrl = widget.skill.resolvedLogoUrl;
        _hasFallbackTriggered = false;
      });
    }
  }

  /// Builds the appropriate logo widget: SvgPicture for .svg URLs,
  /// Image.network for raster (PNG/JPG) URLs.
  Widget _buildLogoWidget() {
    final url = _logoUrl!;
    final isSvg = url.toLowerCase().endsWith('.svg');

    if (isSvg) {
      return SvgPicture.network(
        url,
        width: 20,
        height: 20,
        fit: BoxFit.contain,
        placeholderBuilder: (context) => SizedBox(
          width: 20,
          height: 20,
          child: Center(
            child: SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      );
    }

    return Image.network(
      url,
      width: 20,
      height: 20,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        if (!_hasFallbackTriggered) {
          final fallback = Skill.getAutomaticLogo(widget.skill.name);
          if (fallback != null && fallback != _logoUrl) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _logoUrl = fallback;
                  _hasFallbackTriggered = true;
                });
              }
            });
          }
        }
        return Icon(
          Icons.code,
          color: Theme.of(context).colorScheme.primary,
          size: 16,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.15 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _isHovered ? Theme.of(context).colorScheme.primary.withAlpha(38) : Theme.of(context).colorScheme.primary.withAlpha(12),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: _isHovered ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary.withAlpha(51),
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withAlpha(_isHovered ? 30 : 5),
                blurRadius: _isHovered ? 15 : 10,
                spreadRadius: _isHovered ? 2 : 0,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_logoUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: _buildLogoWidget(),
                ),
                SizedBox(width: 8),
              ] else ...[
                Icon(
                  Icons.bolt_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 16,
                ),
                SizedBox(width: 8),
              ],
              Text(
                widget.skill.name,
                style: GoogleFonts.inter(
                  color: _isHovered ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87) : Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate(target: _isHovered ? 1 : 0).shimmer(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26));
  }
}

class EducationTile extends StatefulWidget {
  final Education education;
  const EducationTile({super.key, required this.education});

  @override
  State<EducationTile> createState() => _EducationTileState();
}

class _EducationTileState extends State<EducationTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _isHovered ? Colors.white.withAlpha(12) : Colors.white.withAlpha(8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isHovered ? Theme.of(context).colorScheme.secondary.withAlpha(100) : Colors.white.withAlpha(25),
              ),
              boxShadow: [
                if (_isHovered)
                  BoxShadow(
                    color: Theme.of(context).colorScheme.secondary.withAlpha(20),
                    blurRadius: 20,
                  ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (_isHovered ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary).withAlpha(25),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: (_isHovered ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary).withAlpha(51),
                    ),
                  ),
                  child: Icon(
                    Icons.school,
                    color: _isHovered ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary,
                    size: 20,
                  ),
                ).animate(target: _isHovered ? 1 : 0).shimmer(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26)),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.education.degree,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _isHovered ? Theme.of(context).colorScheme.secondary : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.education.school,
                        style: TextStyle(
                          color: _isHovered ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.education.period,
                        style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white38 : Colors.black38), fontSize: 12),
                      ),
                      SizedBox(height: 12),
                      Text(
                        widget.education.description,
                        style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white60 : Colors.black54), fontSize: 14, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ContactSection extends StatefulWidget {
  const ContactSection({super.key});

  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSending = false;

  Future<void> _sendMessage(PortfolioService portfolio) async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSending = true);

    final success = await portfolio.sendMessage(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _messageController.text.trim(),
    );

    if (mounted) {
      setState(() => _isSending = false);
      if (success) {
        _nameController.clear();
        _emailController.clear();
        _messageController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TRANSMISSION RÉUSSIE',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).colorScheme.primary,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Votre message a été envoyé avec succès.',
                          style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: const Color(0xFF0A0E21).withAlpha(230),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(20),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'envoi. Réessayez.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PortfolioService>(
      builder: (context, portfolio, _) {
        final contact = portfolio.contact;
        final email = contact['email'] ?? '';
        final phone = contact['phone'] ?? '';
        final linkedin = contact['linkedin'] ?? '';
        final github = contact['github'] ?? '';

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Contact links bar
                if (email.isNotEmpty || phone.isNotEmpty || linkedin.isNotEmpty || github.isNotEmpty)
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      if (email.isNotEmpty) _ContactChip(icon: Icons.email_outlined, label: email, url: 'mailto:$email', color: Theme.of(context).colorScheme.primary),
                      if (phone.isNotEmpty) _ContactChip(icon: Icons.phone_outlined, label: phone, url: 'tel:$phone', color: Theme.of(context).colorScheme.secondary),
                      if (linkedin.isNotEmpty) _ContactChip(icon: Icons.link, label: 'LinkedIn', url: linkedin, color: Theme.of(context).colorScheme.primary),
                      if (github.isNotEmpty) _ContactChip(icon: Icons.code, label: 'GitHub', url: github, color: Theme.of(context).colorScheme.secondary),
                    ],
                  ),
                SizedBox(height: 32),

                // Form card with glassmorphism
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withAlpha(8) : Colors.black.withAlpha(5),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Theme.of(context).colorScheme.primary.withAlpha(60), width: 1),
                        boxShadow: [
                          BoxShadow(color: Theme.of(context).colorScheme.primary.withAlpha(10), blurRadius: 30, spreadRadius: 5),
                        ],
                      ),
                      child: isWide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 2, child: _buildForm(portfolio)),
                                SizedBox(width: 48),
                                Expanded(child: _buildSideInfo()),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildForm(portfolio),
                                SizedBox(height: 32),
                                _buildSideInfo(),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildForm(PortfolioService portfolio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
          ).createShader(bounds),
          child: Text('Envoyer un Message', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87))),
        ),
        SizedBox(height: 8),
        Text('Je vous répondrai dans les plus brefs délais', style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withAlpha(153) : Colors.black54, fontSize: 14)),
        SizedBox(height: 28),
        _buildGlassInput(_nameController, 'Nom Complet', Icons.person_outline),
        SizedBox(height: 16),
        _buildGlassInput(_emailController, 'Email', Icons.email_outlined),
        SizedBox(height: 16),
        _buildGlassInput(_messageController, 'Message', Icons.message_outlined, maxLines: 5),
        SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: _isSending ? null : () => _sendMessage(portfolio),
            icon: _isSending
                ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                : Icon(Icons.send_rounded, color: Colors.black, size: 20),
            label: Text(
              _isSending ? 'ENVOI...' : 'ENVOYER LE MESSAGE',
              style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              disabledBackgroundColor: Theme.of(context).colorScheme.primary.withAlpha(100),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 8,
              shadowColor: Theme.of(context).colorScheme.primary.withAlpha(80),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSideInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Disponibilité', style: GoogleFonts.inter(color: Theme.of(context).colorScheme.primary, fontSize: 14, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        _buildInfoRow(Icons.circle, 'Disponible pour des projets', const Color(0xFF00FF88)),
        SizedBox(height: 10),
        _buildInfoRow(Icons.schedule_outlined, 'Réponse sous 24h', (Theme.of(context).brightness == Brightness.dark ? Colors.white60 : Colors.black54)),
        SizedBox(height: 10),
        _buildInfoRow(Icons.language_outlined, 'Français / Anglais', (Theme.of(context).brightness == Brightness.dark ? Colors.white60 : Colors.black54)),
        SizedBox(height: 32),
        Text('Basé à', style: GoogleFonts.inter(color: Theme.of(context).colorScheme.secondary, fontSize: 14, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        _buildInfoRow(Icons.location_on_outlined, 'Tunisie', (Theme.of(context).brightness == Brightness.dark ? Colors.white60 : Colors.black54)),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        SizedBox(width: 10),
        Flexible(child: Text(text, style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87), fontSize: 14))),
      ],
    );
  }

  Widget _buildGlassInput(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87), fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withAlpha(180) : Colors.black54, fontSize: 13),
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary.withAlpha(153), size: 20),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withAlpha(8) : Colors.black.withAlpha(8),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withAlpha(40) : Colors.black.withAlpha(30)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _ContactChip extends StatefulWidget {
  final IconData icon;
  final String label;
  final String url;
  final Color color;
  const _ContactChip({required this.icon, required this.label, required this.url, required this.color});

  @override
  State<_ContactChip> createState() => _ContactChipState();
}

class _ContactChipState extends State<_ContactChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () async {
          final uri = Uri.parse(widget.url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _isHovered ? widget.color.withAlpha(30) : widget.color.withAlpha(12),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _isHovered ? widget.color : widget.color.withAlpha(60)),
            boxShadow: _isHovered ? [BoxShadow(color: widget.color.withAlpha(50), blurRadius: 10)] : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: widget.color, size: 16),
              SizedBox(width: 8),
              Text(widget.label, style: TextStyle(color: _isHovered ? widget.color : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87), fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class IoTDesignsSection extends StatelessWidget {
  const IoTDesignsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PortfolioService>(
      builder: (context, portfolio, _) {
        if (portfolio.iotDesigns.isEmpty) {
          return Center(
            child: Text('Aucune conception disponible pour le moment.', style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26))),
          );
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth < 600 ? 1 : (constraints.maxWidth < 1000 ? 2 : 3);
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 0.85,
              ),
              itemCount: portfolio.iotDesigns.length,
              itemBuilder: (context, index) {
                return IoTDesignCard(design: portfolio.iotDesigns[index])
                    .animate()
                    .fadeIn(delay: (200 * index).ms)
                    .scale(delay: (200 * index).ms);
              },
            );
          },
        );
      },
    );
  }
}

class IoTDesignCard extends StatefulWidget {
  final IoTDesign design;
  const IoTDesignCard({super.key, required this.design});

  @override
  State<IoTDesignCard> createState() => _IoTDesignCardState();
}

class _IoTDesignCardState extends State<IoTDesignCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withAlpha(8) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered ? Theme.of(context).colorScheme.primary.withAlpha(150) : (Theme.of(context).brightness == Brightness.dark ? Colors.white.withAlpha(25) : Colors.black.withAlpha(20)),
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withAlpha(20),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Header
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        widget.design.thumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withAlpha(12) : Colors.grey.shade200,
                          child: Icon(Icons.memory, color: Theme.of(context).colorScheme.primary, size: 40),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withAlpha(150),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary.withAlpha(200),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'IoT PROJECT',
                            style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Content
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.design.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: _isHovered ? Theme.of(context).colorScheme.primary : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          widget.design.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withAlpha(153) : Colors.black54, fontSize: 11, height: 1.4),
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _DownloadButton(
                              icon: Icons.architecture,
                              label: 'PROTEUS',
                              url: widget.design.proteusUrl,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: _DownloadButton(
                              icon: Icons.code,
                              label: 'CODE',
                              url: widget.design.codeUrl,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DownloadButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;
  final Color color;

  const _DownloadButton({
    required this.icon,
    required this.label,
    required this.url,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: url.isEmpty ? null : () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: url.isEmpty ? (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12) : color.withAlpha(25),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: url.isEmpty ? (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12) : color.withAlpha(100)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: url.isEmpty ? (Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26) : color, size: 14),
            SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                color: url.isEmpty ? (Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26) : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87),
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectsSection extends StatefulWidget {
  const ProjectsSection({super.key});

  @override
  State<ProjectsSection> createState() => _ProjectsSectionState();
}

class _ProjectsSectionState extends State<ProjectsSection> {
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'IoT',
    'Embarqué',
    'Infrastructure Réseaux',
    'Dev Mobile',
    'Dev Web',
    'Dev Logiciel'
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<PortfolioService>(
      builder: (context, portfolio, _) {
        final filteredProjects = _selectedCategory == 'All'
            ? portfolio.projects
            : portfolio.projects.where((p) => p.category == _selectedCategory).toList();

        return Column(
          children: [
            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedCategory = category),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected 
                              ? Theme.of(context).colorScheme.primary.withAlpha(38) 
                              : (Theme.of(context).brightness == Brightness.dark ? Colors.white.withAlpha(12) : Colors.black.withAlpha(8)),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isSelected 
                                ? Theme.of(context).colorScheme.primary 
                                : (Theme.of(context).brightness == Brightness.dark ? Colors.white.withAlpha(25) : Colors.black.withAlpha(20)),
                              width: isSelected ? 1.5 : 1,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withAlpha(30),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                            ],
                          ),
                          child: Text(
                            category.toUpperCase(),
                            style: GoogleFonts.inter(
                              color: isSelected ? Theme.of(context).colorScheme.primary : (Theme.of(context).brightness == Brightness.dark ? Colors.white60 : Colors.black54),
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);
                }).toList(),
              ),
            ),
            SizedBox(height: 40),
            
            // Projects Grid
            if (filteredProjects.isEmpty)
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withAlpha(5) : Colors.black.withAlpha(5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(15)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_open_outlined, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26), size: 48),
                    SizedBox(height: 16),
                    Text(
                      'AUCUN PROJET DANS CETTE CATÉGORIE',
                      style: GoogleFonts.inter(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26), fontSize: 12, letterSpacing: 1),
                    ),
                  ],
                ),
              ).animate().fadeIn()
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth < 600 ? 1 : (constraints.maxWidth < 1000 ? 2 : 3);
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: filteredProjects.length,
                    itemBuilder: (context, index) {
                      return ProjectCard(project: filteredProjects[index])
                          .animate()
                          .fadeIn(delay: (100 * index).ms)
                          .scale(delay: (100 * index).ms, begin: const Offset(0.95, 0.95));
                    },
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

class _HoverNavButton extends StatefulWidget {
  final String title;
  final VoidCallback onTap;

  const _HoverNavButton({
    required this.title,
    required this.onTap,
  });

  @override
  State<_HoverNavButton> createState() => _HoverNavButtonState();
}

class _HoverNavButtonState extends State<_HoverNavButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: GoogleFonts.inter(
                  color: _isHovered ? Theme.of(context).colorScheme.primary : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  shadows: _isHovered
                      ? [
                          Shadow(
                            color: Theme.of(context).colorScheme.primary.withAlpha(204),
                            blurRadius: 10,
                          ),
                        ]
                      : [],
                ),
                child: Text(widget.title),
              ),
              SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: _isHovered ? 40 : 0,
                height: 2,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withAlpha(204),
                      blurRadius: 6,
                      spreadRadius: 1,
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

