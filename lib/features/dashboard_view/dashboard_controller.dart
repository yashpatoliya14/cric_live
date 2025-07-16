import 'package:cric_live/utils/import_exports.dart';

class DashboardController extends GetxController {
  RxInt currentIndex = 0.obs;
  List<Widget> pages = [
    CreateTeamView(),
    Text("create a tournament"),
    Text("history"),
  ];
  onIndexChanged(value) {
    if (value != null) {
      currentIndex.value = value;
    }
  }
}
