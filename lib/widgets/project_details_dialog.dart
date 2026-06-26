import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui' as ui;
import '../models/project.dart';

class ProjectDetailsDialog extends StatelessWidget {
  final Project project;

  const ProjectDetailsDialog({super.key, required this.project});

  String _getSafeImageUrl(String url) {
    if (kIsWeb && url.isNotEmpty) {
      final separator = url.contains('?') ? '&' : '?';
      return '$url${separator}cb=fedtech';
    }
    return url;
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : size.width * 0.15,
        vertical: isMobile ? 40 : size.height * 0.1,
      ),
      child: Stack(
        children: [
          // Glassmorphism Background
          ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0E21).withAlpha(180),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: const Color(0xFF00E5FF).withAlpha(50),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFBD00FF).withAlpha(30),
                      blurRadius: 40,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Project Image Header
                    _buildHeader(context),
                    
                    // Project Content
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTitle(),
                            const SizedBox(height: 16),
                            _buildTechStack(),
                            const SizedBox(height: 24),
                            _buildDescription(),
                            const SizedBox(height: 32),
                            _buildActions(context),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Close Button
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack).fadeIn(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        image: project.imageUrl.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(_getSafeImageUrl(project.imageUrl)),
                fit: BoxFit.cover,
              )
            : null,
        color: Colors.grey[900],
      ),
      child: project.imageUrl.isEmpty
          ? const Center(child: Icon(Icons.image, color: Colors.white24, size: 64))
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF0A0E21).withAlpha(180),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PROJECT DETAILS',
          style: GoogleFonts.orbitron(
            color: const Color(0xFF00E5FF),
            fontSize: 12,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          project.title,
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (project.computedDuration != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: Color(0xFFBD00FF), size: 16),
              const SizedBox(width: 6),
              Text(
                'DURÉE : ${project.computedDuration}',
                style: GoogleFonts.orbitron(
                  color: const Color(0xFFBD00FF),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTechStack() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: project.technologies.map((tech) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFBD00FF).withAlpha(30),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFBD00FF).withAlpha(100)),
          ),
          child: Text(
            tech,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
    ).animate().fadeIn(delay: 200.ms).slideX();
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ABOUT THE PROJECT',
          style: GoogleFonts.orbitron(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          project.description,
          style: TextStyle(
            color: Colors.white.withAlpha(200),
            fontSize: 16,
            height: 1.6,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        if (project.githubUrl != null && project.githubUrl!.isNotEmpty)
          Expanded(
            child: _buildActionButton(
              label: 'GITHUB REPO',
              icon: Icons.code,
              color: const Color(0xFF00E5FF),
              onPressed: () => _launchUrl(context, project.githubUrl!),
            ),
          ),
        if (project.githubUrl != null && project.githubUrl!.isNotEmpty && 
            project.liveUrl != null && project.liveUrl!.isNotEmpty)
          const SizedBox(width: 16),
        if (project.liveUrl != null && project.liveUrl!.isNotEmpty)
          Expanded(
            child: _buildActionButton(
              label: 'LIVE DEMO',
              icon: Icons.launch,
              color: const Color(0xFFBD00FF),
              onPressed: () => _launchUrl(context, project.liveUrl!),
            ),
          ),
        if (project.videoUrl != null && project.videoUrl!.isNotEmpty) ...[
          const SizedBox(width: 16),
          Expanded(
            child: _buildActionButton(
              label: 'WATCH VIDEO',
              icon: Icons.play_circle_outline,
              color: const Color(0xFFFF00E5),
              onPressed: () => _launchUrl(context, project.videoUrl!),
            ),
          ),
        ],
      ],
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [color.withAlpha(50), color.withAlpha(20)],
        ),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
