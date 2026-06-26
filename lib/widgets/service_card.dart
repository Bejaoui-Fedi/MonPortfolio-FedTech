import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui' as ui;
import 'package:google_fonts/google_fonts.dart';
import '../models/work_service.dart';

class ServiceCard extends StatefulWidget {
  final WorkService service;
  const ServiceCard({super.key, required this.service});

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool _isHovered = false;

  String _extractImageUrl(String url) {
    if (url.contains('google.com/imgres')) {
      try {
        final uri = Uri.parse(url);
        final imgUrl = uri.queryParameters['imgurl'];
        if (imgUrl != null) {
          return imgUrl;
        }
      } catch (e) {
        // Fallback to original
      }
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final String processedUrl = _extractImageUrl(widget.service.iconName);
    final bool isImageUrl = processedUrl.startsWith('http');
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? theme.colorScheme.surface : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isHovered ? theme.colorScheme.primary : (isDark ? Colors.white12 : Colors.black12),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withAlpha(_isHovered ? 20 : 0),
                blurRadius: 15,
                spreadRadius: 2,
              ),
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(isDark ? 20 : 15),
                    shape: BoxShape.circle,
                  ),
                  child: isImageUrl
                      ? Image.network(
                          processedUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                          },
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.broken_image, 
                            color: isDark ? Colors.white24 : Colors.black26, 
                            size: 24
                          ),
                        )
                      : Icon(
                          _getIconData(widget.service.iconName),
                          color: theme.colorScheme.primary,
                          size: 28,
                        ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.service.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: 0.5,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    widget.service.description,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9));
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
      case 'fire':
      case 'hot':
      case 'trending':
        return Icons.local_fire_department_rounded;
      case 'build':
      case 'tools':
      case 'maintenance':
        return Icons.build_circle_rounded;
      case 'game':
      case 'gaming':
      case 'controller':
        return Icons.videogame_asset_rounded;
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

