import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../data/expense_repository.dart';
import 'providers/employee_providers.dart';

class ExpenseClaimFormScreen extends ConsumerStatefulWidget {
  const ExpenseClaimFormScreen({super.key});

  @override
  ConsumerState<ExpenseClaimFormScreen> createState() =>
      _ExpenseClaimFormScreenState();
}

class _ExpenseClaimFormScreenState
    extends ConsumerState<ExpenseClaimFormScreen> {
  final _titleController = TextEditingController();
  String? _selectedTemplate;
  String _selectedCurrency = 'USD';
  String? _selectedEmployeeId;
  
  bool _isSubmitting = false;

  final List<String> _currencies = ['USD', 'INR', 'EUR'];
  
  List<Map<String, dynamic>> _items = [];
  List<dynamic> _templates = [];
  List<dynamic> _categories = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final repo = ref.read(expenseRepositoryProvider);
      
      repo.getCategories().then((categories) {
        if (mounted) setState(() => _categories = categories);
      });
      
      repo.getTemplates().then((templates) {
        if (mounted) {
          setState(() {
            _templates = templates;
            if (templates.isNotEmpty) {
              _selectedTemplate = templates.first['id'];
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleController.text.isEmpty || _selectedEmployeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    
    setState(() => _isSubmitting = true);
    
    try {
      final repo = ref.read(expenseRepositoryProvider);
      
      final payload = {
        'title': _titleController.text,
        'currency': _selectedCurrency,
        'template': {'id': _selectedTemplate},
        'employee': {'id': _selectedEmployeeId},
      };
      
      final claimRes = await repo.createClaim(payload);
      
      if (claimRes != null && claimRes['id'] != null) {
        final claimId = claimRes['id'];
        for (var item in _items) {
          final itemPayload = {
            'expenseDate': item['date'],
            'categoryId': item['categoryId'] ?? '1',
            'merchantName': item['merchantName'] ?? 'Vendor',
            'claimAmount': double.tryParse(item['amount'].toString()) ?? 0,
            'description': item['description'] ?? '',
            'currency': _selectedCurrency,
          };
          await repo.createClaimItem(claimId, itemPayload);
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense Logged Successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _addItem() {
    setState(() {
      _items.add({
        'date': DateTime.now().toIso8601String().split('T')[0],
        'amount': '',
        'description': '',
        'categoryId': _categories.isNotEmpty ? _categories.first['id'] : null,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(employeeListProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Claim Details',
                    style: AppTypography.subtitle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  Text('Employee *', style: AppTypography.label),
                  const SizedBox(height: AppSpacing.s8),
                  employeesAsync.when(
                    data: (employees) => DropdownButtonFormField<String>(
                      value: _selectedEmployeeId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      hint: const Text('Select Employee'),
                      items: employees
                          .map((e) => DropdownMenuItem(value: e.id, child: Text('${e.firstName} ${e.lastName}')))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedEmployeeId = v),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Text('Error loading employees'),
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  AppTextField(
                    label: 'Title / Purpose *',
                    placeholder: 'e.g., April Client Visit',
                    controller: _titleController,
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  Text('Currency *', style: AppTypography.label),
                  const SizedBox(height: AppSpacing.s8),
                  DropdownButtonFormField<String>(
                    value: _selectedCurrency,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: _currencies
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCurrency = v!),
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  Text('Expense Template *', style: AppTypography.label),
                  const SizedBox(height: AppSpacing.s8),
                  DropdownButtonFormField<String>(
                    value: _selectedTemplate,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    hint: const Text('Select Template'),
                    items: _templates
                        .map((t) => DropdownMenuItem(value: t['id'].toString(), child: Text(t['templateName'])))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedTemplate = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.s24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Expense Items', style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.w600)),
                TextButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Add Item'),
                ),
              ],
            ),
            
            if (_items.isEmpty)
               const AppCard(
                 padding: EdgeInsets.all(AppSpacing.s24),
                 child: Center(child: Text('No items added yet', style: TextStyle(color: Colors.grey))),
               ),
               
            ...List.generate(_items.length, (index) {
              final item = _items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s16),
                child: AppCard(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Item ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: () => setState(() => _items.removeAt(index)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Category *', style: AppTypography.label),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: item['categoryId'],
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      hint: const Text('Select Category'),
                      items: _categories
                          .map((c) => DropdownMenuItem(value: c['id'].toString(), child: Text(c['category'])))
                          .toList(),
                      onChanged: (v) => setState(() => _items[index]['categoryId'] = v),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Date',
                      initialValue: item['date'],
                      onChanged: (v) => _items[index]['date'] = v,
                    ),
                    const SizedBox(height: 8),
                    AppTextField(
                      label: 'Amount',
                      keyboardType: TextInputType.number,
                      initialValue: item['amount'],
                      onChanged: (v) => _items[index]['amount'] = v,
                    ),
                    const SizedBox(height: 8),
                    AppTextField(
                      label: 'Description',
                      initialValue: item['description'],
                      onChanged: (v) => _items[index]['description'] = v,
                    ),
                  ],
                ),
                ),
              );
            }),
            const SizedBox(height: AppSpacing.s32),

            AppButton(
              text: _isSubmitting ? 'Saving...' : 'Save Expense', 
              onPressed: _isSubmitting ? () {} : _submit,
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
