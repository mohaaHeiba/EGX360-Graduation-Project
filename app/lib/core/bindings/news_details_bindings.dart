import 'package:egx/features/search/presentation/controllers/news_tts_controller.dart';
import 'package:get/get.dart';

class NewsDetailsBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(NewsTtsController());
  }
}
