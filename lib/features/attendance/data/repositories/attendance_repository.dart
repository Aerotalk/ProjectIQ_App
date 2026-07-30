import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/attendance_dashboard_models.dart';
import '../models/regularization_model.dart';
import '../models/leave_model.dart';
import '../models/shift_model.dart';
import '../models/attendance_calendar_model.dart';
import '../models/daily_attendance_model.dart';
import '../models/attendance_exception_model.dart';
import '../models/permission_model.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository();
});

class AttendanceRepository {
  Future<DashboardKPIs> getDashboardKPIs() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return const DashboardKPIs(
      present: 124,
      absent: 8,
      lateArrivals: 12,
      onLeave: 5,
      pendingLeaveRequests: 3,
      regularizationRequests: 4,
    );
  }

  Future<List<TodayAttendanceSummary>> getTodayAttendance() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      const TodayAttendanceSummary(
        employeeName: 'John Doe',
        shift: 'GS',
        checkInTime: '09:00 AM',
        checkOutTime: '--:--',
        status: 'Present',
      ),
      const TodayAttendanceSummary(
        employeeName: 'Jane Smith',
        shift: 'GS',
        checkInTime: '09:15 AM',
        checkOutTime: '--:--',
        status: 'Late',
      ),
      const TodayAttendanceSummary(
        employeeName: 'Mike Johnson',
        shift: 'NS',
        checkInTime: '--:--',
        checkOutTime: '--:--',
        status: 'Absent',
      ),
      const TodayAttendanceSummary(
        employeeName: 'Emily Davis',
        shift: 'GS',
        checkInTime: '08:50 AM',
        checkOutTime: '--:--',
        status: 'Present',
      ),
    ];
  }

  Future<List<LeaveRequestSummary>> getPendingLeaves() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      const LeaveRequestSummary(
        employeeName: 'Jane Smith',
        leaveType: 'Sick Leave',
        days: 2,
        status: 'Pending',
      ),
      const LeaveRequestSummary(
        employeeName: 'Mike Johnson',
        leaveType: 'Casual Leave',
        days: 1,
        status: 'Pending',
      ),
      const LeaveRequestSummary(
        employeeName: 'Sarah Williams',
        leaveType: 'Earned Leave',
        days: 5,
        status: 'Pending',
      ),
    ];
  }

  // --- Regularization ---
  Future<List<RegularizationModel>> getRegularizations() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      const RegularizationModel(
        id: '1',
        employeeName: 'John Doe',
        date: '2023-10-15',
        inTime: '09:00 AM',
        outTime: '06:00 PM',
        reason: 'Forgot to punch in',
        remarks: 'Please approve',
        status: 'Pending',
      ),
      const RegularizationModel(
        id: '2',
        employeeName: 'Jane Smith',
        date: '2023-10-14',
        inTime: '10:00 AM',
        outTime: '06:00 PM',
        reason: 'Late due to traffic',
        remarks: '',
        status: 'Approved',
      ),
    ];
  }

  Future<RegularizationModel> submitRegularization(RegularizationModel model) async {
    await Future.delayed(const Duration(seconds: 1));
    return model;
  }

  // --- Leaves ---
  Future<List<LeaveModel>> getLeaves() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      const LeaveModel(
        id: '1',
        leaveType: 'Sick Leave',
        employeeName: 'John Doe',
        startDate: '2023-11-01',
        endDate: '2023-11-02',
        durationDays: 2,
        reason: 'Fever',
        status: 'Approved',
      ),
    ];
  }

  Future<LeaveModel> submitLeave(LeaveModel model) async {
    await Future.delayed(const Duration(seconds: 1));
    return model;
  }

  // --- Shifts ---
  Future<List<ShiftModel>> getShifts() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      const ShiftModel(
        id: '1',
        shiftName: 'General Shift',
        shiftCode: 'GS',
        startTime: '09:00 AM',
        endTime: '06:00 PM',
        graceTimeMinutes: 15,
      ),
      const ShiftModel(
        id: '2',
        shiftName: 'Night Shift',
        shiftCode: 'NS',
        startTime: '09:00 PM',
        endTime: '06:00 AM',
        graceTimeMinutes: 10,
      ),
    ];
  }

  Future<ShiftModel> submitShift(ShiftModel model) async {
    await Future.delayed(const Duration(seconds: 1));
    return model;
  }

  // --- Calendar ---
  Future<List<AttendanceDayModel>> getAttendanceCalendar(int year, int month) async {
    await Future.delayed(const Duration(seconds: 1));
    // Generate dummy calendar data
    List<AttendanceDayModel> days = [];
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(year, month, i);
      if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
        days.add(AttendanceDayModel(date: date, status: 'Weekend'));
      } else if (i % 7 == 0) {
        days.add(AttendanceDayModel(date: date, status: 'Absent'));
      } else if (i % 14 == 0) {
        days.add(AttendanceDayModel(date: date, status: 'Leave'));
      } else {
        days.add(AttendanceDayModel(
          date: date, 
          status: 'Present',
          inTime: '09:00 AM',
          outTime: '06:00 PM',
          shiftCode: 'GS',
        ));
      }
    }
    return days;
  }

  // --- Daily Attendance Logs ---
  Future<List<DailyAttendanceModel>> getDailyAttendanceLogs() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      DailyAttendanceModel(
        id: '1',
        employeeName: 'John Doe',
        employeeCode: 'EMP001',
        department: 'Engineering',
        shiftName: 'General Shift',
        checkIn: '09:00 AM',
        checkOut: '06:00 PM',
        workingHours: '09:00',
        status: 'Present',
      ),
      DailyAttendanceModel(
        id: '2',
        employeeName: 'Jane Smith',
        employeeCode: 'EMP002',
        department: 'HR',
        shiftName: 'General Shift',
        checkIn: '09:15 AM',
        checkOut: '06:00 PM',
        workingHours: '08:45',
        status: 'Late',
        exceptionType: 'Late Arrival',
        isRegularized: false,
      ),
      DailyAttendanceModel(
        id: '3',
        employeeName: 'Mike Johnson',
        employeeCode: 'EMP003',
        department: 'Engineering',
        shiftName: 'Night Shift',
        checkIn: '--:--',
        checkOut: '--:--',
        workingHours: '00:00',
        status: 'Absent',
      ),
      DailyAttendanceModel(
        id: '4',
        employeeName: 'Emily Davis',
        employeeCode: 'EMP004',
        department: 'HR',
        shiftName: 'General Shift',
        checkIn: '--:--',
        checkOut: '--:--',
        workingHours: '00:00',
        status: 'Leave',
      ),
    ];
  }

  // --- Exceptions ---
  Future<List<AttendanceExceptionModel>> getAttendanceExceptions() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      AttendanceExceptionModel(
        id: '1',
        employeeName: 'Jane Smith',
        employeeCode: 'EMP002',
        date: '2023-11-01',
        exceptionType: 'Late Arrival',
        severity: 'Medium',
        description: 'Checked in 15 mins past grace period.',
        resolved: false,
      ),
      AttendanceExceptionModel(
        id: '2',
        employeeName: 'Mike Johnson',
        employeeCode: 'EMP003',
        date: '2023-11-02',
        exceptionType: 'Missing Swipes',
        severity: 'High',
        description: 'No check-in or check-out recorded for scheduled shift.',
        resolved: false,
      ),
      AttendanceExceptionModel(
        id: '3',
        employeeName: 'Emily Davis',
        employeeCode: 'EMP004',
        date: '2023-10-25',
        exceptionType: 'Early Checkout',
        severity: 'Low',
        description: 'Checked out 5 mins early.',
        resolved: true,
      ),
    ];
  }

  // --- Permissions ---
  Future<List<PermissionModel>> getPermissions() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      PermissionModel(
        id: '1',
        permissionNumber: 'PRM-001',
        employeeName: 'John Doe',
        department: 'Engineering',
        permissionDate: '2023-11-05',
        permissionType: 'Personal',
        startTime: '04:00 PM',
        endTime: '06:00 PM',
        totalHours: '2.0',
        reason: 'Doctor Appointment',
        status: 'Approved',
      ),
      PermissionModel(
        id: '2',
        permissionNumber: 'PRM-002',
        employeeName: 'John Doe',
        department: 'Engineering',
        permissionDate: '2023-11-10',
        permissionType: 'Official',
        startTime: '10:00 AM',
        endTime: '11:00 AM',
        totalHours: '1.0',
        reason: 'Bank Work',
        status: 'Pending',
      ),
    ];
  }

  Future<PermissionModel> submitPermission(PermissionModel model) async {
    await Future.delayed(const Duration(seconds: 1));
    return model;
  }
}

