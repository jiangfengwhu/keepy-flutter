import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../services/ticket_service.dart';
import '../theme/miaoji_theme.dart';

/// 内购产品 ID（需在 App Store Connect 中配置）
const _kProductIds = <String>{
  'miaojidou_500',  // ¥25 / 500 次
  'miaojidou_1000', // ¥45 / 1000 次
  'miaojidou_5000', // ¥215 / 5000 次
};

/// 产品展示信息（作为 fallback）
const _kProductFallback = [
  _PlanInfo(id: 'miaojidou_500', times: 500, price: '¥25', unitPrice: '0.05'),
  _PlanInfo(id: 'miaojidou_1000', times: 1000, price: '¥45', unitPrice: '0.045'),
  _PlanInfo(id: 'miaojidou_5000', times: 5000, price: '¥215', unitPrice: '0.043'),
];

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with WidgetsBindingObserver {
  final TicketService _ticketService = TicketService();
  final InAppPurchase _iap = InAppPurchase.instance;

  String? _ticketId;
  int? _balance;
  bool _balanceLoading = true;

  bool _iapAvailable = false;
  List<ProductDetails> _products = [];
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  final ValueNotifier<bool> _purchasing = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTicketAndBalance();
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
    // 用户从 Apple ID 登录页返回 App 时，
    // 如果 StoreKit 没有发送取消事件，延迟兜底重置
    if (state == AppLifecycleState.resumed && _purchasing.value) {
      Future.delayed(const Duration(seconds: 2), () {
        if (_purchasing.value) {
          _purchasing.value = false;
        }
      });
    }
  }

  Future<void> _loadTicketAndBalance() async {
    setState(() => _balanceLoading = true);
    final ticketId = await _ticketService.getTicketId();
    final balance = await _ticketService.getBalance();
    if (!mounted) return;
    setState(() {
      _ticketId = ticketId;
      _balance = balance;
      _balanceLoading = false;
    });
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
          _purchasing.value = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('购买失败: ${purchase.error?.message ?? "未知错误"}')),
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
    final receipt =
        purchase.verificationData.serverVerificationData;
    final productId = purchase.productID;
    final transactionId = purchase.purchaseID ?? '';

    debugPrint('IAP: 开始验证收据, product=$productId, txn=$transactionId');
    debugPrint('IAP: receipt长度=${receipt.length}');
    debugPrint('IAP: receipt前100字符=${receipt.substring(0, receipt.length > 100 ? 100 : receipt.length)}');
    debugPrint('IAP: source=${purchase.verificationData.source}');
    debugPrint('IAP: localVerificationData长度=${purchase.verificationData.localVerificationData.length}');

    final result = await _ticketService.verifyApplePurchase(
      receipt: receipt,
      productId: productId,
      transactionId: transactionId,
    );

    // 无论验证成功与否都要 completePurchase，否则交易会卡住
    _iap.completePurchase(purchase);

    if (result != null) {
      _loadTicketAndBalance(); // 刷新余额
      if (mounted) {
        _purchasing.value = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('充值成功！已到账 ${result.amount} 次')),
        );
      }
    } else {
      if (mounted) {
        _purchasing.value = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('充值验证失败，请联系客服')),
        );
      }
    }
  }

  Future<void> _buyProduct(ProductDetails product) async {
    if (_ticketId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket 初始化中，请稍后再试')),
      );
      return;
    }
    _purchasing.value = true;
    final purchaseParam = PurchaseParam(
      productDetails: product,
      applicationUserName: _ticketId,
    );
    try {
      final started =
          await _iap.buyConsumable(purchaseParam: purchaseParam);
      if (!started) {
        // 购买未能发起（如用户在 Apple ID 登录时取消）
        _purchasing.value = false;
      }
    } catch (e) {
      _purchasing.value = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('购买失败: $e')),
        );
      }
    }
  }

  void _showPurchaseSheet() {
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

  void _copyTicket() {
    if (_ticketId == null) return;
    Clipboard.setData(ClipboardData(text: _ticketId!));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ticket 已复制到剪贴板')),
    );
  }

  void _showImportDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('导入 Ticket'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '粘贴你的 Ticket ID',
          ),
          maxLines: 2,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final id = controller.text.trim();
              if (id.isEmpty) return;
              Navigator.pop(ctx);
              final ok = await _ticketService.importTicket(id);
              if (!mounted) return;
              if (ok) {
                _loadTicketAndBalance();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('导入成功！')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('无效的 Ticket')),
                );
              }
            },
            child: const Text('导入'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MiaojiColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
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
              '我的',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
            ),
          ),

          // 余额卡片
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: _buildBalanceCard(),
            ),
          ),

          // Ticket 管理
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: _buildTicketSection(),
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
                child: const Icon(Icons.confirmation_number_rounded,
                    size: 20, color: Color(0xFFD4A24C)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '剩余次数',
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
                            backgroundColor:
                                const Color(0xFFD4A24C).withValues(alpha: 0.1),
                            color:
                                const Color(0xFFD4A24C).withValues(alpha: 0.4),
                          ),
                        )
                      : Text(
                          '${_balance ?? 0} 次',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFD4A24C),
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                ],
              ),
              const Spacer(),
              // 充值按钮
              GestureDetector(
                onTap: _showPurchaseSheet,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded,
                          size: 16, color: Color(0xFF3D3124)),
                      SizedBox(width: 4),
                      Text(
                        '充值',
                        style: TextStyle(
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
  //  Ticket 管理
  // ══════════════════════════════════════════

  Widget _buildTicketSection() {
    return Container(
      decoration: BoxDecoration(
        color: MiaojiColors.card,
        borderRadius: BorderRadius.circular(MiaojiRadius.xl),
        boxShadow: MiaojiShadows.paper,
        border: Border.all(color: MiaojiColors.borderLight, width: 1),
      ),
      child: Column(
        children: [
          // 导出 Ticket
          _buildTicketAction(
            icon: Icons.file_upload_outlined,
            color: MiaojiColors.primary,
            label: '导出 Ticket',
            subtitle: _ticketId != null
                ? '${_ticketId!.substring(0, _ticketId!.length.clamp(0, 12))}…'
                : '加载中…',
            onTap: _copyTicket,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
                height: 1,
                color: MiaojiColors.divider.withValues(alpha: 0.5)),
          ),
          // 导入 Ticket
          _buildTicketAction(
            icon: Icons.file_download_outlined,
            color: MiaojiColors.info,
            label: '导入 Ticket',
            subtitle: '用于恢复已购买的次数',
            onTap: _showImportDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildTicketAction({
    required IconData icon,
    required Color color,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: color.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: MiaojiColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: MiaojiColors.textHint,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
    );
  }

  // ══════════════════════════════════════════
  //  设置列表
  // ══════════════════════════════════════════

  Widget _buildSettingsSection() {
    final items = [
      _SettingItem(
          Icons.notifications_outlined, '通知设置', MiaojiColors.warning),
      _SettingItem(
          Icons.info_outline_rounded, '关于', const Color(0xFF8B6BAD)),
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
                onTap: () {},
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
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
                        child:
                            Icon(item.icon, color: item.color, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          item.label,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: MiaojiColors.textPrimary,
                          ),
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

class _SettingItem {
  final IconData icon;
  final String label;
  final Color color;
  const _SettingItem(this.icon, this.label, this.color);
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
                  const Row(
                    children: [
                      Icon(Icons.shopping_bag_rounded,
                          size: 18, color: MiaojiColors.primary),
                      SizedBox(width: 8),
                      Text(
                        '充值次卡',
                        style: TextStyle(
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
                          const Text('处理中…',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: MiaojiColors.textTertiary)),
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
        final fb =
            fallback.where((p) => p.id == product.id).firstOrNull;
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
                      '次',
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
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: MiaojiColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '推荐',
                          style: TextStyle(
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
                  '约 $unitPrice 元/次',
                  style: const TextStyle(
                    fontSize: 11,
                    color: MiaojiColors.textHint,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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
