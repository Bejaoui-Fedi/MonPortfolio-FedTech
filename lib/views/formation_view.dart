import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/portfolio_service.dart';
import '../widgets/section_header.dart';
import '../widgets/education_tile.dart';

class FormationView extends StatelessWidget {
  const FormationView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Formation').animate().fadeIn().slideX(),
          const SizedBox(height: 32),
          Consumer<PortfolioService>(
            builder: (context, portfolio, _) {
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: portfolio.education.length,
                itemBuilder: (context, index) {
                  return EducationTile(education: portfolio.education[index])
                      .animate()
                      .fadeIn(delay: (100 * index).ms)
                      .slideX(begin: 0.05, end: 0);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
