import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/portfolio_service.dart';
import '../widgets/section_header.dart';
import '../widgets/experience_tile.dart';

class CarriereView extends StatelessWidget {
  const CarriereView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Carrière').animate().fadeIn().slideX(),
          const SizedBox(height: 32),
          Consumer<PortfolioService>(
            builder: (context, portfolio, _) {
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: portfolio.experiences.length,
                itemBuilder: (context, index) {
                  return ExperienceTile(experience: portfolio.experiences[index])
                      .animate()
                      .fadeIn(delay: (100 * index).ms)
                      .slideX(begin: -0.05, end: 0);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
