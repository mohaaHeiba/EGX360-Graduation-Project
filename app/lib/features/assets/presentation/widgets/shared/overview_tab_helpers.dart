import 'package:egx/core/helper/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shared section title widget for overview tab
Widget buildOverviewSectionTitle(String title, BuildContext context) {
  return Text(
    title,
    style: context.textStyles.headlineMedium?.copyWith(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
    ),
  );
}

/// Shared stat card widget for overview tab
Widget buildOverviewStatCard(
  String label,
  String value,
  IconData icon,
  BuildContext context, {
  Color? valueColor,
  bool isDesktop = false,
}) {
  final isDarkMode = context.isDarkMode;
  final cardPadding = isDesktop ? 16.0 : 12.0;
  final iconSize = isDesktop ? 16.0 : 14.0;
  final fontSize = isDesktop ? 20.0 : 18.0;
  final iconPadding = isDesktop ? 8.0 : 6.0;

  return Container(
    padding: EdgeInsets.all(cardPadding),
    decoration: BoxDecoration(
      color: isDarkMode ? context.surface.withOpacity(0.5) : context.surface,
      borderRadius: BorderRadius.circular(isDesktop ? 12 : 10),
      border: Border.all(
        color: context.onSurface.withOpacity(isDesktop ? 0.08 : 0.1),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(iconPadding),
              decoration: BoxDecoration(
                color: (valueColor ?? context.primary).withOpacity(0.1),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(isDesktop ? 10 : 8),
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: valueColor ?? context.primary,
              ),
            ),
            SizedBox(width: isDesktop ? 10 : 8),
            Expanded(
              child: Text(
                label,
                style:
                    (isDesktop
                            ? context.textStyles.labelMedium
                            : context.textStyles.labelSmall)
                        ?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        Text(
          value,
          maxLines: 1,
          style: context.textStyles.headlineMedium?.copyWith(
            color: valueColor ?? context.onSurface,
            fontSize: fontSize,
            letterSpacing: -0.5,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

/// Shared detail row widget for overview tab
Widget buildOverviewDetailRow(
  String label,
  String value,
  IconData icon,
  BuildContext context, {
  bool isLink = false,
  bool isDesktop = false,
}) {
  final iconPadding = isDesktop ? 12.0 : 10.0;
  final iconSize = isDesktop ? 22.0 : 20.0;
  final spacing = isDesktop ? 18.0 : 16.0;
  final fontSize = isDesktop ? 16.0 : 15.0;
  final verticalSpacing = isDesktop ? 6.0 : 4.0;

  return Row(
    children: [
      Container(
        padding: EdgeInsets.all(iconPadding),
        decoration: BoxDecoration(
          color: context.onSurface.withOpacity(0.05),
          borderRadius: BorderRadius.circular(isDesktop ? 12 : 10),
        ),
        child: Icon(icon, color: context.primary, size: iconSize),
      ),
      SizedBox(width: spacing),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style:
                  (isDesktop
                          ? context.textStyles.labelMedium
                          : context.textStyles.labelSmall)
                      ?.copyWith(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: verticalSpacing),
            GestureDetector(
              onTap: isLink && value != "-"
                  ? () async {
                      final uri = Uri.parse(value);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    }
                  : null,
              child: Text(
                value,
                style: context.textStyles.bodyLarge?.copyWith(
                  color: isLink && value != "-"
                      ? context.primary
                      : context.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: fontSize,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
