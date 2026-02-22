import 'dart:async';
import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:easy_refresh/easy_refresh.dart';
import '../l10n/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/notification_service.dart';
import '../services/ticket_service.dart';
import '../services/assistant_persona_service.dart';
import '../services/update_service.dart';
import '../theme/miaoji_theme.dart';
import '../widgets/alarm_sound_picker.dart';
import '../widgets/app_toast.dart';
import 'about_page.dart';

/// 内购产品 ID（需在 App Store Connect 中配置）
const _kProductIds = <String>{
  'miaojidou_500', // ¥25 / 500 次
  'miaojidou_1000', // ¥45 / 1000 次
  'miaojidou_5000', // ¥215 / 5000 次
};

/// 产品展示信息（作为 fallback）
const _kProductFallback = [
  _PlanInfo(id: 'miaojidou_500', times: 500, price: '¥12', unitPrice: '0.024'),
  _PlanInfo(
    id: 'miaojidou_1000',
    times: 1000,
    price: '¥22',
    unitPrice: '0.022',
  ),
  _PlanInfo(
    id: 'miaojidou_5000',
    times: 5000,
    price: '¥100',
    unitPrice: '0.02',
  ),
];

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with WidgetsBindingObserver {
  final TicketService _ticketService = TicketService();
  final NotificationService _notifService = NotificationService();
  final AssistantPersonaService _assistantPersonaService =
      AssistantPersonaService();
  final InAppPurchase _iap = InAppPurchase.instance;

  String? _ticketId;
  int? _balance;
  bool _balanceLoading = true;
  bool _notificationEnabled = true; // 默认 true，避免闪烁
  String _assistantPersona = '';

  bool _iapAvailable = false;
  List<ProductDetails> _products = [];
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  final ValueNotifier<bool> _purchasing = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTicketAndBalance();
    _checkNotificationPermission();
    _loadAssistantPersona();
    _initIAP();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _purchaseSub?.cancel();
    _purchasing.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 用户从设置返回时，重新检查通知权限
      _checkNotificationPermission();
      // 用户从 Apple ID 登录页返回 App 时，
      // 如果 StoreKit 没有发送取消事件，延迟兜底重置
      if (_purchasing.value) {
        Future.delayed(const Duration(seconds: 2), () {
          if (_purchasing.value) {
            _purchasing.value = false;
          }
        });
      }
    }
  }

  Future<void> _checkNotificationPermission() async {
    final enabled = await _notifService.checkNotificationPermission();
    if (!mounted) return;
    setState(() => _notificationEnabled = enabled);
  }

  Future<void> _loadTicketAndBalance({bool showLoading = true}) async {
    if (showLoading) {
      setState(() => _balanceLoading = true);
    }
    final ticketId = await _ticketService.getTicketId();
    final balance = await _ticketService.getBalance();
    if (!mounted) return;
    setState(() {
      _ticketId = ticketId;
      _balance = balance;
      if (showLoading) {
        _balanceLoading = false;
      }
    });
  }

  Future<void> _onRefresh() async {
    try {
      await Future.wait([
        _loadTicketAndBalance(showLoading: false),
        _checkNotificationPermission(),
        _loadAssistantPersona(),
      ]);
    } finally {
      if (mounted) {}
    }
  }

  Future<void> _loadAssistantPersona() async {
    final persona = await _assistantPersonaService.getPersona();
    if (!mounted) return;
    setState(() => _assistantPersona = persona);
  }

  Future<void> _showAssistantPersonaSheet() async {
    final l10n = context.l10n;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AssistantPersonaSheet(
        initialPersona: _assistantPersona,
        onSave: (value) => _assistantPersonaService.setPersona(value),
      ),
    );

    if (saved != true) return;
    await _loadAssistantPersona();
    if (!mounted) return;
    AppToast.show(l10n.assistantPersonaSaved);
  }

  Future<void> _initIAP() async {
    final available = await _iap.isAvailable();
    if (!available) {
      debugPrint('IAP: 不可用');
      return;
    }
    setState(() => _iapAvailable = true);

    // 监听购买流
    _purchaseSub = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (e) => debugPrint('IAP error: $e'),
    );

    // 查询产品
    final response = await _iap.queryProductDetails(_kProductIds);
    if (response.error != null) {
      debugPrint('IAP queryProducts error: ${response.error}');
    }
    if (mounted) {
      setState(() {
        _products = response.productDetails
          ..sort((a, b) {
            // 按价格排序
            final aIdx = _kProductFallback.indexWhere((p) => p.id == a.id);
            final bIdx = _kProductFallback.indexWhere((p) => p.id == b.id);
            return aIdx.compareTo(bIdx);
          });
      });
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // 购买成功 → 先发收据到服务端验证，再 complete
        _verifyAndComplete(purchase);
      } else if (purchase.status == PurchaseStatus.error) {
        _iap.completePurchase(purchase);
        if (mounted) {
          Navigator.of(context).pop(); // 关闭充值 BottomSheet
          _purchasing.value = false;
          AppToast.show(
            context.l10n.purchaseFailed(
              purchase.error?.message ?? context.l10n.unknownError,
            ),
          );
        }
      } else if (purchase.status == PurchaseStatus.canceled) {
        _purchasing.value = false;
      } else if (purchase.status == PurchaseStatus.pending) {
        _purchasing.value = true;
      }
    }
  }

  Future<void> _verifyAndComplete(PurchaseDetails purchase) async {
    final receipt = purchase.verificationData.serverVerificationData;
    final productId = purchase.productID;
    final transactionId = purchase.purchaseID ?? '';

    debugPrint('IAP: 开始验证收据, product=$productId, txn=$transactionId');
    debugPrint('IAP: receipt长度=${receipt.length}');
    debugPrint(
      'IAP: receipt前100字符=${receipt.substring(0, receipt.length > 100 ? 100 : receipt.length)}',
    );
    debugPrint('IAP: source=${purchase.verificationData.source}');
    debugPrint(
      'IAP: localVerificationData长度=${purchase.verificationData.localVerificationData.length}',
    );

    final result = await _ticketService.verifyApplePurchase(
      receipt: receipt,
      productId: productId,
      transactionId: transactionId,
    );

    // 无论验证成功与否都要 completePurchase，否则交易会卡住
    _iap.completePurchase(purchase);

    // 关闭充值 BottomSheet
    if (mounted) Navigator.of(context).pop();

    if (result != null) {
      _loadTicketAndBalance(); // 刷新余额
      if (mounted) {
        _purchasing.value = false;
        AppToast.show(context.l10n.rechargeSuccess(result.amount));
      }
    } else {
      if (mounted) {
        _purchasing.value = false;
        AppToast.show(context.l10n.rechargeVerifyFailed);
      }
    }
  }

  Future<void> _buyProduct(ProductDetails product) async {
    if (_ticketId == null) {
      AppToast.show(context.l10n.ticketInitializing);
      return;
    }
    _purchasing.value = true;
    final purchaseParam = PurchaseParam(
      productDetails: product,
      applicationUserName: _ticketId,
    );
    try {
      final started = await _iap.buyConsumable(purchaseParam: purchaseParam);
      if (!started) {
        // 购买未能发起（如用户在 Apple ID 登录时取消）
        _purchasing.value = false;
      }
    } catch (e) {
      _purchasing.value = false;
      if (mounted) {
        AppToast.show(context.l10n.purchaseFailed(e.toString()));
      }
    }
  }

  // ══════════════════════════════════════════
  //  检查更新（仅安卓）
  // ══════════════════════════════════════════

  Future<void> _checkUpdate() =>
      UpdateService.checkAndShowIfNeeded(context, showFeedback: true);

  /// 安卓充值：优先打开淘宝 App，否则回退 H5
  static const _kAndroidRechargeTaobaoApp =
      'taobao://item.taobao.com/item.htm?id=1021064986912';
  static const _kAndroidRechargeH5 =
      'https://m.intl.taobao.com/detail/detail.html?ft=t&id=1021064986912';

  Future<void> _showPurchaseSheet() async {
    if (Platform.isAndroid) {
      final taobaoAppUri = Uri.parse(_kAndroidRechargeTaobaoApp);
      try {
        final launched = await launchUrl(
          taobaoAppUri,
          mode: LaunchMode.externalApplication,
        );
        if (!launched && mounted) {
          await launchUrl(
            Uri.parse(_kAndroidRechargeH5),
            mode: LaunchMode.externalApplication,
          );
        }
      } catch (_) {
        if (mounted) {
          await launchUrl(
            Uri.parse(_kAndroidRechargeH5),
            mode: LaunchMode.externalApplication,
          );
        }
      }
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PurchaseSheet(
        products: _products,
        fallback: _kProductFallback,
        iapAvailable: _iapAvailable,
        purchasingNotifier: _purchasing,
        onBuy: _buyProduct,
      ),
    );
  }

  void _showRestoreSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _RestoreSheet(
        ticketId: _ticketId,
        onImport: (id) async {
          final ok = await _ticketService.importTicket(id);
          if (!mounted) return;
          if (ok) {
            _loadTicketAndBalance();
            AppToast.show(context.l10n.ticketImportSuccess);
          } else {
            AppToast.show(context.l10n.ticketInvalid);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MiaojiColors.background,
      body: EasyRefresh.builder(
        onRefresh: _onRefresh,
        header: ClassicHeader(
          position: IndicatorPosition.locator,
          dragText: context.l10n.refreshDrag,
          armedText: context.l10n.refreshArmed,
          readyText: context.l10n.refreshReady,
          processingText: context.l10n.refreshProcessing,
          processedText: context.l10n.refreshProcessed,
          failedText: context.l10n.refreshFailed,
          showMessage: false,
          iconDimension: 18,
          spacing: 8,
          textStyle: TextStyle(
            color: MiaojiColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: MiaojiColors.textSecondary),
        ),
        childBuilder: (context, physics) {
          return CustomScrollView(
            physics: physics,
            slivers: [
              // 吸顶 Header
              SliverAppBar(
                pinned: true,
                floating: false,
                toolbarHeight: 60,
                backgroundColor: MiaojiColors.background,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0.5,
                automaticallyImplyLeading: false,
                title: Text(
                  context.l10n.profileTitle,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),

              // 标题下方刷新提示
              const HeaderLocator.sliver(),

              // 通知未授权提醒
              if (!_notificationEnabled)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                    child: _buildNotificationBanner(),
                  ),
                ),

              // 余额卡片
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: _buildBalanceCard(),
                ),
              ),

              // 设置列表
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: _buildSettingsSection(),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  // ══════════════════════════════════════════
  //  通知未授权提醒横幅
  // ══════════════════════════════════════════

  Future<void> _openNotificationSettings() async {
    AppSettings.openAppSettings(type: AppSettingsType.notification);
  }

  Widget _buildNotificationBanner() {
    return GestureDetector(
      onTap: _openNotificationSettings,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: MiaojiColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(MiaojiRadius.lg),
          border: Border.all(
            color: MiaojiColors.warning.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: MiaojiColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.notifications_off_rounded,
                size: 20,
                color: MiaojiColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.notificationDisabledTitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: MiaojiColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    context.l10n.notificationDisabledDesc,
                    style: const TextStyle(
                      fontSize: 12,
                      color: MiaojiColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: MiaojiColors.warning,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                context.l10n.notificationDisabledAction,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════
  //  余额卡片
  // ══════════════════════════════════════════

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3D3124), Color(0xFF5A4532)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(MiaojiRadius.xl),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3D3124).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF8B7355).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A24C).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD4A24C).withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.confirmation_number_rounded,
                  size: 20,
                  color: Color(0xFFD4A24C),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.balanceTitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFFF5EFE0).withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 2),
                  _balanceLoading
                      ? SizedBox(
                          width: 60,
                          height: 20,
                          child: LinearProgressIndicator(
                            borderRadius: BorderRadius.circular(4),
                            backgroundColor: const Color(
                              0xFFD4A24C,
                            ).withValues(alpha: 0.1),
                            color: const Color(
                              0xFFD4A24C,
                            ).withValues(alpha: 0.4),
                          ),
                        )
                      : Row(
                          children: [
                            Text(
                              context.l10n.balanceCount(_balance ?? 0),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFD4A24C),
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                ],
              ),
              const Spacer(),
              // 充值按钮
              GestureDetector(
                onTap: _showPurchaseSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4A24C),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4A24C).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_rounded,
                        size: 16,
                        color: Color(0xFF3D3124),
                      ),
                      SizedBox(width: 4),
                      Text(
                        context.l10n.purchaseRecharge,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3D3124),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  //  设置列表
  // ══════════════════════════════════════════

  Widget _buildSettingsSection() {
    final items = [
      _SettingItem(
        Icons.restore_rounded,
        context.l10n.restorePurchasesTitle,
        MiaojiColors.info,
        onTap: _showRestoreSheet,
      ),
      _SettingItem(
        Icons.notifications_active_rounded,
        context.l10n.notificationSoundSetting,
        MiaojiColors.warning,
        onTap: () {
          if (Platform.isAndroid) {
            // 安卓直接跳转到系统通知设置页
            AppSettings.openAppSettings(type: AppSettingsType.notification);
          } else {
            showAlarmSoundPicker(context);
          }
        },
      ),
      _SettingItem(
        Icons.psychology_alt_rounded,
        context.l10n.assistantPersonaSetting,
        const Color(0xFF6B8DD6),
        subtitle: _assistantPersona.isEmpty
            ? context.l10n.assistantPersonaDescription
            : _assistantPersona,
        onTap: _showAssistantPersonaSheet,
      ),
      _SettingItem(
        Icons.info_outline_rounded,
        context.l10n.aboutTitle,
        const Color(0xFF8B6BAD),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AboutPage()),
        ),
      ),
      if (Platform.isAndroid)
        _SettingItem(
          Icons.system_update_rounded,
          context.l10n.checkUpdateTitle,
          const Color(0xFF4CAF50),
          onTap: _checkUpdate,
        ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: MiaojiColors.card,
        borderRadius: BorderRadius.circular(MiaojiRadius.xl),
        boxShadow: MiaojiShadows.paper,
        border: Border.all(color: MiaojiColors.borderLight, width: 1),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Column(
            children: [
              GestureDetector(
                onTap: item.onTap,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: item.color.withValues(alpha: 0.15),
                            width: 1,
                          ),
                        ),
                        child: Icon(item.icon, color: item.color, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.label,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: MiaojiColors.textPrimary,
                              ),
                            ),
                            if (item.subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                item.subtitle!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: MiaojiColors.textHint,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: MiaojiColors.textHint,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              if (index < items.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(
                    height: 1,
                    color: MiaojiColors.divider.withValues(alpha: 0.5),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

/// 预设助手性格选项
enum _PersonaPreset { warm, concise, humorous, custom }

class _AssistantPersonaSheet extends StatefulWidget {
  final String initialPersona;
  final Future<void> Function(String value) onSave;

  const _AssistantPersonaSheet({
    required this.initialPersona,
    required this.onSave,
  });

  @override
  State<_AssistantPersonaSheet> createState() => _AssistantPersonaSheetState();
}

class _AssistantPersonaSheetState extends State<_AssistantPersonaSheet> {
  late final TextEditingController _controller;
  bool _saving = false;
  _PersonaPreset _selected = _PersonaPreset.custom;

  /// 获取预设对应的 prompt 文本
  String _presetPrompt(_PersonaPreset preset) {
    final l10n = context.l10n;
    switch (preset) {
      case _PersonaPreset.warm:
        return l10n.assistantPersonaPresetWarmPrompt;
      case _PersonaPreset.concise:
        return l10n.assistantPersonaPresetConcisePrompt;
      case _PersonaPreset.humorous:
        return l10n.assistantPersonaPresetHumorousPrompt;
      case _PersonaPreset.custom:
        return '';
    }
  }

  /// 根据当前已保存的 persona 文本，匹配预设项
  _PersonaPreset _matchPreset(String persona) {
    final l10n = context.l10n;
    if (persona == l10n.assistantPersonaPresetWarmPrompt) {
      return _PersonaPreset.warm;
    }
    if (persona == l10n.assistantPersonaPresetConcisePrompt) {
      return _PersonaPreset.concise;
    }
    if (persona == l10n.assistantPersonaPresetHumorousPrompt) {
      return _PersonaPreset.humorous;
    }
    return _PersonaPreset.custom;
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialPersona);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selected = _matchPreset(widget.initialPersona);
    // 自定义模式时保留原文本，预设模式时不需要编辑框文本
    if (_selected != _PersonaPreset.custom) {
      _controller.text = '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectPreset(_PersonaPreset preset) {
    setState(() {
      _selected = preset;
      if (preset != _PersonaPreset.custom) {
        _controller.text = '';
      }
    });
  }

  String get _currentPersonaValue {
    if (_selected == _PersonaPreset.custom) {
      return _controller.text;
    }
    return _presetPrompt(_selected);
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    await widget.onSave(_currentPersonaValue);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    final presets = [
      (
        key: _PersonaPreset.warm,
        icon: Icons.favorite_rounded,
        color: const Color(0xFFE8836B),
        title: l10n.assistantPersonaPresetWarm,
        desc: l10n.assistantPersonaPresetWarmDesc,
      ),
      (
        key: _PersonaPreset.concise,
        icon: Icons.bolt_rounded,
        color: const Color(0xFF5B8C5A),
        title: l10n.assistantPersonaPresetConcise,
        desc: l10n.assistantPersonaPresetConciseDesc,
      ),
      (
        key: _PersonaPreset.humorous,
        icon: Icons.sentiment_very_satisfied_rounded,
        color: const Color(0xFFD4A24C),
        title: l10n.assistantPersonaPresetHumorous,
        desc: l10n.assistantPersonaPresetHumorousDesc,
      ),
    ];

    return AnimatedPadding(
      duration: const Duration(milliseconds: 120),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: MiaojiColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, bottomPad > 0 ? 12 : 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 拖拽条
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: MiaojiColors.textHint.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.assistantPersonaTitle,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: MiaojiColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.assistantPersonaHint,
                  style: const TextStyle(
                    fontSize: 12,
                    color: MiaojiColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 16),

                // ── 预设选项 ──
                Text(
                  l10n.assistantPersonaPresetLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: MiaojiColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                ...presets.map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _PresetCard(
                      icon: p.icon,
                      color: p.color,
                      title: p.title,
                      description: p.desc,
                      selected: _selected == p.key,
                      onTap: () => _selectPreset(p.key),
                    ),
                  ),
                ),

                // ── 自定义选项 ──
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _PresetCard(
                    icon: Icons.edit_rounded,
                    color: const Color(0xFF6B8DD6),
                    title: l10n.assistantPersonaCustomLabel,
                    description: null,
                    selected: _selected == _PersonaPreset.custom,
                    onTap: () => _selectPreset(_PersonaPreset.custom),
                  ),
                ),

                // 自定义输入框（仅选中自定义时展示）
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: _selected == _PersonaPreset.custom
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: TextField(
                            controller: _controller,
                            maxLines: 4,
                            minLines: 3,
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: l10n.assistantPersonaCustomPlaceholder,
                              hintStyle: const TextStyle(
                                color: MiaojiColors.textHint,
                                fontSize: 13,
                              ),
                              filled: true,
                              fillColor: MiaojiColors.surfaceVariant,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: MiaojiColors.borderLight,
                                  width: 1,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: MiaojiColors.borderLight,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: MiaojiColors.primary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving
                            ? null
                            : () => Navigator.of(context).pop(false),
                        child: Text(l10n.cancelAction),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _saving ? null : _save,
                        child: Text(l10n.saveAction),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 预设性格选项卡片
class _PresetCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? description;
  final bool selected;
  final VoidCallback onTap;

  const _PresetCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.08) : MiaojiColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? color.withValues(alpha: 0.5)
                : MiaojiColors.borderLight,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: selected ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selected ? color : MiaojiColors.textPrimary,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      description!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: MiaojiColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AnimatedOpacity(
              opacity: selected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 150),
              child: Icon(Icons.check_circle_rounded, size: 20, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingItem {
  final IconData icon;
  final String label;
  final Color color;
  final String? subtitle;
  final VoidCallback? onTap;
  const _SettingItem(
    this.icon,
    this.label,
    this.color, {
    this.subtitle,
    this.onTap,
  });
}

class _PlanInfo {
  final String id;
  final int times;
  final String price;
  final String unitPrice;

  const _PlanInfo({
    required this.id,
    required this.times,
    required this.price,
    required this.unitPrice,
  });
}


// ═══════════════════════════════════════════
//  内购恢复 BottomSheet
// ═══════════════════════════════════════════

class _RestoreSheet extends StatefulWidget {
  final String? ticketId;
  final Future<void> Function(String id) onImport;

  const _RestoreSheet({required this.ticketId, required this.onImport});

  @override
  State<_RestoreSheet> createState() => _RestoreSheetState();
}

class _RestoreSheetState extends State<_RestoreSheet> {
  final _controller = TextEditingController();
  bool _importing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _copyTicket() {
    if (widget.ticketId == null) return;
    Clipboard.setData(ClipboardData(text: widget.ticketId!));
    HapticFeedback.lightImpact();
    AppToast.show(context.l10n.ticketCopied);
  }

  Future<void> _doImport() async {
    final id = _controller.text.trim();
    if (id.isEmpty) return;
    setState(() => _importing = true);
    Navigator.of(context).pop();
    await widget.onImport(id);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 120),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: MiaojiColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPad > 0 ? 0 : 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 拖拽条
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 20),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: MiaojiColors.textHint.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // 标题
                Row(
                  children: [
                    Icon(
                      Icons.restore_rounded,
                      size: 18,
                      color: MiaojiColors.info,
                    ),
                    SizedBox(width: 8),
                    Text(
                      context.l10n.restorePurchasesTitle,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: MiaojiColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  context.l10n.restorePurchasesDesc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: MiaojiColors.textHint,
                  ),
                ),
                const SizedBox(height: 20),

                // ── 导出 ──
                Text(
                  context.l10n.ticketExportTitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: MiaojiColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _copyTicket,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: MiaojiColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: MiaojiColors.borderLight,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.ticketId ?? context.l10n.loadingShort,
                            style: const TextStyle(
                              fontSize: 13,
                              color: MiaojiColors.textPrimary,
                              fontFamily: 'monospace',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.copy_rounded,
                          size: 16,
                          color: MiaojiColors.textHint,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── 导入 ──
                Text(
                  context.l10n.ticketImportTitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: MiaojiColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: 'monospace',
                        ),
                        decoration: InputDecoration(
                          hintText: context.l10n.ticketPasteHint,
                          hintStyle: const TextStyle(
                            fontSize: 13,
                            color: MiaojiColors.textHint,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          filled: true,
                          fillColor: MiaojiColors.surfaceVariant,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: MiaojiColors.borderLight,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: MiaojiColors.borderLight,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: MiaojiColors.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _importing ? null : _doImport,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: MiaojiColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _importing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                context.l10n.ticketImportAction,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
//  充值 BottomSheet
// ═══════════════════════════════════════════

class _PurchaseSheet extends StatelessWidget {
  final List<ProductDetails> products;
  final List<_PlanInfo> fallback;
  final bool iapAvailable;
  final ValueNotifier<bool> purchasingNotifier;
  final void Function(ProductDetails) onBuy;

  const _PurchaseSheet({
    required this.products,
    required this.fallback,
    required this.iapAvailable,
    required this.purchasingNotifier,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: MiaojiColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPad > 0 ? 0 : 16),
          child: ValueListenableBuilder<bool>(
            valueListenable: purchasingNotifier,
            builder: (context, purchasing, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 拖拽条
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 20),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: MiaojiColors.textHint.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // 标题
                  Row(
                    children: [
                      Icon(
                        Icons.shopping_bag_rounded,
                        size: 18,
                        color: MiaojiColors.primary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        context.l10n.purchaseSheetTitle,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: MiaojiColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 套餐列表
                  ..._buildCards(purchasing),
                  if (purchasing)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: MiaojiColors.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            context.l10n.purchaseProcessing,
                            style: const TextStyle(
                              fontSize: 13,
                              color: MiaojiColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCards(bool purchasing) {
    if (products.isNotEmpty) {
      return products.map((product) {
        final fb = fallback.where((p) => p.id == product.id).firstOrNull;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _PlanCard(
            times: fb?.times ?? 0,
            price: product.price,
            unitPrice: fb?.unitPrice ?? '',
            highlight: fb?.id == 'miaojidou_1000',
            onTap: purchasing ? null : () => onBuy(product),
          ),
        );
      }).toList();
    }

    return fallback.map((plan) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _PlanCard(
          times: plan.times,
          price: plan.price,
          unitPrice: plan.unitPrice,
          highlight: plan.id == 'miaojidou_1000',
          onTap: null,
        ),
      );
    }).toList();
  }
}

class _PlanCard extends StatelessWidget {
  final int times;
  final String price;
  final String unitPrice;
  final bool highlight;
  final VoidCallback? onTap;

  const _PlanCard({
    required this.times,
    required this.price,
    required this.unitPrice,
    this.highlight = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: highlight
              ? MiaojiColors.primary.withValues(alpha: 0.04)
              : MiaojiColors.card,
          borderRadius: BorderRadius.circular(MiaojiRadius.lg),
          border: Border.all(
            color: highlight
                ? MiaojiColors.primary.withValues(alpha: 0.3)
                : MiaojiColors.borderLight,
            width: highlight ? 1.5 : 1,
          ),
          boxShadow: MiaojiShadows.sm,
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$times',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: highlight
                            ? MiaojiColors.primary
                            : MiaojiColors.textPrimary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      context.l10n.purchaseTimesUnit,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: highlight
                            ? MiaojiColors.primary
                            : MiaojiColors.textSecondary,
                      ),
                    ),
                    if (highlight) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: MiaojiColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          context.l10n.purchaseRecommended,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: MiaojiColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.purchaseUnitPrice(unitPrice),
                  style: const TextStyle(
                    fontSize: 11,
                    color: MiaojiColors.textHint,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: highlight
                    ? MiaojiColors.primary
                    : MiaojiColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: highlight
                    ? null
                    : Border.all(color: MiaojiColors.borderLight, width: 1),
              ),
              child: Text(
                price,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: highlight ? Colors.white : MiaojiColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
