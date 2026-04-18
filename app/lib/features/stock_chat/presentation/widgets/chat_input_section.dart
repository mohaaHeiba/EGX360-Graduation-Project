import 'package:cached_network_image/cached_network_image.dart';
import 'package:egx/core/data/init_local_data.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/stock_chat/presentation/controllers/stock_chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatInputSection extends StatelessWidget {
  final StockChatController controller;

  const ChatInputSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = Get.find<InitLocalData>().currentUser.value;
    final isDark = theme.brightness == Brightness.dark;

    // Local observable for text content to avoid rebuilding everything
    final hasText = (controller.messageController.text.trim().isNotEmpty).obs;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // --- Avatar ---
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: (currentUser?.avatarUrl == null)
                  ? context.primary.withOpacity(0.15)
                  : Colors.transparent,
              image: (currentUser?.avatarUrl != null)
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(
                        currentUser!.avatarUrl!,
                      ),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: (currentUser?.avatarUrl == null)
                ? Center(
                    child: Text(
                      (currentUser?.name ?? "U").substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: context.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
          ),

          const SizedBox(width: 12),

          // --- TextField ---
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: controller.messageController,
                onChanged: (value) {
                  hasText.value = value.trim().isNotEmpty;
                },
                decoration: InputDecoration(
                  hintText: "Join the discussion...",
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  isDense: true,
                ),
                minLines: 1,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),

          // --- Send Button ---
          Obx(() {
            final showButton = hasText.value;
            final isSending = controller.isLoading.value;

            return AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: SizedBox(
                width: showButton || isSending ? null : 0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: context.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: isSending
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () {
                              controller.sendMessage();
                              hasText.value = false; // Reset local state
                            },
                          ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
