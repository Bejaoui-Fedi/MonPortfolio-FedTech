import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' as ui;
import 'package:flutter_animate/flutter_animate.dart';
import '../models/project.dart';
import 'project_details_dialog.dart';

class ProjectCard extends StatefulWidget {
  final Project project;
  const ProjectCard({super.key, required this.project});

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  Offset _mousePosition = Offset.zero;

  String _getSafeImageUrl(String url) {
    if (kIsWeb && url.isNotEmpty) {
      final separator = url.contains('?') ? '&' : '?';
      return '$url${separator}cb=fedtech';
    }
    return url;
  }

  void _showProjectDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ProjectDetailsDialog(project: widget.project),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (event) => setState(() {
        _isHovered = true;
        _mousePosition = event.localPosition;
      }),
      onHover: (event) => setState(() => _mousePosition = event.localPosition),
      onExit: (_) => setState(() => _isHovered = false),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          
          final dx = _mousePosition.dx - (width / 2);
          final dy = _mousePosition.dy - (height / 2);
          
          final tiltX = _isHovered ? (-dy / (height / 2)) * 0.05 : 0.0;
          final tiltY = _isHovered ? (dx / (width / 2)) * 0.05 : 0.0;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(tiltX)
              ..rotateY(tiltY),
            transformAlignment: Alignment.center,
            child: GestureDetector(
              onTap: () => _showProjectDetails(context),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withAlpha(_isHovered ? 30 : 10),
                      blurRadius: _isHovered ? 20 : 10,
                      spreadRadius: -5,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      // Background Image
                      Positioned.fill(
                        child: AnimatedScale(
                          scale: _isHovered ? 1.05 : 1.0,
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOut,
                          child: widget.project.imageUrl.isEmpty
                              ? Container(color: isDark ? Colors.grey[900] : Colors.grey[200])
                              : Image.network(
                                  _getSafeImageUrl(widget.project.imageUrl),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: isDark ? Colors.grey[900] : Colors.grey[200],
                                      child: Center(
                                        child: Icon(Icons.broken_image, color: isDark ? Colors.white24 : Colors.black26, size: 40),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),

                      // Overlay Gradient (Always dark for readability of text on image)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withAlpha(120),
                                Colors.black.withAlpha(200),
                              ],
                              stops: const [0.4, 0.7, 1.0],
                            ),
                          ),
                        ),
                      ),

                      // Content Panel
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withAlpha(_isHovered ? 220 : 160),
                              ],
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.project.title,
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: width < 300 ? 16 : 20,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (widget.project.videoUrl != null)
                                    Icon(Icons.play_circle_outline, color: theme.colorScheme.primary, size: 20),
                                ],
                              ),
                              if (widget.project.computedDuration != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.timer_outlined, color: theme.colorScheme.secondary, size: 12),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.project.computedDuration!,
                                      style: GoogleFonts.inter(
                                        color: theme.colorScheme.secondary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 8),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 300),
                                child: SizedBox(
                                  height: _isHovered ? null : 0,
                                  child: Column(
                                    children: [
                                      Text(
                                        widget.project.description,
                                        style: TextStyle(
                                          color: Colors.white.withAlpha(180),
                                          fontSize: 12,
                                          height: 1.4,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                  ),
                                ),
                              ),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: widget.project.technologies.take(3).map((tech) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withAlpha(isDark ? 40 : 180),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: theme.colorScheme.primary.withAlpha(80)),
                                    ),
                                    child: Text(
                                      tech.toUpperCase(),
                                      style: GoogleFonts.inter(
                                        color: isDark ? theme.colorScheme.primary : Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Subtle Glow Border
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: _isHovered ? theme.colorScheme.primary.withAlpha(80) : Colors.white.withAlpha(10),
                              width: 1,
                            ),
                          ),
                        ),
                      ),

                      // Interactive Inkwell
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _showProjectDetails(context),
                            splashColor: theme.colorScheme.primary.withAlpha(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }
}
