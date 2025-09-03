import 'package:cric_live/utils/import_exports.dart';
import 'package:intl/intl.dart';

class TournamentView extends StatelessWidget {
  const TournamentView({super.key});

  @override
  Widget build(BuildContext context) {
    // It's better to add an isLoading flag to your controller for a robust UI
    // For now, we will assume loading is done when the matches list is populated.
    final controller = Get.find<TournamentController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Tournament Matches'), elevation: 0.5),
      body: Obx(() {
        // A dedicated isLoading flag in the controller is the best practice.
        // If you add `RxBool isLoading = true.obs;` to your controller,
        // you can use `if (controller.isLoading.value)`.
        if (controller.matches.isEmpty) {
          // This state could mean loading or no data.
          // A proper loader would differentiate between them.
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.hourglass_empty, size: 40, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No matches found for this tournament.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                TextButton(
                  onPressed: () {
                    controller.tempFetch();
                  },
                  child: Text("Refresh"),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            controller.tempFetch();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: controller.matches.length,
            itemBuilder: (context, index) {
              final match = controller.matches[index];
              return _buildMatchCard(match, controller);
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Map<String, dynamic> result = await Get.toNamed(
            NAV_CREATE_MATCH,
            arguments: {"tournamentId": controller.tournamentId},
          );
          log(
            ":::::::::::::::::::::::::::::::::::::::::::::::::result ${result["matchId"]}",
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Add New Match',
      ),
    );
  }

  Widget _buildMatchCard(
    CreateMatchModel match,
    TournamentController controller,
  ) {
    final team1 = match.team1 ?? 'Team A';
    final team2 = match.team2 ?? 'Team B';
    final matchDate =
        match.matchDate != null
            ? DateFormat('EEE, MMM d, yyyy').format(match.matchDate!)
            : 'Date TBD';

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        leading: const Icon(
          Icons.sports_cricket,
          color: Colors.blueAccent,
          size: 40,
        ),
        title: Text(
          '$team1 vs $team2',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(matchDate, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 4),
            ],
          ),
        ),
        trailing: TextButton(
          onPressed: () => controller.startMatch(match),
          child: const Text(
            'Start',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        onTap: () {
          // You can still navigate to match details from the main tile
          Get.snackbar(
            'Match Details',
            'Showing details for $team1 vs $team2',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      ),
    );
  }
}
