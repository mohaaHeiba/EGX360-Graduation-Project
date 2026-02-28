import 'package:egx/features/profile/presentations/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

Widget buildImagePreview() {
  return GetBuilder<ProfileController>(
    builder: (logic) {
      if (logic.pickedImage == null) return const SizedBox.shrink();

      return Stack(
        children: [
          Container(
            constraints: const BoxConstraints(maxHeight: 350),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
              color: Colors.grey[50],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(logic.pickedImage!, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: () => logic.clearImage(),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      );
    },
  );
}
