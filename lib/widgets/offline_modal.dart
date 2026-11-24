import 'package:flutter/material.dart';
import '../core/offline/offline_manager.dart';
import '../theme/app_theme.dart';

class OfflineModal extends StatelessWidget {
  final OfflineReport report;
  final VoidCallback onCollect;

  const OfflineModal({
    super.key,
    required this.report,
    required this.onCollect,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: const Color(0xFF131D2A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF284860),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00C9FF).withOpacity(0.3),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🏝️', style: TextStyle(fontSize: 34)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'WELCOME BACK',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Away for ${report.awayDurationFormatted}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF8BA3B8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (report.wasCapped) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withOpacity(0.4)),
                ),
                child: const Text(
                  'Reached offline simulation cap. Upgrade log to extend!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.amber, fontSize: 11),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0C141D),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1E3142)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  _buildStatRow(
                    icon: '🦤',
                    label: 'Dodos Born',
                    value: '+${report.dodosBorn}',
                    color: const Color(0xFF4ADE80),
                  ),
                  const Divider(color: Color(0xFF1E3142), height: 16),
                  _buildStatRow(
                    icon: '🪙',
                    label: 'Credits Earned',
                    value: '+${report.creditsEarned.toStringAsFixed(0)}',
                    color: const Color(0xFFFBBF24),
                  ),
                  const Divider(color: Color(0xFF1E3142), height: 16),
                  _buildStatRow(
                    icon: '🧬',
                    label: 'DNA Recovered',
                    value: '+${report.dnaRecovered.toStringAsFixed(1)}',
                    color: const Color(0xFF38BDF8),
                  ),
                  const Divider(color: Color(0xFF1E3142), height: 16),
                  _buildStatRow(
                    icon: '🔬',
                    label: 'Research Produced',
                    value: '+${report.researchGathered.toStringAsFixed(1)}',
                    color: const Color(0xFFA78BFA),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onCollect,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: AppColors.onFill(const Color(0xFF10B981)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: const Color(0xFF10B981).withOpacity(0.5),
              ),
              child: const Text(
                'COLLECT REWARDS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFFC4D5E5),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
