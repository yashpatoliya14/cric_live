import 'package:cric_live/features/create_team_view/create_team_controller.dart';
import 'package:cric_live/utils/import_exports.dart';

class CreateTeamView extends StatelessWidget {
  const CreateTeamView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateTeamController());
    return Scaffold(
      appBar: AppBar(title: Text(APPBAR_CREATE_TEAM)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      maxRadius: 50,
                      child: IconButton(
                        padding: EdgeInsets.all(38),
                        icon: Icon(Icons.camera_alt),
                        onPressed: () {},
                      ),
                    ),
                    Text("Team Logo"),
                  ],
                ),
              ),
              SizedBox(height: 10),
              CustomTextFormField(
                controller: controller.controllerName,
                hintText: "Enter Team Name",
                labelText: "Team Name",
              ),
              SizedBox(height: 15),
              CustomTextFormField(
                controller: controller.controllerName,
                hintText: "Search player...",
                labelText: "Search",
              ),
              SizedBox(height: 10),
              Center(child: Text("No player data available")),
            ],
          ),
        ),
      ),
    );
  }
}
