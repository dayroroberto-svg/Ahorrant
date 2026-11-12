import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ProgresoScreen extends StatelessWidget {
  const ProgresoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mi Progreso',
          style: GoogleFonts.fredoka(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.darkBlue,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.cyan, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cyan.withValues(alpha: 0.15),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppColors.softCyan,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.insights_rounded,
                      size: 44,
                      color: AppColors.teal,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Balance y Hábitos',
                    style: GoogleFonts.fredoka(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlue,
                    ),
                  ),
                  Text(
                    'Control de tus gastos y metas',
                    style: GoogleFonts.fredoka(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Desglose Estimado',
              style: GoogleFonts.fredoka(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBlue,
              ),
            ),
            const SizedBox(height: 12),
            _buildStat('Gastos hormiga', 'S/ 120.00', Icons.pest_control_rounded,
                AppColors.yellow, AppColors.darkBlue),
            _buildStat('Gastos necesarios', 'S/ 90.00',
                Icons.check_circle_rounded, AppColors.softTeal, AppColors.teal),
            _buildStat('Ahorro acumulado', 'S/ 85.00', Icons.savings_rounded,
                AppColors.softCyan, AppColors.cyan),
            _buildStat('Total controlado', 'S/ 295.00', Icons.trending_up_rounded,
                AppColors.softYellow, AppColors.darkBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String valor, IconData icon, Color bgColor,
      Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.softTeal, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.teal.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: iconColor),
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: GoogleFonts.fredoka(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          Text(
            valor,
            style: GoogleFonts.fredoka(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.darkBlue,
            ),
          ),
        ],
      ),
    );
  }
}
