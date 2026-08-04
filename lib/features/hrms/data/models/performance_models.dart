class EmployeeInfo {
  final String id;
  final String name;
  final String? avatarUrl;
  final String designation;
  final String department;

  EmployeeInfo({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.designation,
    required this.department,
  });

  factory EmployeeInfo.fromJson(Map<String, dynamic> json) {
    return EmployeeInfo(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      designation: json['designation'],
      department: json['department'],
    );
  }
}

class AppraisalCycle {
  final String id;
  final String name;
  final String type;
  final String period;
  final String startDate;
  final String endDate;
  final String selfReviewDeadline;
  final String managerReviewDeadline;
  final String hrReviewDeadline;
  final List<String> departments;
  final List<String> locations;
  final List<String> grades;
  final int eligibleCount;
  final int completionPercentage;
  final String status;
  final String? description;

  AppraisalCycle({
    required this.id,
    required this.name,
    required this.type,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.selfReviewDeadline,
    required this.managerReviewDeadline,
    required this.hrReviewDeadline,
    required this.departments,
    required this.locations,
    required this.grades,
    required this.eligibleCount,
    required this.completionPercentage,
    required this.status,
    this.description,
  });

  factory AppraisalCycle.fromJson(Map<String, dynamic> json) {
    return AppraisalCycle(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      period: json['period'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      selfReviewDeadline: json['selfReviewDeadline'],
      managerReviewDeadline: json['managerReviewDeadline'],
      hrReviewDeadline: json['hrReviewDeadline'],
      departments: List<String>.from(json['departments'] ?? []),
      locations: List<String>.from(json['locations'] ?? []),
      grades: List<String>.from(json['grades'] ?? []),
      eligibleCount: json['eligibleCount'],
      completionPercentage: json['completionPercentage'],
      status: json['status'],
      description: json['description'],
    );
  }
}

class Goal {
  final String id;
  final String title;
  final String description;
  final EmployeeInfo employee;
  final String cycleId;
  final String category;
  final int weightage;
  final String kpi;
  final double targetValue;
  final double currentValue;
  final String unit;
  final String dueDate;
  final String priority;
  final String status;
  final double progress;
  final String? comments;
  final int? attachments;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.employee,
    required this.cycleId,
    required this.category,
    required this.weightage,
    required this.kpi,
    required this.targetValue,
    required this.currentValue,
    required this.unit,
    required this.dueDate,
    required this.priority,
    required this.status,
    required this.progress,
    this.comments,
    this.attachments,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      employee: EmployeeInfo.fromJson(json['employee']),
      cycleId: json['cycleId'],
      category: json['category'],
      weightage: json['weightage'],
      kpi: json['kpi'],
      targetValue: (json['targetValue'] as num).toDouble(),
      currentValue: (json['currentValue'] as num).toDouble(),
      unit: json['unit'],
      dueDate: json['dueDate'],
      priority: json['priority'],
      status: json['status'],
      progress: (json['progress'] as num).toDouble(),
      comments: json['comments'],
      attachments: json['attachments'],
    );
  }
}
