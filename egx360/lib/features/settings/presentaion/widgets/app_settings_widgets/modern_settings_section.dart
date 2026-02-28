import 'package:egx/core/constants/app_gaps.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ModernSettingsSection extends StatelessWidget {
  final String title;
  final List<SettingItem> items;

  const ModernSettingsSection({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8.w, bottom: 12.h),
          child: Text(
            title,
            style: theme.textStyles.labelSmall?.copyWith(
              color: theme.onBackground.withValues(alpha: 0.6),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: [
              BoxShadow(
                color: theme.surface.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: Offset(0, 8.h),
              ),
            ],
          ),

          child: Column(
            children: items.asMap().entries.map((entry) {
              final isLast = entry.key == items.length - 1;
              return _buildSettingTile(context, entry.value, isLast);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    SettingItem item,
    bool isLast,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: item.onTap ?? () {},
      borderRadius: isLast
          ? BorderRadius.vertical(bottom: Radius.circular(10.r))
          : BorderRadius.zero,
      child: Container(
        decoration: BoxDecoration(
          gradient: item.gradient,
          border: !isLast
              ? Border(
                  bottom: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
                )
              : null,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            if (item.icon != null)
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: (item.iconColor ?? colorScheme.primary).withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item.icon,
                  color: item.iconColor ?? colorScheme.primary,
                  size: 20.sp.clamp(12, 18),
                ),
              ),
            AppGaps.w14,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: textTheme.titleMedium?.copyWith(
                      color: item.titleColor ?? colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp.clamp(12, 18),
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    SizedBox(height: 3.h),
                    Text(
                      item.subtitle!,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 12.sp.clamp(10, 14),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            item.trailing ??
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  size: 16.sp.clamp(12, 18),
                ),
          ],
        ),
      ),
    );
  }
}

class SettingItem {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? titleColor;
  final Color? iconColor;
  final Gradient? gradient;
  final VoidCallback? onTap;

  SettingItem({
    this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.titleColor,
    this.iconColor,
    this.gradient,
    this.onTap,
  });
}
