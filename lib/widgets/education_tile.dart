import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/education.dart';

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
