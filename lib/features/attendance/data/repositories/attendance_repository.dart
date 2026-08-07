import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../models/attendance_dashboard_models.dart';
import '../models/regularization_model.dart';
import '../models/leave_model.dart';
import '../models/shift_model.dart';
import '../models/attendance_calendar_model.dart';
import '../models/daily_attendance_model.dart';
import '../models/attendance_exception_model.dart';
import '../models/permission_model.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  final dio = ref.read(dioProvider);
  return AttendanceRepository(dio);
});

class AttendanceRepository {
  final Dio _dio;

  AttendanceRepository(this._dio);

  Future<DashboardKPIs> getDashboardKPIs() async {
    try {
      final responses = await Future.wait([
        _dio.get('/hrms/attendance/records').catchError((_) => Response(requestOptions: RequestOptions(path: ''), data: [])),
        _dio.get('/hrms/leave/applications').catchError((_) => Response(requestOptions: RequestOptions(path: ''), data: [])),
        _dio.get('/hrms/attendance/regularizations').catchError((_) => Response(requestOptions: RequestOptions(path: ''), data: [])),
      ]);

      final attendanceData = responses[0].data is List ? responses[0].data as List : [];
      final leaveData = responses[1].data is List ? responses[1].data as List : [];
      final regData = responses[2].data is List ? responses[2].data as List : [];

      int present = 0;
      int absent = 0;
      int lateArrivals = 0;
      int onLeave = 0;
      int pendingLeaveRequests = 0;
      int regularizationRequests = 0;

      for (var att in attendanceData) {
        if (att['status'] == 'Present') present++;
        if (att['status'] == 'Absent') absent++;
        if (att['status'] == 'Late' || (att['lateBy'] != null && att['lateBy'] > 0)) lateArrivals++;
      }

      for (var leave in leaveData) {
        if (leave['status'] == 'Approved') onLeave++;
        if (leave['status'] == 'Pending') pendingLeaveRequests++;
      }

      for (var reg in regData) {
        if (reg['status'] == 'Pending') regularizationRequests++;
      }

      return DashboardKPIs(
        present: present,
        absent: absent,
        lateArrivals: lateArrivals,
        onLeave: onLeave,
        pendingLeaveRequests: pendingLeaveRequests,
        regularizationRequests: regularizationRequests,
      );
    } catch (e) {
      return const DashboardKPIs(
        present: 0,
        absent: 0,
        lateArrivals: 0,
        onLeave: 0,
        pendingLeaveRequests: 0,
        regularizationRequests: 0,
      );
    }
  }

