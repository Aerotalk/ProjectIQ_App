class RegularizationModel {
  final String id;
  final String employeeName;
  final String date;
  final String inTime;
  final String outTime;
  final String reason;
  final String remarks;
  final String status;

  const RegularizationModel({
    required this.id,
    required this.employeeName,
    required this.date,
    required this.inTime,
    required this.outTime,
    required this.reason,
    required this.remarks,
    required this.status,
  });

  RegularizationModel copyWith({
    String? id,
    String? employeeName,
    String? date,
    String? inTime,
    String? outTime,
    String? reason,
    String? remarks,
    String? status,
  }) {
    return RegularizationModel(
      id: id ?? this.id,
      employeeName: employeeName ?? this.employeeName,
      date: date ?? this.date,
      inTime: inTime ?? this.inTime,
      outTime: outTime ?? this.outTime,
      reason: reason ?? this.reason,
      remarks: remarks ?? this.remarks,
      status: status ?? this.status,
    );
  }
}
