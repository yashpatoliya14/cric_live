import 'package:cric_live/features/search_view/search_screen_controller.dart';
import 'package:cric_live/utils/import_exports.dart';

class SearchScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SearchScreenController());
  }
}
