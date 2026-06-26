import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils/supabase_config.dart';
import 'services/auth_service.dart';
import 'services/portfolio_service.dart';
import 'services/theme_provider.dart';
import 'views/home_view.dart';
import 'views/expertises_view.dart';
import 'views/competences_view.dart';
import 'views/realisations_view.dart';
import 'views/carriere_view.dart';
import 'views/formation_view.dart';
import 'views/iot_conceptions_view.dart';
import 'views/contact_view.dart';
import 'views/study_documents_view.dart';
import 'widgets/main_layout.dart';
import 'views/admin_login_view.dart';
import 'views/admin_dashboard_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => PortfolioService()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

CustomTransitionPage _buildPageWithTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 400),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutQuart);
      return FadeTransition(
        opacity: curve,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.05),
            end: Offset.zero,
          ).animate(curve),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1.0).animate(curve),
            child: child,
          ),
        ),
      );
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final TextTheme textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2563EB),
        primary: const Color(0xFF3B82F6), // Tailwind Blue-500
        secondary: const Color(0xFF2DD4BF), // Teal-400
        surface: const Color(0xFF1E293B), // Slate-800
        background: const Color(0xFF0F172A), // Slate-900
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      useMaterial3: true,
      textTheme: textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white).copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(fontWeight: FontWeight.w800, color: Colors.white),
        displayMedium: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
        headlineLarge: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
        headlineMedium: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
        titleLarge: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
      ),
    );
    
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            return MainLayout(child: child);
          },
          routes: [
            GoRoute(
              path: '/',
              pageBuilder: (context, state) => _buildPageWithTransition(
                context: context,
                state: state,
                child: const HomeView(),
              ),
            ),
            GoRoute(
              path: '/expertises',
              pageBuilder: (context, state) => _buildPageWithTransition(
                context: context,
                state: state,
                child: const ExpertisesView(),
              ),
            ),
            GoRoute(
              path: '/competences',
              pageBuilder: (context, state) => _buildPageWithTransition(
                context: context,
                state: state,
                child: const CompetencesView(),
              ),
            ),
            GoRoute(
              path: '/realisations',
              pageBuilder: (context, state) => _buildPageWithTransition(
                context: context,
                state: state,
                child: const RealisationsView(),
              ),
            ),
            GoRoute(
              path: '/carriere',
              pageBuilder: (context, state) => _buildPageWithTransition(
                context: context,
                state: state,
                child: const CarriereView(),
              ),
            ),
            GoRoute(
              path: '/formation',
              pageBuilder: (context, state) => _buildPageWithTransition(
                context: context,
                state: state,
                child: const FormationView(),
              ),
            ),
            GoRoute(
              path: '/iot',
              pageBuilder: (context, state) => _buildPageWithTransition(
                context: context,
                state: state,
                child: const IoTConceptionsView(),
              ),
            ),
            GoRoute(
              path: '/documents',
              pageBuilder: (context, state) => _buildPageWithTransition(
                context: context,
                state: state,
                child: const StudyDocumentsView(),
              ),
            ),
            GoRoute(
              path: '/contact',
              pageBuilder: (context, state) => _buildPageWithTransition(
                context: context,
                state: state,
                child: const ContactView(),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/admin',
          pageBuilder: (context, state) {
            final authService = context.watch<AuthService>();
            return _buildPageWithTransition(
              context: context,
              state: state,
              child: Theme(
                data: darkTheme,
                child: authService.isAdmin
                    ? const AdminDashboardView()
                    : const AdminLoginView(),
              ),
            );
          },
        ),
      ],
    );



    return MaterialApp.router(
      title: 'BejaouiFedi Portfolio',
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB), // Tailwind Blue-600
          primary: const Color(0xFF2563EB),
          secondary: const Color(0xFF14B8A6), // Teal
          surface: const Color(0xFFF8FAFC), // Slate-50
          background: const Color(0xFFF1F5F9), // Slate-100
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        useMaterial3: true,
        textTheme: textTheme.copyWith(
          displayLarge: textTheme.displayLarge?.copyWith(fontWeight: FontWeight.w800),
          displayMedium: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w700),
          headlineLarge: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
          headlineMedium: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
          titleLarge: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      darkTheme: darkTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
