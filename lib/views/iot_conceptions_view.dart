import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/portfolio_service.dart';
import '../widgets/page_header.dart';
import 'home_view.dart';

class IoTConceptionsView extends StatelessWidget {
  const IoTConceptionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PortfolioService>(
      builder: (context, portfolio, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 100, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'IOT & CONCEPTIONS',
                subtitle: 'Systèmes embarqués et conception matérielle',
                count: portfolio.iotDesigns.length,
                countLabel: 'SYSTÈMES',
              ),
              const SizedBox(height: 48),
              const IoTDesignsSection(),
            ],
          ),
        );
      },
    );
  }
}
