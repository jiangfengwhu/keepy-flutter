import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'api_config.dart';
import 'database_service.dart';
import 'ticket_service.dart';

const _kLastCheckinDate = 'last_checkin_date';

class CheckinService {
  static final CheckinService _instance = CheckinService._internal();
  factory CheckinService() => _instance;
  CheckinService._internal();

  static const String _baseUrl = apiBaseUrl;
  final DatabaseService _db = DatabaseService();

  Future<bool> hasCheckedInToday() async {
    final last = await _db.getKv(_kLastCheckinDate);
    return last == _formatDate(DateTime.now());
  }

  Future<CheckinResult> checkIn() async {
    final ticketId = await TicketService().getTicketId();
    if (ticketId == null || ticketId.isEmpty) {
      return const CheckinResult(
        success: false,
        errorType: CheckinErrorType.ticketUnavailable,
      );
    }

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 10);
    try {
      final uri = Uri.parse('$_baseUrl/checkin');
      final request = await client.postUrl(uri);
      request.headers.set('X-Ticket-ID', ticketId);
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final message = _extractMessage(body);
        await _db.setKv(_kLastCheckinDate, _formatDate(DateTime.now()));
        return CheckinResult(success: true, message: message);
      }

      final message = _extractMessage(body);
      debugPrint('CheckinService: checkin 失败 (${response.statusCode}): $body');
      return CheckinResult(
        success: false,
        message: message,
        errorType: CheckinErrorType.requestFailed,
      );
    } catch (e) {
      debugPrint('CheckinService: checkin 异常: $e');
      return const CheckinResult(
        success: false,
        errorType: CheckinErrorType.requestFailed,
      );
    } finally {
      client.close();
    }
  }

  String _formatDate(DateTime time) {
    final year = time.year.toString().padLeft(4, '0');
    final month = time.month.toString().padLeft(2, '0');
    final day = time.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String? _extractMessage(String body) {
    if (body.trim().isEmpty) return null;
    try {
      final map = jsonDecode(body) as Map<String, dynamic>;
      final message = map['message'];
      if (message == null) return null;
      final text = message.toString().trim();
      return text.isEmpty ? null : text;
    } catch (_) {
      return null;
    }
  }
}

class CheckinResult {
  final bool success;
  final String? message;
  final CheckinErrorType? errorType;

  const CheckinResult({required this.success, this.message, this.errorType});
}

enum CheckinErrorType { ticketUnavailable, requestFailed }