  Future<List<TodayAttendanceSummary>> getTodayAttendance() async {
    try {
      final response = await _dio.get('/hrms/attendance/records');
      if (response.data is List) {
        return (response.data as List).map((r) => TodayAttendanceSummary(
          employeeName: '${r['employee']?['firstName'] ?? ''} ${r['employee']?['lastName'] ?? ''}'.trim(),
          shift: r['shift']?['shiftName'] ?? '',
          checkInTime: r['checkIn']?.toString().split('T').last ?? '--:--',
          checkOutTime: r['checkOut']?.toString().split('T').last ?? '--:--',
          status: r['status'] ?? 'Absent',
        )).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<LeaveRequestSummary>> getPendingLeaves() async {
    try {
      final response = await _dio.get('/hrms/leave/applications');
      if (response.data is List) {
        return (response.data as List).map((l) => LeaveRequestSummary(
          employeeName: '${l['employee']?['firstName'] ?? ''} ${l['employee']?['lastName'] ?? ''}'.trim(),
          leaveType: l['leaveType']?['name'] ?? '',
          days: (l['duration'] ?? 0).toInt(),
          status: l['status'] ?? 'Pending',
        )).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // --- Regularization ---
  Future<List<RegularizationModel>> getRegularizations() async {
    try {
      final response = await _dio.get('/hrms/attendance/regularizations');
      if (response.data is List) {
        return (response.data as List).map((r) => RegularizationModel(
          id: r['id'] ?? '',
          employeeName: '${r['employee']?['firstName'] ?? ''} ${r['employee']?['lastName'] ?? ''}'.trim(),
          date: r['date']?.toString().split('T')[0] ?? '',
          inTime: r['requestedCheckIn']?.toString().split('T').last ?? '',
          outTime: r['requestedCheckOut']?.toString().split('T').last ?? '',
          reason: r['reason'] ?? '',
          remarks: r['approvalRemarks'] ?? '',
          status: r['status'] ?? 'Pending',
        )).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<RegularizationModel> submitRegularization(RegularizationModel model) async {
    final payload = {
      'date': model.date,
      'reason': model.reason,
      'requestedCheckIn': '${model.date}T${model.inTime}',
      'requestedCheckOut': '${model.date}T${model.outTime}',
      'employee': {'id': '00000000-0000-0000-0000-000000000001'},
    };
    final response = await _dio.post('/hrms/attendance/regularizations', data: payload);
    return model;
  }

  // --- Leaves ---
  Future<List<LeaveModel>> getLeaves() async {
    try {
      final response = await _dio.get('/hrms/leave/applications');
      if (response.data is List) {
        return (response.data as List).map((l) => LeaveModel(
          id: l['id'] ?? '',
          leaveType: l['leaveType']?['name'] ?? '',
          employeeName: '${l['employee']?['firstName'] ?? ''} ${l['employee']?['lastName'] ?? ''}'.trim(),
          startDate: l['fromDate']?.toString().split('T')[0] ?? '',
          endDate: l['toDate']?.toString().split('T')[0] ?? '',
          durationDays: (l['duration'] ?? 0).toDouble(),
          reason: l['reason'] ?? '',
          status: l['status'] ?? 'Pending',
        )).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<LeaveModel> submitLeave(LeaveModel model) async {
    final payload = {
      'fromDate': model.startDate,
      'toDate': model.endDate,
      'reason': model.reason,
      'employee': {'id': '00000000-0000-0000-0000-000000000001'},
    };
    await _dio.post('/hrms/leave/applications', data: payload);
    return model;
  }

  // --- Shifts ---
  Future<List<ShiftModel>> getShifts() async {
    try {
      final response = await _dio.get('/hrms/shifts');
      if (response.data is List) {
        return (response.data as List).map((s) => ShiftModel(
          id: s['id'] ?? '',
          shiftName: s['shiftName'] ?? '',
          shiftCode: s['shiftCode'] ?? '',
          startTime: s['startTime']?.toString().split('T').last ?? '',
          endTime: s['endTime']?.toString().split('T').last ?? '',
          graceTimeMinutes: s['graceTime'] ?? 0,
        )).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<ShiftModel> submitShift(ShiftModel model) async {
    return model;
  }

  // --- Calendar ---
  Future<List<AttendanceDayModel>> getAttendanceCalendar(int year, int month) async {
    List<AttendanceDayModel> days = [];
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(year, month, i);
      if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
        days.add(AttendanceDayModel(date: date, status: 'Weekend'));
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
    try {
      final response = await _dio.get('/hrms/attendance/records');
      if (response.data is List) {
        return (response.data as List).map((r) => DailyAttendanceModel(
          id: r['id'] ?? '',
          employeeName: '${r['employee']?['firstName'] ?? ''} ${r['employee']?['lastName'] ?? ''}'.trim(),
          employeeCode: r['employee']?['employeeCode'] ?? '',
          department: r['department']?['departmentName'] ?? '',
          shiftName: r['shift']?['shiftName'] ?? '',
          checkIn: r['checkIn']?.toString().split('T').last ?? '--:--',
          checkOut: r['checkOut']?.toString().split('T').last ?? '--:--',
          workingHours: (r['workingHours'] ?? 0).toString(),
          status: r['status'] ?? 'Present',
        )).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // --- Exceptions ---
  Future<List<AttendanceExceptionModel>> getAttendanceExceptions() async {
    try {
      final response = await _dio.get('/hrms/attendance/exceptions');
      if (response.data is List) {
        return (response.data as List).map((ex) => AttendanceExceptionModel(
          id: ex['id'] ?? '',
          employeeName: '${ex['employee']?['firstName'] ?? ''} ${ex['employee']?['lastName'] ?? ''}'.trim(),
          employeeCode: ex['employee']?['employeeCode'] ?? '',
          date: ex['createdAt']?.toString().split('T')[0] ?? '',
          exceptionType: ex['exceptionType'] ?? 'Unknown',
          severity: ex['severity'] ?? 'Low',
          description: ex['description'] ?? '',
          resolved: ex['resolved'] ?? false,
        )).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // --- Permissions ---
  Future<List<PermissionModel>> getPermissions() async {
    try {
      final response = await _dio.get('/hrms/attendance/permissions');
      if (response.data is List) {
        return (response.data as List).map((p) => PermissionModel(
          id: p['id'] ?? '',
          permissionNumber: p['permissionNumber'] ?? '',
          employeeName: '${p['employee']?['firstName'] ?? ''} ${p['employee']?['lastName'] ?? ''}'.trim(),
          department: p['employee']?['department']?['departmentName'] ?? '',
          permissionDate: p['permissionDate']?.toString().split('T')[0] ?? '',
          permissionType: p['permissionType'] ?? '',
          startTime: p['startTime']?.toString().split('T').last ?? '',
          endTime: p['endTime']?.toString().split('T').last ?? '',
          totalHours: (p['totalHours'] ?? 0).toString(),
          reason: p['reason'] ?? '',
          status: p['status'] ?? 'Pending',
        )).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<PermissionModel> submitPermission(PermissionModel model) async {
    final payload = {
      'permissionType': model.permissionType,
      'permissionDate': model.permissionDate,
      'startTime': '${model.permissionDate}T${model.startTime}',
      'endTime': '${model.permissionDate}T${model.endTime}',
      'reason': model.reason,
      'employee': {'id': '00000000-0000-0000-0000-000000000001'},
    };
    await _dio.post('/hrms/attendance/permissions', data: payload);
    return model;
  }
}

