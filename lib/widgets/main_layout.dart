import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import '../services/theme_provider.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  PopupMenuItem<String> _buildPopupMenuItem(BuildContext context, String title, IconData icon, String route) {
    return PopupMenuItem<String>(
      value: route,
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.inter(
              color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87),
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => context.go('/'),
            child: Text('FEDTECH', style: GoogleFonts.inter(fontWeight: FontWeight.w900, letterSpacing: 4, color: isDark ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87) : Colors.black87)),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.white.withAlpha(12)),
          ),
        ),
        actions: [
          if (isDesktop) ...[
            _HoverNavButton(title: 'Accueil', onTap: () => context.go('/')),
            SizedBox(width: 8),
            _HoverNavButton(title: 'Expertises', onTap: () => context.go('/expertises')),
            SizedBox(width: 8),
            _HoverNavButton(title: 'Compétences', onTap: () => context.go('/competences')),
            SizedBox(width: 8),
            PopupMenuButton<String>(
              tooltip: '',
              offset: const Offset(0, 50),
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0A0E21).withAlpha(242) : Colors.white.withAlpha(242),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary.withAlpha(76),
                  width: 1.5,
                ),
              ),
              onSelected: (route) => context.go(route),
              itemBuilder: (context) => [
                _buildPopupMenuItem(context, 'Logiciels', Icons.rocket_launch_outlined, '/realisations'),
                _buildPopupMenuItem(context, 'IoT & Conceptions', Icons.developer_board_outlined, '/iot'),
              ],
              child: const _HoverNavButton(
                title: 'Réalisations',
                onTap: null,
              ),
            ),
            SizedBox(width: 8),
            _HoverNavButton(title: 'Carrière', onTap: () => context.go('/carriere')),
            SizedBox(width: 8),
            _HoverNavButton(title: 'Formation', onTap: () => context.go('/formation')),
            SizedBox(width: 8),
            _HoverNavButton(title: 'Documents', onTap: () => context.go('/documents')),
            SizedBox(width: 8),
            _HoverNavButton(title: 'Contact', onTap: () => context.go('/contact')),
            SizedBox(width: 24),
          ] else
            PopupMenuButton<String>(
              icon: Icon(Icons.menu, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87)),
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0A0E21).withAlpha(242) : Colors.white.withAlpha(242),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary.withAlpha(76),
                  width: 1.5,
                ),
              ),
              onSelected: (route) {
                if (route == '/realisations_choice') {
                  _showRealisationsBottomSheet(context);
                } else {
                  context.go(route);
                }
              },
              itemBuilder: (context) => [
                _buildPopupMenuItem(context, 'Accueil', Icons.home_outlined, '/'),
                _buildPopupMenuItem(context, 'Expertises', Icons.bolt_outlined, '/expertises'),
                _buildPopupMenuItem(context, 'Compétences', Icons.code_outlined, '/competences'),
                _buildPopupMenuItem(context, 'Réalisations', Icons.rocket_launch_outlined, '/realisations_choice'),
                _buildPopupMenuItem(context, 'Carrière', Icons.work_history_outlined, '/carriere'),
                _buildPopupMenuItem(context, 'Formation', Icons.school_outlined, '/formation'),
                _buildPopupMenuItem(context, 'Documents', Icons.picture_as_pdf_outlined, '/documents'),
                _buildPopupMenuItem(context, 'Contact', Icons.contact_mail_outlined, '/contact'),
              ],
            ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: isDark ? (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87) : Colors.black87),
                  onPressed: () => themeProvider.toggleTheme(),
                ),
                SizedBox(width: 8),
                Tooltip(
                  message: 'SYSTEM',
                  child: GestureDetector(
                    onLongPress: () => context.go('/admin'),
                    child: IconButton(
                      icon: Icon(Icons.terminal_outlined, color: isDark ? (Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26) : Colors.black26, size: 20),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Access Restricted: Authorization Required', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 10)),
                            backgroundColor: Colors.transparent,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const BackgroundDecorations(),
          child,
        ],
      ),
    );
  }

  void _showRealisationsBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF0A0E21) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choisissez une catégorie',
                  style: GoogleFonts.orbitron(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: Icon(Icons.rocket_launch_outlined, color: theme.colorScheme.secondary),
                  title: Text('Logiciels & Applications', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/realisations');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.developer_board_outlined, color: theme.colorScheme.secondary),
                  title: Text('IoT & Systèmes Embarqués', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/iot');
                  },
                ),
              ],
            ),
          ),
        );
      },
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

class _HoverNavButton extends StatefulWidget {
  final String title;
  final VoidCallback? onTap;

  const _HoverNavButton({
    super.key,
    required this.title,
    this.onTap,
  });

  @override
  State<_HoverNavButton> createState() => _HoverNavButtonState();
}

class _HoverNavButtonState extends State<_HoverNavButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
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
