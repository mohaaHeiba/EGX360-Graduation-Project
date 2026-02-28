import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 🔹 Generic Text Field Widget with Premium Styling
Widget textFieldWidget({
  required TextEditingController controller,
  required String hint,
  required IconData icon,
  String? Function(String?)? validator,
  TextInputType inputType = TextInputType.text,
}) {
  return Builder(
    builder: (context) {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;

      return TextFormField(
        controller: controller,
        keyboardType: inputType,
        validator: validator,
        style: theme.textTheme.bodyMedium?.copyWith(letterSpacing: 0.2),
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: colorScheme.onSurface.withOpacity(0.6),
            size: 20,
          ),
          hintText: hint,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.4),
            letterSpacing: 0.2,
          ),
          filled: true,
          fillColor: colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          // Very thin borders for premium look
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: colorScheme.outline.withOpacity(0.15),
              width: 0.8,
            ),
          ),
          // Mint Green focus border
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: colorScheme.error.withOpacity(0.8),
              width: 0.8,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: colorScheme.error, width: 1.2),
          ),
        ),
      );
    },
  );
}

/// 🔹 Password Text Field Widget with Premium Styling
Widget textFieldPasswordWidget({
  required TextEditingController controller,
  required String hint,
  required IconData icon,
  required RxBool isObsure,
  String? Function(String?)? validator,
  TextInputType inputType = TextInputType.visiblePassword,
}) {
  return Builder(
    builder: (context) {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;

      return Obx(
        () => TextFormField(
          controller: controller,
          keyboardType: inputType,
          obscureText: isObsure.value,
          validator: validator,
          style: theme.textTheme.bodyMedium?.copyWith(letterSpacing: 0.2),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: colorScheme.onSurface.withOpacity(0.6),
              size: 20,
            ),
            hintText: hint,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.4),
              letterSpacing: 0.2,
            ),
            filled: true,
            fillColor: colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            // Very thin borders for premium look
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: colorScheme.outline.withOpacity(0.15),
                width: 0.8,
              ),
            ),
            // Mint Green focus border
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: colorScheme.error.withOpacity(0.8),
                width: 0.8,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colorScheme.error, width: 1.2),
            ),
            // Show/Hide password button
            suffixIcon: IconButton(
              icon: Icon(
                isObsure.value ? Icons.visibility_off : Icons.visibility,
                color: colorScheme.onSurface.withOpacity(0.5),
                size: 20,
              ),
              onPressed: () => isObsure.value = !isObsure.value,
            ),
          ),
        ),
      );
    },
  );
}
