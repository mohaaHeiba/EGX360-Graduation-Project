import 'package:egx/core/Layout/layout_controller.dart';
import 'package:get/get.dart';

class LayoutBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(LayoutController(), permanent: true);
    // Get.put(CommunityController());
  }
}
