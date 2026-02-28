import 'package:flutter/material.dart';

Widget buildTextField(
  BuildContext context,
  ThemeData theme,
  ColorScheme colorScheme, {
  required TextEditingController controller,
  required String hintText,
  int? minLines,
  int? maxLines,
  bool autofocus = false,
  bool isTitle = false,
}) {
  // Define borders based on your reference code to keep it DRY
  final BorderRadius borderRadius = BorderRadius.circular(12);

  final OutlineInputBorder enabledBorder = OutlineInputBorder(
    borderRadius: borderRadius,
    borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
  );

  final OutlineInputBorder focusedBorder = OutlineInputBorder(
    borderRadius: borderRadius,
    borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
  );

  final OutlineInputBorder errorBorder = OutlineInputBorder(
    borderRadius: borderRadius,
    borderSide: BorderSide(color: colorScheme.error),
  );

  return TextField(
    controller: controller,
    maxLines: maxLines,
    minLines: minLines,
    autofocus: autofocus,
    textCapitalization: TextCapitalization.sentences,
    cursorColor: colorScheme.primary,
    cursorWidth: 2.5,
    cursorRadius: const Radius.circular(2),

    style: theme.textTheme.bodyMedium?.copyWith(
      fontSize: isTitle ? 20 : 16,
      fontWeight: isTitle ? FontWeight.w700 : FontWeight.w400,
      color: colorScheme.onSurface,
      height: 1.5,
    ),

    decoration: InputDecoration(
      hintText: hintText,
      hintStyle: theme.textTheme.bodyMedium?.copyWith(
        fontSize: isTitle ? 20 : 16,
        fontWeight: isTitle ? FontWeight.w700 : FontWeight.w400,
        color: colorScheme.onSurface.withOpacity(0.5), // Opacity from reference
      ),

      // --- Reference Style Applied Here ---
      filled: true,
      fillColor: theme.cardColor, // Or colorScheme.surface
      contentPadding: const EdgeInsets.all(16), // Padding inside the box

      border: enabledBorder,
      enabledBorder: enabledBorder,
      focusedBorder: focusedBorder,
      errorBorder: errorBorder,
    ),
  );
}
