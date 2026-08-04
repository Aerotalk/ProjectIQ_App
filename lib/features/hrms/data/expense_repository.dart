import 'package:flutter_riverpod/flutter_riverpod.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository();
});

class ExpenseRepository {
  Future<List<dynamic>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {'id': 'cat1', 'category': 'Travel', 'glCode': 'GL-TRV-100', 'active': true},
      {'id': 'cat2', 'category': 'Meals', 'glCode': 'GL-MEA-200', 'active': true},
      {'id': 'cat3', 'category': 'Office Supplies', 'glCode': 'GL-OFF-300', 'active': true},
    ];
  }

  Future<List<dynamic>> getClaims() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {
        'id': 'clm1',
        'claimNo': 'CLM-1001',
        'title': 'April Client Visit',
        'totalClaimed': 250.50,
        'status': 'Submitted',
        'submittedOn': DateTime.now().toIso8601String(),
      }
    ];
  }

  Future<List<dynamic>> getBatches() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {
        'id': 'bat1',
        'batchNo': 'BAT-9901',
        'totalAmount': 1500.00,
        'status': 'Processed',
        'createdAt': DateTime.now().toIso8601String(),
      }
    ];
  }

  Future<List<dynamic>> getAdvances() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {
        'id': 'adv1',
        'advanceNo': 'ADV-5001',
        'amount': 500.00,
        'reason': 'Upcoming conference',
        'status': 'Pending',
      }
    ];
  }
}
