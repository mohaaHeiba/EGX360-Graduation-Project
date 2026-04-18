import 'package:egx/features/search/presentation/controllers/search_stocks_controller.dart';
import 'package:get/get.dart';

class SearchBindings extends Bindings {
  @override
  void dependencies() {
    Get.put((SearchStocksController()));
    // Get.put(CommunityController());
  }
}
