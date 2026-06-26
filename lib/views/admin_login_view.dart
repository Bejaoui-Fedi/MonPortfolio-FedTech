import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' as ui;
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/portfolio_service.dart';
import '../widgets/main_layout.dart';

class AdminLoginView extends StatefulWidget {
  const AdminLoginView({super.key});

  @override
  State<AdminLoginView> createState() => _AdminLoginViewState();
}

class _AdminLoginViewState extends State<AdminLoginView> {
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isScanning = false;

  bool _obscurePassword = true;

  void _loginWithPassword() async {
    final authService = context.read<AuthService>();
    setState(() {
      _errorMessage = null;
    });

    final success = await authService.login(_passwordController.text);
    if (!success) {
      setState(() {
        _errorMessage = 'MOT DE PASSE INCORRECT';
      });
    }
  }

  void _authenticateBiometric() async {
    final authService = context.read<AuthService>();

    if (kIsWeb) {
      setState(() {
        _isScanning = true;
        _errorMessage = null;
      });

      final success = await authService.authenticateWithLiveCamera();
      
      if (!success) {
        if (mounted) {
          setState(() {
            _isScanning = false;
            _errorMessage = 'ÉCHEC DE LA VÉRIFICATION : Visage non reconnu';
          });
        }
      }
      return;
    }

    // Fallback for mobile (using ImagePicker or local_auth)
    final ImagePicker picker = ImagePicker();
    final portfolio = context.read<PortfolioService>();
    
    try {
      // Step 1: Open Camera to capture the face
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 70,
      );

      if (photo == null) return; // User cancelled

      setState(() {
        _isScanning = true;
        _errorMessage = null;
      });

      final authService = context.read<AuthService>();
      final success = await authService.authenticateWithBiometrics();

      if (!success) {
        if (mounted) {
          setState(() {
            _isScanning = false;
            _errorMessage = 'ÉCHEC DE LA VÉRIFICATION : Visage non reconnu';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _errorMessage = 'Erreur système lors du scan';
        });
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.white24 : Colors.black45;
    final cardBgColor = isDark ? Colors.white.withAlpha(12) : Colors.black.withAlpha(12);
    final fieldBgColor = isDark ? Colors.white.withAlpha(5) : Colors.black.withAlpha(5);
    final dividerColor = isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(20);

    return Scaffold(
      body: Stack(
        children: [
          const BackgroundDecorations(),
          Center(
              child: SingleChildScrollView(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: const Color(0xFF00E5FF).withAlpha(51)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildSecurityIcon(),
                          const SizedBox(height: 24),
                          Text(
                            'ADMIN CONSOLE',
                            style: GoogleFonts.orbitron(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 40),
                          if (!_isScanning) ...[
                            if (_errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 24.0),
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Color(0xFFBD00FF), fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            
                            // Password Field
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                hintText: 'PASSWORD',
                                hintStyle: GoogleFonts.orbitron(color: hintColor, fontSize: 12),
                                prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF00E5FF)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    color: hintColor,
                                    size: 18,
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                filled: true,
                                fillColor: fieldBgColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(color: const Color(0xFF00E5FF).withAlpha(50)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(color: const Color(0xFF00E5FF).withAlpha(50)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(color: Color(0xFF00E5FF)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _loginWithPassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00E5FF).withAlpha(30),
                                  foregroundColor: textColor,
                                  side: const BorderSide(color: Color(0xFF00E5FF)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                ),
                                child: Text('LOGIN', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(child: Divider(color: dividerColor)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text('OR', style: GoogleFonts.orbitron(color: hintColor, fontSize: 10)),
                                ),
                                Expanded(child: Divider(color: dividerColor)),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Face ID Button
                            SizedBox(
                              width: double.infinity,
                              height: 65,
                              child: ElevatedButton.icon(
                                onPressed: _authenticateBiometric,
                                icon: const Icon(Icons.face_unlock_outlined, size: 28),
                                label: Text('FACE ID', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, fontSize: 16)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFBD00FF).withAlpha(40),
                                  foregroundColor: textColor,
                                  side: const BorderSide(color: Color(0xFFBD00FF)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                ),
                              ),
                            ),
                          ] else ...[
                            Consumer<PortfolioService>(
                              builder: (context, portfolio, _) {
                                return _buildScanningAnimation(context, portfolio);
                              },
                            ),
                          ],
                          const SizedBox(height: 24),
                          TextButton(
                            onPressed: () => context.go('/'),
                            child: Text('BACK TO PORTFOLIO', style: TextStyle(color: hintColor, letterSpacing: 2, fontSize: 10)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.9, 0.9)),
            ),
          ],
        ),
    );
  }

  Widget _buildSecurityIcon() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: (_isScanning ? const Color(0xFFBD00FF) : const Color(0xFF00E5FF)).withAlpha(25),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (_isScanning ? const Color(0xFFBD00FF) : const Color(0xFF00E5FF)).withAlpha(51),
            blurRadius: 20,
          ),
        ],
      ),
      child: Icon(
        _isScanning ? Icons.face_retouching_natural : Icons.security,
        size: 48,
        color: _isScanning ? const Color(0xFFBD00FF) : const Color(0xFF00E5FF),
      ),
    ).animate(target: _isScanning ? 1 : 0).shimmer(duration: 2.seconds);
  }

  Widget _buildScanningAnimation(BuildContext context, PortfolioService portfolio) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hintColor = isDark ? Colors.white38 : Colors.black54;

    return Column(
      children: [
        SizedBox(
          height: 180,
          width: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background HUD Ring
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFBD00FF).withAlpha(30), width: 1),
                ),
              ).animate(onPlay: (c) => c.repeat()).rotate(duration: 10.seconds),

              // Profile Image with Glitch Effect
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFBD00FF), width: 2),
                  image: DecorationImage(
                    image: portfolio.profileImageUrl.isEmpty
                        ? const NetworkImage('https://placehold.co/150.png') as ImageProvider
                        : (portfolio.profileImageUrl.startsWith('http')
                            ? NetworkImage(portfolio.profileImageUrl) as ImageProvider
                            : AssetImage(portfolio.profileImageUrl)),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      const Color(0xFFBD00FF).withAlpha(100),
                      BlendMode.color,
                    ),
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat())
                .shimmer(delay: 500.ms, duration: 2.seconds, color: isDark ? Colors.white24 : Colors.black26),

              // Scanning Line
              Container(
                width: 150,
                height: 2,
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withAlpha(127),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                .moveY(begin: -60, end: 60, duration: 1.5.seconds, curve: Curves.easeInOut),
              
              // Scanning Frame
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF00E5FF).withAlpha(100), width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 3.seconds),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'ANALYZING BIOMETRICS...',
          style: GoogleFonts.orbitron(
            color: const Color(0xFF00E5FF),
            fontWeight: FontWeight.bold,
            fontSize: 10,
            letterSpacing: 2,
          ),
        ).animate(onPlay: (c) => c.repeat()).fadeIn(duration: 500.ms).fadeOut(delay: 500.ms),
        const SizedBox(height: 8),
        Text(
          'SEARCHING FOR IDENTITY...',
          style: GoogleFonts.orbitron(
            color: const Color(0xFFBD00FF),
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 1,
          ),
        ).animate().fadeIn(delay: 800.ms).shimmer(delay: 1.seconds),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => setState(() => _isScanning = false),
          child: Text('ABORT SCAN', style: TextStyle(color: hintColor)),
        ),
      ],
    );
  }
}

