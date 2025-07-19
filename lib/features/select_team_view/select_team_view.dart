import 'package:cric_live/utils/import_exports.dart';

class SelectTeamView extends StatelessWidget {
  const SelectTeamView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SelectTeamController());
    return Scaffold(
      appBar: AppBar(title: Text(APPBAR_SELECT_TEAM)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomTextFormField(
                controller: controller.controllerSearch,
                hintText: "Search Tournaments, Matches, Players",
                labelText: "Search",
              ),
            ),
            Center(child: Text("No Data Found")),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(NAV_CREATE_TEAM);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
