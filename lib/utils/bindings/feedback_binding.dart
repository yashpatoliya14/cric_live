import 'package:cric_live/features/feedback_view/feedback_controller.dart';
import 'package:cric_live/features/feedback_view/feedback_repo.dart';
import 'package:get/get.dart';

class FeedbackBinding extends Bindings {
  @override
  void dependencies() {
    // Lazily inject the repository and controller.
    // They will be created only when they are first needed.
    Get.lazyPut<FeedbackRepository>(() => FeedbackRepository());
    Get.lazyPut<FeedbackController>(
      () => FeedbackController(repository: Get.find<FeedbackRepository>()),
    );
  }
}
