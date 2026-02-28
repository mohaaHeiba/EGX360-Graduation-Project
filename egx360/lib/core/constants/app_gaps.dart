import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppGaps {
  // Screen Dimensions using ScreenUtil
  static double get screenWidth => ScreenUtil().screenWidth;
  static double get screenHeight => ScreenUtil().screenHeight;

  // Heights - scaled using .h
  static final h4 = SizedBox(height: 4.h);
  static final h8 = SizedBox(height: 8.h);
  static final h12 = SizedBox(height: 12.h);
  static final h16 = SizedBox(height: 16.h);
  static final h18 = SizedBox(height: 18.h);
  static final h20 = SizedBox(height: 20.h);
  static final h24 = SizedBox(height: 24.h);
  static final h32 = SizedBox(height: 32.h);
  static final h40 = SizedBox(height: 40.h);

  // Widths - scaled using .w
  static final w4 = SizedBox(width: 4.w);
  static final w8 = SizedBox(width: 8.w);
  static final w12 = SizedBox(width: 12.w);
  static final w14 = SizedBox(width: 14.w);
  static final w16 = SizedBox(width: 16.w);
  static final w20 = SizedBox(width: 20.w);
  static final w24 = SizedBox(width: 24.w);
  static final w32 = SizedBox(width: 32.w);
  static final w40 = SizedBox(width: 40.w);
}
