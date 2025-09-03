import 'package:cric_live/features/players_view/players_controller.dart';
import 'package:cric_live/utils/import_exports.dart';

class PlayersView extends StatelessWidget {
  const PlayersView({super.key});

  @override
  Widget build(BuildContext context) {
    final int teamId = Get.arguments['teamId'];
    final bool isView = Get.arguments['isView'];
    final controller = Get.put(
      PlayersController(teamId: teamId, isView: isView),
    );
    return Scaffold(
      appBar: AppBar(title: Text(APPBAR_TEAM_PLAYERS)),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemBuilder: (context, id) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 2),
                    child: ListTile(
                      style: Theme.of(context).listTileTheme.style,
                      leading: Text(
                        controller.players[id].playerName.toString(),
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  );
                },
                itemCount: controller.players.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
