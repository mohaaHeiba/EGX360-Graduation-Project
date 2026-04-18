import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/notifications/presentation/controller/notification_controller.dart';
import 'package:egx/features/notifications/presentation/widgets/notification_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationDropdown extends StatefulWidget {
  final Widget child;

  const NotificationDropdown({super.key, required this.child});

  @override
  State<NotificationDropdown> createState() => _NotificationDropdownState();
}

class _NotificationDropdownState extends State<NotificationDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isOpen = false;
    });
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Transparent barrier to close dropdown when clicking outside
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeDropdown,
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            width: 360,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(size.width - 360, size.height + 10),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surface,
                shadowColor: Colors.black.withOpacity(0.2),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 500),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.s.notifications_title,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            if (Get.isRegistered<NotificationController>())
                              Obx(() {
                                final controller =
                                    Get.find<NotificationController>();
                                if (controller.unreadCount == 0)
                                  return const SizedBox.shrink();
                                return TextButton(
                                  onPressed: () {
                                    controller.markAllAsRead();
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(context.s.mark_all_read_btn),
                                );
                              }),
                          ],
                        ),
                      ),
                      const Divider(height: 1),

                      // List
                      Flexible(
                        child: GetBuilder<NotificationController>(
                          init:
                              Get.find<
                                NotificationController
                              >(), // Ensure initialization if needed
                          builder: (controller) {
                            return Obx(() {
                              if (controller.isLoading.value &&
                                  controller.notifications.isEmpty) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              if (controller.notifications.isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Text(context.s.no_notifications_msg),
                                  ),
                                );
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount:
                                    controller.notifications.length +
                                    (controller.hasMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index ==
                                      controller.notifications.length) {
                                    // Trigger loading more
                                    if (!controller.isLoading.value) {
                                      controller.fetchNotifications();
                                    }
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(12),
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  final notification =
                                      controller.notifications[index];
                                  return NotificationItem(
                                    notification: notification,
                                    onTap: () {
                                      _closeDropdown();
                                      controller.onItemClick(notification);
                                    },
                                  );
                                },
                              );
                            });
                          },
                        ),
                      ),

                      // Footer
                      const Divider(height: 1),
                      InkWell(
                        onTap: () {
                          _closeDropdown();
                          Get.toNamed(
                            '/notifications',
                          ); // Or whatever the route is
                        },
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(12),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          child: Text(
                            context.s.view_all_notifications_btn,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(onTap: _toggleDropdown, child: widget.child),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }
}
