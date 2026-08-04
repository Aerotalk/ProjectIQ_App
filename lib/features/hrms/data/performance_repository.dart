import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/performance_models.dart';

final performanceRepositoryProvider = Provider<PerformanceRepository>((ref) {
  return PerformanceRepository();
});

class PerformanceRepository {
  // Mock data inspired by frontend mockPerformanceData.ts

  Future<List<AppraisalCycle>> getActiveCycles() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      AppraisalCycle(
        id: 'C-2026-01',
        name: 'Annual Performance Review 2026',
        type: 'Annual',
        period: 'Jan 2026 - Dec 2026',
        startDate: '2026-01-01',
        endDate: '2026-12-31',
        selfReviewDeadline: '2026-11-15',
        managerReviewDeadline: '2026-11-30',
        hrReviewDeadline: '2026-12-15',
        departments: ['Engineering', 'Sales', 'Marketing', 'HR'],
        locations: ['New York', 'London', 'Remote'],
        grades: ['L1', 'L2', 'L3', 'L4', 'L5'],
        eligibleCount: 154,
        completionPercentage: 75,
        status: 'Active',
        description: 'Annual performance evaluation for all full-time employees.',
      ),
      AppraisalCycle(
        id: 'C-2026-Q1',
        name: 'Q1 Check-in 2026',
        type: 'Quarterly',
        period: 'Jan 2026 - Mar 2026',
        startDate: '2026-01-01',
        endDate: '2026-03-31',
        selfReviewDeadline: '2026-04-05',
        managerReviewDeadline: '2026-04-15',
        hrReviewDeadline: '2026-04-20',
        departments: ['Sales', 'Marketing'],
        locations: ['All'],
        grades: ['All'],
        eligibleCount: 42,
        completionPercentage: 100,
        status: 'Completed',
        description: 'Quarterly goal check-in for revenue-generating teams.',
      ),
      AppraisalCycle(
        id: 'C-2026-02',
        name: 'Mid-Year Review 2026',
        type: 'Bi-Annual',
        period: 'Jan 2026 - Jun 2026',
        startDate: '2026-01-01',
        endDate: '2026-06-30',
        selfReviewDeadline: '2026-07-15',
        managerReviewDeadline: '2026-07-31',
        hrReviewDeadline: '2026-08-15',
        departments: ['Engineering', 'Product'],
        locations: ['All'],
        grades: ['All'],
        eligibleCount: 89,
        completionPercentage: 15,
        status: 'Review Phase',
        description: 'Mid-year performance assessment and goal calibration.',
      ),
    ];
  }

  Future<List<Goal>> getGoals() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      Goal(
        id: 'G-001',
        title: 'Increase Q3 Revenue by 15%',
        description: 'Focus on enterprise clients to boost overall Q3 revenue.',
        employee: EmployeeInfo(id: 'EMP-01', name: 'John Doe', designation: 'Senior Account Executive', department: 'Sales'),
        cycleId: 'C-2026-01',
        category: 'Financial',
        weightage: 40,
        kpi: 'Quarterly Revenue',
        targetValue: 500000,
        currentValue: 350000,
        unit: '\$',
        dueDate: '2026-09-30',
        priority: 'High',
        status: 'In Progress',
        progress: 70,
        comments: 'Tracking well against enterprise targets.',
        attachments: 2,
      ),
      Goal(
        id: 'G-002',
        title: 'Launch Mobile App v2.0',
        description: 'Complete development and rollout of the new mobile application.',
        employee: EmployeeInfo(id: 'EMP-02', name: 'Jane Smith', designation: 'Engineering Lead', department: 'Engineering'),
        cycleId: 'C-2026-01',
        category: 'Productivity',
        weightage: 50,
        kpi: 'Launch Date',
        targetValue: 100,
        currentValue: 100,
        unit: '%',
        dueDate: '2026-08-15',
        priority: 'Critical',
        status: 'Completed',
        progress: 100,
      ),
      Goal(
        id: 'G-003',
        title: 'Reduce Churn Rate to < 2%',
        description: 'Implement new customer success workflows to retain clients.',
        employee: EmployeeInfo(id: 'EMP-03', name: 'Alice Johnson', designation: 'Customer Success Manager', department: 'Support'),
        cycleId: 'C-2026-02',
        category: 'Customer Satisfaction',
        weightage: 30,
        kpi: 'Churn Percentage',
        targetValue: 2,
        currentValue: 3.5,
        unit: '%',
        dueDate: '2026-12-31',
        priority: 'Medium',
        status: 'In Progress',
        progress: 45,
      ),
    ];
  }

  Future<List<dynamic>> getSelfReviews() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {
        'id': 'SR-101',
        'cycle': 'Mid-Year Review 2026',
        'overallRating': 4.2,
        'status': 'Submitted',
        'submittedOn': '2026-07-10',
      }
    ];
  }

  Future<List<dynamic>> getManagerReviews() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {
        'id': 'MR-101',
        'employee': 'John Doe',
        'cycle': 'Mid-Year Review 2026',
        'overallRating': 4.0,
        'status': 'Pending',
      }
    ];
  }

  Future<List<dynamic>> getCalibrationRecords() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {
        'id': 'CAL-01',
        'employee': 'John Doe',
        'currentRating': 4.0,
        'proposedRating': 3.8,
        'status': 'Pending',
      },
      {
        'id': 'CAL-02',
        'employee': 'Jane Smith',
        'currentRating': 4.8,
        'proposedRating': 4.8,
        'status': 'Finalized',
      }
    ];
  }
}
