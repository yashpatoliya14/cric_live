import 'package:cric_live/features/search_view/search_screen_controller.dart';
import 'package:cric_live/utils/import_exports.dart';

class SearchScreenView extends StatelessWidget {
  const SearchScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SearchScreenController());
    return Scaffold(
      appBar: AppBar(title: Text(APPBAR_SEARCH)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomTextFormField(
                controller: controller.controllerSearch,
                hintText: "Search Tournaments, Players, Matches ...",
                labelText: "Search",
              ),
            ),
            Center(child: Text("No Data Found")),
          ],
        ),
      ),
    );
  }
}
