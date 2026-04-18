import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/auth/domain/entity/auth_entity.dart';
import 'package:egx/features/profile/presentations/controller/profile_controller.dart';
import 'package:egx/features/profile/presentations/widgets/create_post_widgets/build_bottom_toolbar.dart';
import 'package:egx/features/profile/presentations/widgets/create_post_widgets/build_image_preview.dart';
import 'package:egx/features/profile/presentations/widgets/create_post_widgets/build_text_field.dart'; // Import the new widget above
import 'package:egx/features/profile/presentations/widgets/create_post_widgets/build_user_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreatePostPage extends GetView<ProfileController> {
  const CreatePostPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Obx(() {
      final AuthEntity? user =
          (Get.arguments as AuthEntity?) ?? controller.userProfile.value;

      if (user == null) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        resizeToAvoidBottomInset: true,
        appBar: _buildAppBar(context),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. User Info
                        buildUserInfo(context, user, controller),
                        const SizedBox(height: 20),

                        // 2. Selected Stock Chips
                        if (controller.selectedStocks.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: controller.selectedStocks.map<Widget>((
                                stock,
                              ) {
                                return _buildStockChip(
                                  context,
                                  stock,
                                  controller,
                                );
                              }).toList(),
                            ),
                          ),

                        // 3. Headline Field (Distinct Box)
                        buildTextField(
                          context,
                          theme,
                          colorScheme,
                          controller: controller.headlineTextController,
                          hintText: context.s.profile_headline_hint,
                          isTitle: true, // Uses Bold Style
                          maxLines: 2,
                          minLines: 1,
                          autofocus: true,
                        ),

                        const SizedBox(height: 16), // Space between boxes
                        // 4. Body Field (Distinct Box)
                        buildTextField(
                          context,
                          theme,
                          colorScheme,
                          controller: controller.postTextController,
                          hintText: context.s.profile_post_hint,
                          isTitle: false, // Normal Style
                          minLines: 8, // Taller box
                          autofocus: false,
                        ),

                        const SizedBox(height: 24),

                        // 5. Image Preview
                        buildImagePreview(),

                        const SizedBox(height: 100), // Space for bottom toolbar
                      ],
                    ),
                  ),
                ),
                buildBottomToolbar(context, colorScheme, controller),
              ],
            ),

            // Autocomplete Overlay
            _buildAutocompleteOverlay(context, controller, theme, colorScheme),
          ],
        ),
      );
    });
  }

  // --- Sub-Widgets ---

  Widget _buildStockChip(
    BuildContext context,
    dynamic stock,
    ProfileController controller,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
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
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => controller.removeStock(stock),
            child: Icon(
              Icons.close_rounded,
              size: 16,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutocompleteOverlay(
    BuildContext context,
    ProfileController controller,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Obx(() {
      if (!controller.showAutocomplete.value) {
        return const SizedBox.shrink();
      }
      return Positioned(
        left: 20,
        right: 20,
        bottom: 80,
        child: Material(
          elevation: 10,
          shadowColor: Colors.black26,
          borderRadius: BorderRadius.circular(16),
          color: theme.cardColor,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 250),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    child: Text(
                      context.s.profile_suggested_stocks,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurfaceVariant,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Flexible(
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
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
                            radius: 14,
                            backgroundColor:
                                colorScheme.surfaceContainerHighest,
                            child: stock.logoUrl != null
                                ? CachedNetworkImage(imageUrl: stock.logoUrl!)
                                : Text(
                                    stock.symbol[0],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                          title: Text(
                            stock.symbol,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            stock.companyNameEn,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Icon(
                            Icons.add,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 80,
      backgroundColor: context.background,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leadingWidth: 80,
      leading: Center(
        child: Container(
          margin: const EdgeInsets.only(left: 0.0),
          decoration: BoxDecoration(
            color: context.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: context.primary.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
            onPressed: Get.back,
          ),
        ),
      ),
      title: Text(
        context.s.profile_create_post,
        style: TextStyle(
          color: context.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Obx(() {
            final isValid = controller.isPostValid.value;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 36,
              child: ElevatedButton(
                onPressed: isValid
                    ? () {
                        controller.createPost();
                        // Get.back();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primary,
                  disabledBackgroundColor: context.primary.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  elevation: isValid ? 4 : 0,
                  shadowColor: context.primary.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
                child: Text(
                  context.s.profile_post_button,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
