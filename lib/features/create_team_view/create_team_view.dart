import 'package:cric_live/features/create_team_view/create_team_controller.dart';
import 'package:cric_live/utils/import_exports.dart';

class CreateTeamView extends StatelessWidget {
  const CreateTeamView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<CreateTeamController>(
      init: CreateTeamController(),
      builder:
          (controller) => Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,

            body: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildCircleAvatar(title: "Team A", onPressed: () {}),
                      _buildCircleAvatar(title: "Team B", onPressed: () {}),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile(
                          value: controller.tossWinnerTeam.value,
                          groupValue: controller.teams,
                          onChanged: controller.onTossWinnerTeamChanged,

                          title: Text("Team A"),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile(
                          value: controller.tossWinnerTeam.value,
                          groupValue: controller.teams,
                          onChanged: controller.onTossWinnerTeamChanged,
                          title: Text("Team B"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  _buildCircleAvatar({required String title, required Function onPressed}) {
    return Column(
      children: [
        CircleAvatar(
          maxRadius: 50,
          child: IconButton(
            padding: EdgeInsets.all(38),
            icon: Icon(Icons.add),
            onPressed: () => onPressed(),
          ),
        ),
        Text(title),
      ],
    );
  }
}
