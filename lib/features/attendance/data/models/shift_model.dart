class ShiftModel {
  final String id;
  final String shiftName;
  final String shiftCode;
  final String startTime;
  final String endTime;
  final int graceTimeMinutes;

  const ShiftModel({
    required this.id,
    required this.shiftName,
    required this.shiftCode,
    required this.startTime,
    required this.endTime,
    required this.graceTimeMinutes,
  });

  ShiftModel copyWith({
    String? id,
    String? shiftName,
    String? shiftCode,
    String? startTime,
    String? endTime,
    int? graceTimeMinutes,
  }) {
    return ShiftModel(
      id: id ?? this.id,
      shiftName: shiftName ?? this.shiftName,
      shiftCode: shiftCode ?? this.shiftCode,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      graceTimeMinutes: graceTimeMinutes ?? this.graceTimeMinutes,
    );
  }
}
