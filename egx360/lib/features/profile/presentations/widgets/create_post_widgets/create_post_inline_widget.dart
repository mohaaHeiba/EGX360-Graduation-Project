import 'package:cached_network_image/cached_network_image.dart';
import 'package:egx/core/constants/app_gaps.dart';
import 'package:egx/features/auth/domain/entity/auth_entity.dart';
import 'package:egx/features/profile/presentations/controller/profile_controller.dart';
import 'package:egx/features/profile/presentations/widgets/create_post_widgets/build_image_preview.dart';
import 'package:egx/features/profile/presentations/widgets/create_post_widgets/build_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreatePostInlineWidget extends GetView<ProfileController> {
  final AuthEntity user;

  const CreatePostInlineWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Obx(() {
      final isExpanded = controller.isCreatePostExpanded.value;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isExpanded
                ? colorScheme.primary.withOpacity(0.5)
                : colorScheme.outline.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Collapsed State: "What's on your mind?"
            if (!isExpanded)
              InkWell(
                onTap: () {
                  controller.isCreatePostExpanded.value = true;
                  // Focus on body field when expanded
                  // Future.delayed might be needed if focus node logic is added
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _buildAvatar(context, user),
                      AppGaps.w16,
                      Text(
                        "What's on your mind?",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.textTheme.bodyLarge?.color?.withOpacity(
                            0.5,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.image_outlined,
                        color: colorScheme.primary.withOpacity(0.7),
                      ),
                      AppGaps.w16,
                      Icon(
                        Icons.send_rounded,
                        color: colorScheme.primary.withOpacity(0.7),
                      ),
                    ],
                  ),
                ),
              )
            // 2. Expanded State: Full Form
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header (Avatar + Input Area)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAvatar(context, user),
                        AppGaps.w12,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Headline Field (Toggled)
                              Obx(() {
                                if (!controller.showHeadlineField.value) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: buildTextField(
                                    context,
                                    theme,
                                    colorScheme,
                                    controller:
                                        controller.headlineTextController,
                                    hintText: "Headline (Optional)",
                                    isTitle: true,
                                    maxLines: 1,
                                    minLines: 1,
                                    autofocus: true,
                                  ),
                                );
                              }),

                              // Body Field
                              buildTextField(
                                context,
                                theme,
                                colorScheme,
                                controller: controller.postTextController,
                                hintText:
                                    "Share your market analysis...\nUse \$ for symbols like \$EGX30",
                                isTitle: false,
                                minLines: 3,
                                maxLines: 10,
                                autofocus: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Selected Stocks Chips
                  Obx(() {
                    if (controller.selectedStocks.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.selectedStocks.map<Widget>((
                          stock,
                        ) {
                          return _buildStockChip(context, stock, controller);
                        }).toList(),
                      ),
                    );
                  }),

                  // Image Preview
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: buildImagePreview(),
                  ),

                  Divider(
                    height: 1,
                    color: colorScheme.outline.withOpacity(0.1),
                  ),

                  // Start of Toolbar Area
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left Actions Toolbar
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                // Photo Button
                                IconButton(
                                  onPressed: () => controller.pickImage(),
                                  icon: const Icon(Icons.image_outlined),
                                  color: colorScheme.primary,
                                  tooltip: "Add Photo",
                                ),

                                // Headline Toggle Button
                                IconButton(
                                  onPressed: () {
                                    controller.showHeadlineField.value =
                                        !controller.showHeadlineField.value;
                                  },
                                  icon: Obx(
                                    () => Icon(
                                      controller.showHeadlineField.value
                                          ? Icons.title_rounded
                                          : Icons.text_fields_rounded,
                                    ),
                                  ),
                                  color: colorScheme.primary,
                                  tooltip: controller.showHeadlineField.value
                                      ? "Remove Headline"
                                      : "Add Headline",
                                ),

                                // Stock Button
                                IconButton(
                                  onPressed: () => controller.addStockSymbol(),
                                  icon: const Icon(Icons.attach_money_rounded),
                                  color: Colors.green,
                                  tooltip: "Tag Stock",
                                ),

                                Container(
                                  height: 20,
                                  width: 1,
                                  color: colorScheme.outline.withOpacity(0.2),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),

                                // Sentiment Toggles
                                _buildSentimentButton(
                                  context,
                                  "bullish",
                                  Icons.trending_up_rounded,
                                  Colors.green,
                                ),
                                _buildSentimentButton(
                                  context,
                                  "bearish",
                                  Icons.trending_down_rounded,
                                  Colors.red,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Right Actions: Cancel & Post
                        Row(
                          children: [
                            // Cancel Button (Collapse)
                            TextButton(
                              onPressed: () {
                                controller.isCreatePostExpanded.value = false;
                                controller.showHeadlineField.value = false;
                                // Ideally clear text too? Maybe keep draft.
                              },
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ),
                            AppGaps.w8,

                            // Post Button
                            Obx(() {
                              final isValid = controller.isPostValid.value;
                              return ElevatedButton(
                                onPressed: isValid
                                    ? () {
                                        controller.createPost(goBack: false);
                                        // After post success, collapse widget
                                        controller.isCreatePostExpanded.value =
                                            false;
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: colorScheme.primary
                                      .withOpacity(0.2),
                                  elevation: isValid ? 2 : 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                ),
                                child: const Text(
                                  "Post",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Autocomplete List (Appends below when active)
                  Obx(() {
                    if (!controller.showAutocomplete.value ||
                        controller.filteredStocks.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        border: Border(
                          top: BorderSide(
                            color: colorScheme.outline.withOpacity(0.1),
                          ),
                        ),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: controller.filteredStocks.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: colorScheme.outline.withOpacity(0.1),
                        ),
                        itemBuilder: (context, index) {
                          final stock = controller.filteredStocks[index];
                          return ListTile(
                            onTap: () => controller.selectStock(stock),
                            dense: true,
                            leading: CircleAvatar(
                              radius: 12,
                              backgroundColor:
                                  colorScheme.surfaceContainerHighest,
                              child: stock.logoUrl != null
                                  ? CachedNetworkImage(imageUrl: stock.logoUrl!)
                                  : Text(
                                      stock.symbol[0],
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                            ),
                            title: Text(
                              stock.symbol,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              stock.companyNameEn,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
          ],
        ),
      );
    });
  }

  Widget _buildAvatar(BuildContext context, AuthEntity user) {
    final colorScheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: 20,
      backgroundColor: colorScheme.primary.withOpacity(0.1),
      backgroundImage: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
          ? CachedNetworkImageProvider(user.avatarUrl!)
          : null,
      child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
          ? Icon(Icons.person, color: colorScheme.primary)
          : null,
    );
  }

  Widget _buildSentimentButton(
    BuildContext context,
    String value,
    IconData icon,
    Color color,
  ) {
    return Obx(() {
      final isSelected = controller.selectedSentiment.value == value;
      return IconButton(
        onPressed: () => controller.setSentiment(value),
        icon: Icon(icon),
        color: isSelected ? color : color.withOpacity(0.3),
        tooltip: value.capitalizeFirst,
        style: IconButton.styleFrom(
          backgroundColor: isSelected ? color.withOpacity(0.1) : null,
        ),
      );
    });
  }

  Widget _buildStockChip(
    BuildContext context,
    dynamic stock,
    ProfileController controller,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "\$${stock.symbol}",
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: () => controller.removeStock(stock),
            child: Icon(
              Icons.close_rounded,
              size: 14,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
