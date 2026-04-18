// removed unused import

import 'package:egx/core/constants/app_images.dart';
import 'package:egx/core/custom/custom_appbar.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/chatbot/presentation/controllers/chatbot_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';

class ChatbotPage extends StatelessWidget {
  final bool isDesktop;
  const ChatbotPage({super.key, this.isDesktop = false});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(ChatbotController(), permanent: true);

    // Force LTR so chat bubbles, row alignment, and markdown
    // all render correctly even when the app locale is RTL.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: context.background,
        resizeToAvoidBottomInset: true,
        appBar: isDesktop ? null : customAppbar(
          Get.back,
          'EGX AI',
          withIcon: true,
          iconData: Icons.smart_toy_rounded,
          customActions: [
            TextButton.icon(
              onPressed: ctrl.clearChat,
              icon: const Icon(Icons.add_comment_rounded, size: 16),
              label: const Text('New Chat', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                foregroundColor: context.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              if (isDesktop)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'EGX AI',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: context.onSurface,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: ctrl.clearChat,
                        icon: const Icon(Icons.add_comment_rounded, size: 18),
                        label: const Text('New Chat'),
                        style: TextButton.styleFrom(
                          foregroundColor: context.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Obx(
                  () => ctrl.isEmpty
                      ? _buildEmptyState(context, ctrl)
                      : _buildMessages(context, ctrl),
                ),
              ),
              Obx(
                () => ctrl.isEmpty
                    ? _buildSuggestions(context, ctrl)
                    : const SizedBox(),
              ),
              _buildInput(context, ctrl),
            ],
          ),
        ),
      ),
    );
  }

  // ── Empty State ──────────────────────────────────────────────────

  Widget _buildEmptyState(BuildContext context, ChatbotController ctrl) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(AppImages.logo, width: 100, height: 100),
            const SizedBox(height: 18),
            Text(
              'Ask me about your portfolio, market news, AI predictions, and community sentiment',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.65,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // ── Messages ─────────────────────────────────────────────────────

  Widget _buildMessages(BuildContext context, ChatbotController ctrl) {
    return Obx(
      () => ListView.builder(
        controller: ctrl.scrollController,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
        itemCount: ctrl.messages.length + (ctrl.isTyping.value ? 1 : 0),
        itemBuilder: (ctx, i) {
          if (ctrl.isTyping.value && i == ctrl.messages.length) {
            return _TypingBubble(context: context);
          }
          final msg = ctrl.messages[i];
          // Date separator between days
          return _buildBubble(context, msg);
        },
      ),
    );
  }

  Widget _buildBubble(BuildContext context, ChatMessage msg) {
    final isUser = msg.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        // LTR: bot = left (start), user = right (end)
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Bot avatar on the left
          if (!isUser)
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8, bottom: 2),
              decoration: BoxDecoration(
                color: context.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.smart_toy_rounded,
                size: 17,
                color: context.primary,
              ),
            ),

          // Bubble
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: isUser
                    ? context.primary
                    : context.surface.withOpacity(0.5),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  // tail: bot bottom-left, user bottom-right
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: isUser
                    ? null
                    : Border.all(
                        color: context.colors.outline.withOpacity(0.08),
                      ),
              ),
              child: isUser
                  ? Text(
                      msg.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        height: 1.55,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : MarkdownBody(
                      data: msg.text,
                      shrinkWrap: true,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          color: context.onSurface.withOpacity(0.85),
                          fontSize: 14.5,
                          height: 1.6,
                        ),
                        strong: TextStyle(
                          color: context.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                        ),
                        em: TextStyle(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                        listBullet: TextStyle(
                          color: context.primary,
                          fontSize: 14,
                        ),
                        h2: TextStyle(
                          color: context.onSurface,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          letterSpacing: -0.2,
                        ),
                        h3: TextStyle(
                          color: context.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                        ),
                        code: TextStyle(
                          color: context.primary,
                          backgroundColor: context.primary.withOpacity(0.08),
                          fontSize: 13,
                        ),
                      ),
                    ),
            ),
          ),

          // User avatar on the right
          if (isUser)
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(left: 8, bottom: 2),
              decoration: BoxDecoration(
                color: context.onSurface.withOpacity(0.07),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.person_rounded,
                size: 17,
                color: context.onSurface.withOpacity(0.45),
              ),
            ),
        ],
      ),
    );
  }

  // ── Suggestions ───────────────────────────────────────────────────

  Widget _buildSuggestions(BuildContext context, ChatbotController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: Colors.grey.withOpacity(0.1), thickness: 1, height: 1),
        const SizedBox(height: 10),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: ctrl.suggestions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => i == 0
                  ? ctrl.sendDailySummary()
                  : ctrl.sendMessage(ctrl.suggestions[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: context.surface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: context.colors.outline.withOpacity(0.1),
                  ),
                ),
                child: Text(
                  ctrl.suggestions[i],
                  style: TextStyle(
                    color: context.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Input Bar ─────────────────────────────────────────────────────

  Widget _buildInput(BuildContext context, ChatbotController ctrl) {
    return Column(
      children: [
        Divider(color: Colors.grey.withOpacity(0.12), thickness: 1, height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Obx(
            () => Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: ctrl.inputController,
                    focusNode: ctrl.focusNode,
                    enabled: !ctrl.isTyping.value,
                    maxLines: 5,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    onSubmitted: ctrl.sendMessage,
                    style: TextStyle(color: context.onSurface, fontSize: 14.5),
                    decoration: InputDecoration(
                      hintText: ctrl.isTyping.value
                          ? 'Analyzing... please wait'
                          : 'Ask anything...',
                      hintStyle: TextStyle(
                        color: context.onSurface.withOpacity(0.3),
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: context.surface.withOpacity(0.4),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: context.colors.outline.withOpacity(0.1),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: context.colors.outline.withOpacity(0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: context.primary.withOpacity(0.4),
                        ),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: context.colors.outline.withOpacity(0.06),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Send button (RTL: leading = right side)
                GestureDetector(
                  onTap: ctrl.isTyping.value
                      ? null
                      : () => ctrl.sendMessage(ctrl.inputController.text),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: ctrl.isTyping.value
                          ? context.primary.withOpacity(0.3)
                          : context.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: ctrl.isTyping.value
                          ? []
                          : [
                              BoxShadow(
                                color: context.primary.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                    ),
                    child: Icon(
                      ctrl.isTyping.value
                          ? Icons.hourglass_top_rounded
                          : Icons.send_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                ),
                // Text field
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Typing Indicator ──────────────────────────────────────────────

class _TypingBubble extends StatefulWidget {
  const _TypingBubble({required this.context});
  final BuildContext context;

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.25,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ac, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext _) {
    final context = widget.context;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 10, bottom: 2),
            decoration: BoxDecoration(
              color: context.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.smart_toy_rounded,
              size: 17,
              color: context.primary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: context.surface.withOpacity(0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(
                color: context.colors.outline.withOpacity(0.08),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Analyzing your data',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedBuilder(
                  animation: _anim,
                  builder: (_, __) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      3,
                      (i) => Container(
                        margin: EdgeInsets.only(right: i < 2 ? 4.0 : 0),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: context.primary.withOpacity(
                            (_anim.value - i * 0.22).clamp(0.15, 1.0),
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
