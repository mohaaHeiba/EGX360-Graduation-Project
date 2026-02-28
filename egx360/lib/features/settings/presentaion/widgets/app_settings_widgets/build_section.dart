import 'package:egx/core/constants/app_gaps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget buildSection(String title, String content, {required ThemeData theme}) {
  final titleColor = theme.textTheme.titleMedium!.color;
  final contentColor = theme.textTheme.bodyMedium!.color;

  return Padding(
    padding: EdgeInsets.only(bottom: 20.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: titleColor,
            fontSize: 18.sp.clamp(16, 20),
            fontWeight: FontWeight.w600,
          ),
        ),
        AppGaps.h8,
        Text(
          content,
          style: TextStyle(
            color: contentColor,
            height: 1.5,
            fontSize: 14.sp.clamp(12, 16),
          ),
        ),
      ],
    ),
  );
}
