import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_config.dart';

/// Keychain 中存储的 ticket 键
const _kTicketId = 'keepy_ticket_id';

/// Ticket 服务 — 管理次卡 API Key
/// ticket 存储在 iOS Keychain 中，卸载重装后仍然保留
class TicketService {
  static final TicketService _instance = TicketService._internal();
  factory TicketService() => _instance;
  TicketService._internal();

  static const String _baseUrl = apiBaseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _cachedTicketId;

  /// 防止并发调用重复生成 ticket
  Future<String?>? _pendingGetTicket;

  /// 获取当前 ticket id（内存 -> Keychain -> 请求接口）
  /// 并发安全：多次调用只会触发一次实际请求
  Future<String?> getTicketId() {
    if (_cachedTicketId != null) return Future.value(_cachedTicketId);
    return _pendingGetTicket ??= _doGetTicketId().whenComplete(() {
      _pendingGetTicket = null;
    });
  }

  Future<String?> _doGetTicketId() async {
    // Keychain 缓存（卸载重装后仍存在）
    final stored = await _storage.read(key: _kTicketId);
    if (stored != null && stored.isNotEmpty) {
      _cachedTicketId = stored;
      debugPrint('TicketService: 从 Keychain 读取 ticket: $stored');
      return stored;
    }

    // 请求生成
    return await generateTicket();
  }

  /// 获取安卓设备 ID（用于卸载重装后恢复 ticket）
  Future<String?> _getAndroidDeviceId() async {
    if (!Platform.isAndroid) return null;
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final id = androidInfo.id; // Settings.Secure.ANDROID_ID
      debugPrint('TicketService: Android device id: $id');
      return id.isNotEmpty ? id : null;
    } catch (e) {
      debugPrint('TicketService: 获取 Android device id 失败: $e');
      return null;
    }
  }

  /// 调用 /ticket/generate 生成新 ticket
  Future<String?> generateTicket() async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 10);
    try {
      // 安卓上附带 device_id，服务端可据此在卸载重装后返回同一 ticket
      final deviceId = await _getAndroidDeviceId();
      final payload = <String, dynamic>{};
      if (deviceId != null) {
        payload['device_id'] = deviceId;
      }

      final uri = Uri.parse('$_baseUrl/ticket/generate');
      final request = await client.postUrl(uri);
      request.headers
          .set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
      request.add(utf8.encode(jsonEncode(payload)));
      final response = await request.close();

      if (response.statusCode != 200) {
        final body = await response.transform(utf8.decoder).join();
        debugPrint(
            'TicketService: generate 失败 (${response.statusCode}): $body');
        return null;
      }

      final body = await response.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final ticketId = json['ticket_id'] as String?;

      if (ticketId != null && ticketId.isNotEmpty) {
        _cachedTicketId = ticketId;
        await _storage.write(key: _kTicketId, value: ticketId);
        debugPrint('TicketService: 生成 ticket 并存入 Keychain: $ticketId');
        return ticketId;
      }

      debugPrint('TicketService: 响应无 ticket_id: $body');
      return null;
    } catch (e) {
      debugPrint('TicketService: generate 异常: $e');
      return null;
    } finally {
      client.close();
    }
  }

  /// 查询余额
  Future<int?> getBalance() async {
    final ticketId = await getTicketId();
    if (ticketId == null) return null;

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 10);
    try {
      final uri = Uri.parse('$_baseUrl/ticket/balance');
      final request = await client.postUrl(uri);
      request.headers.set(
          HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
      final bodyBytes =
          utf8.encode(jsonEncode({'ticket_id': ticketId}));
      request.headers
          .set(HttpHeaders.contentLengthHeader, bodyBytes.length.toString());
      request.add(bodyBytes);
      final response = await request.close();

      if (response.statusCode != 200) {
        final body = await response.transform(utf8.decoder).join();
        debugPrint(
            'TicketService: balance 失败 (${response.statusCode}): $body');
        return null;
      }

      final body = await response.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final balance = json['Balance'];
      if (balance is int) return balance;
      if (balance is num) return balance.toInt();
      return int.tryParse(balance.toString());
    } catch (e) {
      debugPrint('TicketService: balance 异常: $e');
      return null;
    } finally {
      client.close();
    }
  }

  /// 向服务端发送 Apple 收据进行验证充值
  /// 成功返回充值结果，失败返回 null
  Future<AppleRechargeResult?> verifyApplePurchase({
    required String receipt,
    required String productId,
    required String transactionId,
  }) async {
    final ticketId = await getTicketId();
    if (ticketId == null) return null;

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 15);
    try {
      final uri = Uri.parse('$_baseUrl/ticket/apple-recharge');
      final request = await client.postUrl(uri);
      request.headers.set(
          HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
      final payload = jsonEncode({
        'ticket_id': ticketId,
        'receipt': receipt,
        'product_id': productId,
        'transaction_id': transactionId,
      });
      debugPrint('TicketService: apple-recharge 请求:');
      debugPrint('  ticket_id=$ticketId');
      debugPrint('  product_id=$productId');
      debugPrint('  transaction_id=$transactionId');
      debugPrint('  receipt长度=${receipt.length}');
      final bodyBytes = utf8.encode(payload);
      request.headers
          .set(HttpHeaders.contentLengthHeader, bodyBytes.length.toString());
      request.add(bodyBytes);
      final response = await request.close();

      final body = await response.transform(utf8.decoder).join();
      debugPrint(
          'TicketService: apple-recharge 响应 (${response.statusCode}): $body');
      if (response.statusCode == 200) {
        final json = jsonDecode(body) as Map<String, dynamic>;
        return AppleRechargeResult(
          amount: (json['amount'] as num?)?.toInt() ?? 0,
          productId: json['product_id'] as String? ?? productId,
          appleTransactionId:
              json['apple_transaction_id'] as String? ?? transactionId,
          environment: json['environment'] as String? ?? '',
        );
      }

      debugPrint(
          'TicketService: apple-recharge 失败 (${response.statusCode}): $body');
      return null;
    } catch (e) {
      debugPrint('TicketService: apple-recharge 异常: $e');
      return null;
    } finally {
      client.close();
    }
  }

  /// 导入已有 ticket（用于恢复购买）
  Future<bool> importTicket(String ticketId) async {
    _cachedTicketId = ticketId;
    await _storage.write(key: _kTicketId, value: ticketId);
    // 验证是否有效
    final balance = await getBalance();
    if (balance != null) {
      debugPrint('TicketService: 导入成功, 余额: $balance');
      return true;
    }
    debugPrint('TicketService: 导入的 ticket 无效');
    return false;
  }

  /// 获取缓存的 ticket（同步，可能为 null）
  String? get cachedTicketId => _cachedTicketId;
}

/// Apple 充值验证结果
class AppleRechargeResult {
  final int amount;
  final String productId;
  final String appleTransactionId;
  final String environment;

  const AppleRechargeResult({
    required this.amount,
    required this.productId,
    required this.appleTransactionId,
    required this.environment,
  });
}
