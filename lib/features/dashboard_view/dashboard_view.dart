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
                "CricLive",
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    Get.toNamed(NAV_SEARCH);
                  },
                ),
              ],
            ),
            drawer: Drawer(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            CircleAvatar(child: Icon(Icons.person)),
                            SizedBox(width: 10),
                            Text("Yash Patoliya"),
                          ],
                        ),
                      ),
                    ),

                    ListTile(
                      leading: Icon(Icons.settings),
                      title: Text("Settings"),
                    ),

                    ListTile(
                      leading: Icon(Icons.dark_mode),
                      title: Text("Dark Mode"),
                    ),

                    Container(
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.login_outlined),
                        title: Text("Log out"),
                      ),
                    ),
                  ],
                ),
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
