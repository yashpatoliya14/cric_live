import 'package:cric_live/utils/import_exports.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    return Drawer(
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
                    Obx(() => Text("${controller.email}")),
                  ],
                ),
              ),
            ),

            ListTile(leading: Icon(Icons.settings), title: Text("Settings")),

            ListTile(leading: Icon(Icons.dark_mode), title: Text("Dark Mode")),

            Container(
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                onTap: () {
                  Get.offAllNamed(NAV_LOGIN);
                },
                leading: Icon(Icons.login_outlined),
                title: Text("Log out"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
