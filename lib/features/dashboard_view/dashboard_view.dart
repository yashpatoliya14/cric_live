import 'package:cric_live/features/dashboard_view/dashboard_controller.dart';
import 'package:cric_live/utils/import_exports.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<DashboardController>(
      init: DashboardController(),
      builder:
          (controller) => Scaffold(
            appBar: AppBar(
              title: Text(
                "Home",
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
            ),
            body: IndexedStack(
              index: controller.currentIndex.value,
              children: controller.pages,
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: controller.currentIndex.value,
              onTap: (value) => controller.onIndexChanged(value),
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: "New Match",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.group),
                  label: "New Tournament",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: "History",
                ),
              ],
            ),
          ),
    );
  }
}
