// lib/features/stock_chat/presentation/pages/stock_chat_page.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:egx/core/data/init_local_data.dart';
import 'package:egx/core/routes/app_pages.dart';
import 'package:egx/features/auth/domain/entity/auth_entity.dart';
import 'package:egx/features/stock_chat/presentation/widgets/chat_input_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../controllers/stock_chat_controller.dart';

class StockChatPage extends StatelessWidget {
  final String stockId;
  final String symbol;

  const StockChatPage({super.key, required this.stockId, required this.symbol});

  @override
  Widget build(BuildContext context) {
    // Initialize controller with a unique tag for this stock
    final controller = Get.put(
      StockChatController(
        getChatStreamUseCase: Get.find(),
        sendMessageUseCase: Get.find(),
        getUserProfileUseCase: Get.find(),
        stockId: stockId,
      ),
      tag: 'chat_$stockId',
    );

    return Column(
      children: [
        // منطقة الرسائل
        Expanded(
          child: Obx(() {
            if (controller.messages.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 48,
                      color: Colors.grey[700],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Start the discussion for $symbol!",
                      style: TextStyle(color: Colors.grey[500], fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              reverse: true, // Show newest messages at the bottom
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: controller.messages.length,
              itemBuilder: (context, index) {
                final msg = controller.messages[index];
                final isMe = msg.userId == controller.currentUserId;

                // Use InitLocalData for current user to ensure instant display
                final currentUser = Get.find<InitLocalData>().currentUser.value;
                final userProfile = isMe
                    ? currentUser
                    : controller.userProfiles[msg.userId];

                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.85,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: isMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        if (!isMe) ...[
                          // Avatar for other users (Left)
                          InkWell(
                            onTap: () {
                              if (userProfile != null) {
                                _navigateToUserProfile(userProfile);
                              }
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[800],
                                image: (userProfile?.avatarUrl != null)
                                    ? DecorationImage(
                                        image: CachedNetworkImageProvider(
                                          userProfile!.avatarUrl!,
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: (userProfile?.avatarUrl == null)
                                  ? Center(
                                      child: Text(
                                        (userProfile?.name ?? "U")
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ],
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? Colors.blueAccent
                                  : const Color(0xFF2A2A35),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: isMe
                                    ? const Radius.circular(16)
                                    : const Radius.circular(4),
                                bottomRight: isMe
                                    ? const Radius.circular(4)
                                    : const Radius.circular(16),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Name for everyone
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: InkWell(
                                    onTap: () {
                                      if (userProfile != null) {
                                        _navigateToUserProfile(userProfile);
                                      }
                                    },
                                    child: Text(
                                      isMe
                                          ? "You"
                                          : (userProfile?.name ??
                                                "User ${msg.userId.substring(0, 5)}"),
                                      style: TextStyle(
                                        color: isMe
                                            ? Colors.white.withOpacity(0.9)
                                            : Colors.orangeAccent,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  msg.message,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    timeago.format(
                                      msg.createdAt,
                                    ), // Using timeago for timestamps
                                    style: TextStyle(
                                      color: isMe
                                          ? Colors.white70
                                          : Colors.grey[500],
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isMe) ...[
                          // Avatar for current user (Right)
                          InkWell(
                            onTap: () {
                              if (userProfile != null) {
                                _navigateToUserProfile(userProfile);
                              }
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              margin: const EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blueAccent.withOpacity(0.5),
                                image: (userProfile?.avatarUrl != null)
                                    ? DecorationImage(
                                        image: CachedNetworkImageProvider(
                                          userProfile!.avatarUrl!,
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: (userProfile?.avatarUrl == null)
                                  ? Center(
                                      child: Text(
                                        (userProfile?.name ?? "U")
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),

        // منطقة الكتابة الجديدة
        ChatInputSection(controller: controller),
      ],
    );
  }

  void _navigateToUserProfile(AuthEntity user) {
    Get.toNamed(AppPages.userProfilePage, arguments: user);
  }
}
