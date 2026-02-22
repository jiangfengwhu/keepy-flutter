import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../l10n/l10n_ext.dart';
import '../theme/miaoji_theme.dart';
import '../widgets/app_toast.dart';
import 'api_config.dart';

/// 远端版本信息（解析自 version.json）
class UpdateInfo {
  final String version;
  final int buildNumber;
  final String downloadUrl;
  final String releaseNotes;
  final bool forceUpdate;

  const UpdateInfo({
    required this.version,
    required this.buildNumber,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.forceUpdate,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      version: json['version'] as String? ?? '',
      buildNumber: json['build_number'] as int? ?? 0,
      downloadUrl: json['download_url'] as String? ?? '',
      releaseNotes: json['release_notes'] as String? ?? '',
      forceUpdate: json['force_update'] as bool? ?? false,
    );
  }
}

class UpdateService {
  /// 检查是否有新版本可用。
  /// 返回 [UpdateInfo] 表示有更新，返回 null 表示已是最新版本或检查失败。
  static Future<UpdateInfo?> checkUpdate() async {
    if (!Platform.isAndroid) return null;

    try {
      final response = await http
          .get(
            Uri.parse(updateVersionUrl),
            headers: {
              'Cache-Control': 'no-cache, no-store',
              'Pragma': 'no-cache',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        debugPrint('UpdateService: 请求 version.json 失败，状态码 ${response.statusCode}');
        return null;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final info = UpdateInfo.fromJson(json);

      if (info.version.isEmpty || info.buildNumber == 0) {
        debugPrint('UpdateService: version.json 数据无效');
        return null;
      }

      final packageInfo = await PackageInfo.fromPlatform();
      final currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;

      debugPrint(
        'UpdateService: 当前构建号=$currentBuildNumber，最新构建号=${info.buildNumber}',
      );

      if (info.buildNumber > currentBuildNumber) {
        return info;
      }
      return null;
    } catch (e) {
      debugPrint('UpdateService: 检查更新出错 $e');
      return null;
    }
  }

  /// 检查更新并按需弹窗。
  ///
  /// [context] 用于弹窗的上下文。
  /// [showFeedback] 为 true 时（手动触发），无论结果均给出提示；
  ///               为 false 时（自动触发），仅有新版本时才弹窗，静默失败。
  static Future<void> checkAndShowIfNeeded(
    BuildContext context, {
    bool showFeedback = false,
  }) async {
    if (!Platform.isAndroid) return;

    final l10n = context.l10n;

    if (showFeedback) {
      AppToast.show(l10n.checkUpdateChecking);
    }

    final info = await checkUpdate();

    if (!context.mounted) return;

    if (info == null) {
      if (showFeedback) {
        AppToast.show(l10n.checkUpdateLatest);
      }
      return;
    }

    // 弹出更新确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: !info.forceUpdate,
      builder: (ctx) => UpdateConfirmDialog(info: info),
    );

    if (confirmed != true || !context.mounted) return;

    // 弹出下载进度对话框
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => UpdateDownloadDialog(info: info),
    );
  }

  /// 下载 APK 并安装。
  /// [onProgress] 回调进度 0.0~1.0，[onError] 回调错误信息。
  static Future<void> downloadAndInstall(
    String downloadUrl, {
    required void Function(double progress) onProgress,
    required void Function(String error) onError,
  }) async {
    if (!Platform.isAndroid) return;

    try {
      final dir = await getExternalStorageDirectory();
      if (dir == null) {
        onError('无法获取存储目录');
        return;
      }

      final savePath = '${dir.path}/keepy-update.apk';
      final file = File(savePath);

      final request = http.Request('GET', Uri.parse(downloadUrl));
      final streamedResponse = await request.send().timeout(
        const Duration(minutes: 10),
      );

      if (streamedResponse.statusCode != 200) {
        onError('下载失败，状态码 ${streamedResponse.statusCode}');
        return;
      }

      final totalBytes = streamedResponse.contentLength ?? 0;
      int receivedBytes = 0;

      final sink = file.openWrite();
      await for (final chunk in streamedResponse.stream) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0) {
          onProgress(receivedBytes / totalBytes);
        }
      }
      await sink.close();

      onProgress(1.0);

      final result = await OpenFilex.open(savePath);
      if (result.type != ResultType.done) {
        onError('无法打开安装包：${result.message}');
      }
    } catch (e) {
      onError('下载或安装出错：$e');
    }
  }
}

// ═══════════════════════════════════════════
//  更新确认对话框
// ═══════════════════════════════════════════

class UpdateConfirmDialog extends StatelessWidget {
  final UpdateInfo info;
  const UpdateConfirmDialog({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      backgroundColor: MiaojiColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MiaojiRadius.xl),
      ),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.system_update_rounded,
              color: Color(0xFF4CAF50),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            l10n.checkUpdateAvailableTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: MiaojiColors.textPrimary,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              l10n.checkUpdateAvailableVersion(info.version),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4CAF50),
              ),
            ),
          ),
          if (info.releaseNotes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              info.releaseNotes,
              style: const TextStyle(
                fontSize: 13,
                color: MiaojiColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (!info.forceUpdate)
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              l10n.checkUpdateLater,
              style: const TextStyle(color: MiaojiColors.textHint),
            ),
          ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.checkUpdateInstallNow),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════
//  下载进度对话框
// ═══════════════════════════════════════════

class UpdateDownloadDialog extends StatefulWidget {
  final UpdateInfo info;
  const UpdateDownloadDialog({super.key, required this.info});

  @override
  State<UpdateDownloadDialog> createState() => _UpdateDownloadDialogState();
}

class _UpdateDownloadDialogState extends State<UpdateDownloadDialog> {
  double _progress = 0;
  bool _installing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    await UpdateService.downloadAndInstall(
      widget.info.downloadUrl,
      onProgress: (progress) {
        if (!mounted) return;
        setState(() {
          _progress = progress;
          if (progress >= 1.0) _installing = true;
        });
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _error = error);
      },
    );
    if (mounted && _error == null) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final percent = (_progress * 100).toInt();

    return AlertDialog(
      backgroundColor: MiaojiColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MiaojiRadius.xl),
      ),
      title: Text(
        _installing
            ? l10n.checkUpdateInstalling
            : l10n.checkUpdateDownloading,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: MiaojiColors.textPrimary,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_error != null)
            Text(
              l10n.checkUpdateDownloadFailed(_error!),
              style: const TextStyle(
                fontSize: 13,
                color: MiaojiColors.textSecondary,
              ),
            )
          else ...[
            Text(
              _installing
                  ? l10n.checkUpdateInstalling
                  : l10n.checkUpdateDownloadProgress(percent),
              style: const TextStyle(
                fontSize: 13,
                color: MiaojiColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _installing ? null : _progress,
                minHeight: 6,
                backgroundColor:
                    const Color(0xFF4CAF50).withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF4CAF50),
                ),
              ),
            ),
          ],
        ],
      ),
      actions: _error != null
          ? [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancelAction),
              ),
            ]
          : null,
    );
  }
}
