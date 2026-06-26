import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/portfolio_service.dart';

class StudyDocumentsView extends StatelessWidget {
  const StudyDocumentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final portfolio = context.watch<PortfolioService>();
    final sortedDocs = [...portfolio.studyDocuments]
      ..sort((a, b) {
        final dateA = a.startDate ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = b.startDate ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateB.compareTo(dateA); // décroissant : plus récent en premier
      });
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DOCUMENTS D\'ÉTUDE',
                style: GoogleFonts.orbitron(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary,
                  letterSpacing: 2,
                ),
              ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
              const SizedBox(height: 16),
              Text(
                'Consultez mes ressources, présentations et documents académiques.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.black87,
                  height: 1.6,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 48),

              if (sortedDocs.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Text(
                      'Aucun document disponible pour le moment.',
                      style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms)
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedDocs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final doc = sortedDocs[index];
                    return _DocumentCard(
                      title: doc.title,
                      description: doc.description ?? '',
                      type: doc.type,
                      fileUrl: doc.fileUrl,
                      startDate: doc.startDate,
                      endDate: doc.endDate,
                      isDark: isDark,
                      theme: theme,
                    ).animate().fadeIn(delay: (400 + index * 100).ms).slideY(begin: 0.1);
                  },
                ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentCard extends StatefulWidget {
  final String title;
  final String description;
  final String type;
  final String fileUrl;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isDark;
  final ThemeData theme;

  const _DocumentCard({
    required this.title,
    required this.description,
    required this.type,
    required this.fileUrl,
    this.startDate,
    this.endDate,
    required this.isDark,
    required this.theme,
  });

  @override
  State<_DocumentCard> createState() => _DocumentCardState();
}

class _DocumentCardState extends State<_DocumentCard> {
  bool _isHovered = false;

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'ppt':
      case 'pptx': return Icons.slideshow;
      case 'doc':
      case 'docx': return Icons.description;
      case 'zip':
      case 'rar': return Icons.folder_zip;
      default: return Icons.insert_drive_file;
    }
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'pdf': return Colors.redAccent;
      case 'ppt':
      case 'pptx': return Colors.orangeAccent;
      case 'doc':
      case 'docx': return Colors.blueAccent;
      case 'zip':
      case 'rar': return Colors.amber;
      default: return widget.theme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: widget.isDark 
              ? (_isHovered ? widget.theme.colorScheme.primary.withAlpha(20) : const Color(0xFF0A0E21).withAlpha(150))
              : (_isHovered ? widget.theme.colorScheme.primary.withAlpha(10) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered 
                ? widget.theme.colorScheme.primary 
                : (widget.isDark ? widget.theme.colorScheme.primary.withAlpha(50) : Colors.grey.withAlpha(50)),
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.theme.colorScheme.primary.withAlpha(widget.isDark ? 50 : 20),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ]
              : [
                  if (!widget.isDark)
                    BoxShadow(
                      color: Colors.black.withAlpha(5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () async {
              final type = widget.type.toLowerCase();
              // Pour les fichiers PPT, DOC, etc. on utilise Google Docs Viewer
              final needsViewer = ['ppt', 'pptx', 'doc', 'docx'].contains(type);
              final viewUrl = needsViewer
                  ? 'https://docs.google.com/viewer?url=${Uri.encodeComponent(widget.fileUrl)}'
                  : widget.fileUrl;

              final uri = Uri.parse(viewUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Impossible d\'ouvrir ce fichier.')),
                  );
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _getColorForType(widget.type).withAlpha(widget.isDark ? 30 : 20),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      _getIconForType(widget.type),
                      color: _getColorForType(widget.type),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: GoogleFonts.orbitron(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: widget.isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (widget.startDate != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.endDate != null
                                ? '${_fmt(widget.startDate!)} → ${_fmt(widget.endDate!)}'
                                : '${_fmt(widget.startDate!)} → En cours',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: widget.theme.colorScheme.primary.withAlpha(200),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        if (widget.description.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            widget.description,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: widget.isDark ? Colors.white70 : Colors.black54,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
