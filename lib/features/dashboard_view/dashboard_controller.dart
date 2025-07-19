import 'package:cric_live/utils/import_exports.dart';

class DashboardController extends GetxController {
  RxInt currentIndex = 0.obs;
  List<Widget> pages = [CreateMatchView(), TournamentView(), HistoryView()];
  onIndexChanged(value) {
    if (value != null) {
      currentIndex.value = value;
    }
  }
}
