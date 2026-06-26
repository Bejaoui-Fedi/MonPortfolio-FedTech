import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/skill.dart';

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
