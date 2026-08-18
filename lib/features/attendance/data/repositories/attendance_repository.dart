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

  String _toTitleCase(String? text, String defaultText) {
    if (text == null || text.isEmpty) return defaultText;
    return text.split('_').map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' : '').join(' ');
  }

  /// Fetch today's check-in status for an employee
  Future<Map<String, dynamic>> getCheckInStatus(String employeeId) async {
    try {
      final response = await _dio.get(
        '/hrms/attendance/records/check-in/status',
        queryParameters: {'employeeId': employeeId},
      );
      return Map<String, dynamic>.from(response.data as Map);
    } catch (e) {
      return {'currentlyCheckedIn': false};
    }
  }

  /// Perform check-in — captures GPS before the API call
  Future<void> checkIn(String employeeId, {double? lat, double? lng, String? locationLabel}) async {
    final data = <String, dynamic>{
      'employeeId': employeeId,
      'source': 'Mobile',
    };
    if (lat != null) data['latitude'] = lat;
    if (lng != null) data['longitude'] = lng;
    if (locationLabel != null) data['locationLabel'] = locationLabel;

    await _dio.post('/hrms/attendance/records/check-in', data: data);
  }

  /// Perform check-out — captures GPS before the API call
  Future<void> checkOut(String employeeId, {double? lat, double? lng, String? locationLabel}) async {
    final data = <String, dynamic>{
      'employeeId': employeeId,
    };
    if (lat != null) data['latitude'] = lat;
    if (lng != null) data['longitude'] = lng;
    if (locationLabel != null) data['locationLabel'] = locationLabel;

    await _dio.post('/hrms/attendance/records/check-out', data: data);
  }

  Future<DashboardKPIs> getDashboardKPIs() async {
    try {
      final response = await _dio.get('/hrms/attendance/dashboard/kpis');
      final data = response.data;
      
      return DashboardKPIs(
        present: data['present'] ?? 0,
        absent: data['absent'] ?? 0,
        lateArrivals: data['lateArrivals'] ?? 0,
        onLeave: data['onLeave'] ?? 0,
        pendingLeaveRequests: data['pendingLeaveRequests'] ?? 0,
        regularizationRequests: data['regularizationRequests'] ?? 0,
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

  Future<List<TodayAttendanceSummary>> getTodayAttendance({String? employeeId}) async {
    try {
      final today = DateTime.now().toIso8601String().split('T').first;
      final query = <String, dynamic>{
        'startDate': today, 
        'endDate': today,
      };
      if (employeeId != null) query['employeeId'] = employeeId;
      
      final response = await _dio.get(
        '/hrms/attendance/records', 
        queryParameters: query,
      );
      if (response.data is List) {
        return (response.data as List).map((r) => TodayAttendanceSummary(
          employeeName: '${r['employee']?['firstName'] ?? ''} ${r['employee']?['lastName'] ?? ''}'.trim(),
          shift: r['shift']?['shiftName'] ?? '',
          checkInTime: r['checkIn']?.toString().split('T').last ?? '--:--',
          checkOutTime: r['checkOut']?.toString().split('T').last ?? '--:--',
          status: _toTitleCase(r['status']?.toString(), 'Absent'),
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
          status: _toTitleCase(l['status']?.toString(), 'Pending'),
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
          status: _toTitleCase(r['status']?.toString(), 'Pending'),
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
      if (model.employeeId != null) 'employee': {'id': model.employeeId},
    };
    await _dio.post('/hrms/attendance/regularizations', data: payload);
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
          status: _toTitleCase(l['status']?.toString(), 'Pending'),
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
      if (model.employeeId != null) 'employee': {'id': model.employeeId},
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
    final payload = {
      'shiftCode': model.shiftCode,
      'shiftName': model.shiftName,
      'startTime': model.startTime,
      'endTime': model.endTime,
      'graceTime': model.graceTimeMinutes,
    };
    try {
      final response = await _dio.post('/hrms/shifts', data: payload);
      final s = response.data;
      return ShiftModel(
        id: s['id'] ?? '',
        shiftName: s['shiftName'] ?? '',
        shiftCode: s['shiftCode'] ?? '',
        startTime: s['startTime']?.toString().split('T').last ?? '',
        endTime: s['endTime']?.toString().split('T').last ?? '',
        graceTimeMinutes: s['graceTime'] ?? 0,
      );
    } catch (e) {
      throw Exception('Failed to create shift: $e');
    }
  }

  // --- Calendar ---
  Future<List<AttendanceDayModel>> getAttendanceCalendar(int year, int month, {String? employeeId}) async {
    try {
      final startDate = DateTime(year, month, 1).toIso8601String().split('T').first;
      // Find the last day of the month
      final nextMonth = month < 12 ? month + 1 : 1;
      final nextMonthYear = month < 12 ? year : year + 1;
      final endDate = DateTime(nextMonthYear, nextMonth, 0).toIso8601String().split('T').first;

      final query = <String, dynamic>{
        'startDate': startDate,
        'endDate': endDate,
      };
      if (employeeId != null && employeeId.isNotEmpty) {
        query['employeeId'] = employeeId;
      }

      final response = await _dio.get('/hrms/attendance/records', queryParameters: query);
      
      final Map<String, dynamic> recordMap = {};
      if (response.data is List) {
        for (var r in response.data) {
          if (r['attendanceDate'] != null) {
            recordMap[r['attendanceDate']] = r;
          }
        }
      }

      List<AttendanceDayModel> days = [];
      final daysInMonth = DateTime(nextMonthYear, nextMonth, 0).day; // A simple way to get days in month without DateUtils if missing
      
      for (int i = 1; i <= daysInMonth; i++) {
        final date = DateTime(year, month, i);
        // Format manually to ensure YYYY-MM-DD local, as toIso8601String() on local might differ
        final mm = month.toString().padLeft(2, '0');
        final dd = i.toString().padLeft(2, '0');
        final dateStr = '$year-$mm-$dd';
        
        if (recordMap.containsKey(dateStr)) {
          final r = recordMap[dateStr];
          
          String? inTime;
          String? outTime;
          if (r['checkIn'] != null) {
             final inDt = DateTime.tryParse(r['checkIn'])?.toLocal();
             if (inDt != null) {
               final hr = inDt.hour > 12 ? inDt.hour - 12 : (inDt.hour == 0 ? 12 : inDt.hour);
               final ampm = inDt.hour >= 12 ? 'PM' : 'AM';
               inTime = '${hr.toString().padLeft(2, '0')}:${inDt.minute.toString().padLeft(2, '0')} $ampm';
             }
          }
          if (r['checkOut'] != null) {
             final outDt = DateTime.tryParse(r['checkOut'])?.toLocal();
             if (outDt != null) {
               final hr = outDt.hour > 12 ? outDt.hour - 12 : (outDt.hour == 0 ? 12 : outDt.hour);
               final ampm = outDt.hour >= 12 ? 'PM' : 'AM';
               outTime = '${hr.toString().padLeft(2, '0')}:${outDt.minute.toString().padLeft(2, '0')} $ampm';
             }
          }
          
          days.add(AttendanceDayModel(
            date: date,
            status: r['status'] ?? 'Absent',
            inTime: inTime,
            outTime: outTime,
            shiftCode: 'S1',
          ));
        } else {
          if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
            days.add(AttendanceDayModel(date: date, status: 'Weekend'));
          } else {
            if (date.isAfter(DateTime.now())) {
              days.add(AttendanceDayModel(date: date, status: 'Pending'));
            } else {
              days.add(AttendanceDayModel(date: date, status: 'Absent'));
            }
          }
        }
      }
      return days;
    } catch (e) {
      return [];
    }
  }

  // --- Daily Attendance Logs ---
  Future<List<DailyAttendanceModel>> getDailyAttendanceLogs({String? employeeId}) async {
    try {
      final today = DateTime.now().toIso8601String().split('T').first;
      final query = <String, dynamic>{
        'startDate': today, 
        'endDate': today,
      };
      if (employeeId != null) query['employeeId'] = employeeId;
      
      final response = await _dio.get('/hrms/attendance/records', queryParameters: query);
      
      if (response.data is List) {
        return (response.data as List).map((r) {
          return DailyAttendanceModel(
            id: r['id'] ?? '',
            employeeName: '${r['employee']?['firstName'] ?? ''} ${r['employee']?['lastName'] ?? ''}'.trim(),
            employeeCode: r['employee']?['employeeCode'] ?? '',
            department: r['department']?['departmentName'] ?? '',
            shiftName: r['shift']?['shiftName'] ?? '',
            checkIn: r['checkIn']?.toString().split('T').last ?? '--:--',
            checkOut: r['checkOut']?.toString().split('T').last ?? '--:--',
            workingHours: (r['workingHours'] ?? 0).toString(),
            status: _toTitleCase(r['status']?.toString(), 'Present'),
            exceptionType: r['exceptionType'],
            isRegularized: r['regularized'] ?? false,
            checkInLocation: r['checkInLocation'],
            checkInLat: r['checkInLatitude'] != null ? double.tryParse(r['checkInLatitude'].toString()) : null,
            checkInLng: r['checkInLongitude'] != null ? double.tryParse(r['checkInLongitude'].toString()) : null,
            checkOutLocation: r['checkOutLocation'],
            checkOutLat: r['checkOutLatitude'] != null ? double.tryParse(r['checkOutLatitude'].toString()) : null,
            checkOutLng: r['checkOutLongitude'] != null ? double.tryParse(r['checkOutLongitude'].toString()) : null,
          );
        }).toList();
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
          status: _toTitleCase(p['status']?.toString(), 'Pending'),
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
      if (model.employeeId != null) 'employee': {'id': model.employeeId},
    };
    await _dio.post('/hrms/attendance/permissions', data: payload);
    return model;
  }
}

