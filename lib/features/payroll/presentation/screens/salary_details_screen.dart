import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_spacing.dart';

class SalaryDetailsScreen extends StatelessWidget {
  const SalaryDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salary Breakup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          children: [
            _buildSummaryCard(context),
            const SizedBox(height: AppSpacing.s24),
            _buildExpandableSection(
              context,
              title: 'Earnings',
              icon: LucideIcons.trendingUp,
              color: Colors.green,
              items: {
                'Basic Pay': '₹ 75,000',
                'HRA': '₹ 30,000',
                'Special Allowance': '₹ 40,000',
                'Internet Reimbursement': '₹ 1,500',
              },
              total: '₹ 1,46,500',
            ),
            const SizedBox(height: AppSpacing.s16),
            _buildExpandableSection(
              context,
              title: 'Deductions',
              icon: LucideIcons.trendingDown,
              color: Colors.red,
              items: {
                'Provident Fund (PF)': '₹ 9,000',
                'Professional Tax (PT)': '₹ 200',
                'Income Tax (TDS)': '₹ 22,300',
              },
              total: '₹ 31,500',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Net Salary',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            '₹ 1,15,000',
            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('Gross', '₹ 1,46,500'),
              Container(width: 1, height: 30, color: Colors.white30),
              _buildSummaryItem('Deductions', '₹ 31,500'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildExpandableSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Map<String, String> items,
    required String total,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1.0),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Column(
              children: [
                ...items.entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(e.key, style: TextStyle(color: Colors.grey.shade700)),
                          Text(e.value, style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    )),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(total, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
