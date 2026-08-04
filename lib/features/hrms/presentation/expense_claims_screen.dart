import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import 'tabs/expense_claims_dashboard_tab.dart';
import 'tabs/expense_claims_list_tab.dart';
import 'tabs/expense_advances_tab.dart';
import 'tabs/expense_configuration_tab.dart';
import 'tabs/expense_approvals_tab.dart';
import 'tabs/expense_batch_processing_tab.dart';

class ExpenseClaimsScreen extends ConsumerStatefulWidget {
  const ExpenseClaimsScreen({super.key});

  @override
  ConsumerState<ExpenseClaimsScreen> createState() => _ExpenseClaimsScreenState();
}

class _ExpenseClaimsScreenState extends ConsumerState<ExpenseClaimsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Claims'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primaryLight,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primaryLight,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'Claims'),
            Tab(text: 'Advances'),
            Tab(text: 'Configuration'),
            Tab(text: 'Approvals'),
            Tab(text: 'Batch Processing'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ExpenseClaimsDashboardTab(),
          ExpenseClaimsListTab(),
          ExpenseAdvancesTab(),
          ExpenseConfigurationTab(),
          ExpenseApprovalsTab(),
          ExpenseBatchProcessingTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/hrms/expense-claims/new');
        },
        child: const Icon(LucideIcons.plus),
      ),
    );
  }
}
