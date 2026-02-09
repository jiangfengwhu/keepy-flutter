import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../l10n/l10n_ext.dart';
import '../theme/miaoji_theme.dart';

/// 聊天输入栏组件 — 支持语音输入 + 图片发送
class ChatInputBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final VoidCallback? onPickImage;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSend,
    this.onPickImage,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar>
    with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;
  bool _isListening = false;
  bool _hasText = false;

  // 边框呼吸动画
  late AnimationController _borderController;
  late Animation<double> _borderAnim;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _hasText = widget.controller.text.trim().isNotEmpty;

    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _borderAnim = Tween<double>(begin: 1.5, end: 3.5).animate(
      CurvedAnimation(parent: _borderController, curve: Curves.easeInOut),
    );

    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final available = await _speech.initialize(
      onError: (error) {
        debugPrint('SpeechToText error: ${error.errorMsg}');
        if (mounted) {
          setState(() => _isListening = false);
          _borderController.stop();
          _borderController.reset();
        }
      },
      onStatus: (status) {
        debugPrint('SpeechToText status: $status');
        // 当识别自动停止时（如超时），更新状态
        if (status == 'done' || status == 'notListening') {
          if (mounted && _isListening) {
            setState(() => _isListening = false);
            _borderController.stop();
            _borderController.reset();
          }
        }
      },
    );
    if (mounted) {
      setState(() => _speechAvailable = available);
    }
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _borderController.dispose();
    if (_isListening) _speech.stop();
    super.dispose();
  }

  // ── 语音控制 ──

  Future<void> _startListening() async {
    if (!_speechAvailable || _isListening) return;

    HapticFeedback.mediumImpact();

    setState(() => _isListening = true);
    _borderController.repeat(reverse: true);

    final locale = Localizations.localeOf(context);
    final localeId = locale.languageCode == 'zh' ? 'zh_CN' : 'en_US';

    await _speech.listen(
      onResult: (result) {
        if (!mounted) return;
        widget.controller.text = result.recognizedWords;
        // 光标移到末尾
        widget.controller.selection = TextSelection.fromPosition(
          TextPosition(offset: widget.controller.text.length),
        );
      },
      localeId: localeId,
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        cancelOnError: true,
      ),
    );
  }

  Future<void> _stopListening() async {
    if (!_isListening) return;

    await _speech.stop();
    if (mounted) {
      setState(() => _isListening = false);
      _borderController.stop();
      _borderController.reset();
    }
  }

  // ── UI ──

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final safePadding = MediaQuery.of(context).padding.bottom;
    final bottomPad =
        (bottomInset > safePadding ? bottomInset : safePadding) + 8;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPad),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 图片按钮
          if (widget.onPickImage != null) ...[
            _buildImageButton(),
            const SizedBox(width: 8),
          ],
          // 输入框
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(MiaojiRadius.xl),
                border: Border.all(
                  color: _isListening
                      ? const Color(0xFFE85D4A).withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFFF5EFE0),
                  height: 1.4,
                ),
                cursorColor: const Color(0xFFD4A24C),
                decoration: InputDecoration(
                  hintText: _isListening
                      ? context.l10n.chatInputListeningHint
                      : context.l10n.chatInputPlaceholder,
                  hintStyle: TextStyle(
                    color: _isListening
                        ? const Color(0xFFE85D4A).withValues(alpha: 0.6)
                        : const Color(0xFFF5EFE0).withValues(alpha: 0.35),
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.fromLTRB(18, 12, 12, 12),
                  isDense: true,
                  filled: false,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // 发送 / 麦克风 按钮
          _hasText && !_isListening ? _buildSendButton() : _buildMicButton(),
        ],
      ),
    );
  }

  Widget _buildImageButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onPickImage?.call();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: Icon(
          Icons.image_outlined,
          color: const Color(0xFFF5EFE0).withValues(alpha: 0.5),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return GestureDetector(
      onTap: widget.onSend,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFD4A24C),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4A24C).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.send_rounded,
          color: Color(0xFF3D3124),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildMicButton() {
    return GestureDetector(
      onLongPressStart: (_) => _startListening(),
      onLongPressEnd: (_) => _stopListening(),
      // 单击也支持：点一下开始，再点一下停止
      onTap: () {
        if (_isListening) {
          _stopListening();
        } else {
          _startListening();
        }
      },
      child: AnimatedBuilder(
        animation: _borderAnim,
        builder: (context, child) {
          final borderWidth = _isListening ? _borderAnim.value : 1.0;
          final borderColor = _isListening
              ? Color.lerp(
                  const Color(0xFFE85D4A).withValues(alpha: 0.5),
                  const Color(0xFFE85D4A),
                  (_borderAnim.value - 1.5) / 2.0,
                )!
              : Colors.white.withValues(alpha: 0.08);

          return Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _isListening
                  ? const Color(0xFFE85D4A).withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: borderColor,
                width: borderWidth,
              ),
              boxShadow: _isListening
                  ? [
                      BoxShadow(
                        color:
                            const Color(0xFFE85D4A).withValues(alpha: 0.3),
                        blurRadius: 8 + (_borderAnim.value - 1.5) * 4,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
              color: _isListening
                  ? const Color(0xFFE85D4A)
                  : const Color(0xFFF5EFE0).withValues(alpha: 0.5),
              size: 20,
            ),
          );
        },
      ),
    );
  }
}
