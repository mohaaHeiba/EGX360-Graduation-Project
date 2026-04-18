import 'package:egx/core/services/permission_service.dart';
import 'package:egx/features/welcome/presentaion/controller/welcome_controller.dart';
import 'package:get/get.dart';

class WelcomeBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PermissionService(), fenix: true);
    Get.put<WelcomeController>(WelcomeController());
  }
}
