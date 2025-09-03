import 'package:cric_live/utils/import_exports.dart';

class ResultView extends StatelessWidget {
  const ResultView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ResultController>(
      init: ResultController(),
      builder: (controller) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Obx(() => Text(controller.matchTitle)),
              actions: [
                IconButton(
                  icon: Icon(Icons.home),
                  onPressed: () {
                    Get.offAllNamed(NAV_DASHBOARD_PAGE);
                  },
                ),
              ],
              bottom: TabBar(
                tabs: const [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Scoreboard"),
                  ),
                  Padding(padding: EdgeInsets.all(8.0), child: Text("Overs")),
                ],
              ),
            ),
            body: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading match result...'),
                    ],
                  ),
                );
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 48),
                      SizedBox(height: 16),
                      Text(
                        controller.errorMessage.value,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: controller.refreshMatchData,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (!controller.hasMatchData) {
                return Center(child: Text('No match data available'));
              }

              return TabBarView(
                children: [
                  _buildScoreboardTab(controller),
                  _buildOversTab(controller),
                ],
              );
            }),
          ),
        );
      },
    );
  }

  ///first page
  Widget _buildScoreboardTab(ResultController controller) {
    return RefreshIndicator(
      onRefresh: controller.refreshMatchData,
      child: ListView(
        padding: EdgeInsets.all(8.0),
        children: [
          // Match Result Summary
          if (controller.resultSummary.isNotEmpty)
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  controller.resultSummary,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          SizedBox(height: 8),

          // Team 1 Innings
          if (controller.hasTeamData(1)) _buildTeamInningsCard(controller, 1),

          // Team 2 Innings
          if (controller.hasTeamData(2)) _buildTeamInningsCard(controller, 2),
        ],
      ),
    );
  }

  Widget _buildTeamInningsCard(ResultController controller, int inningNo) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        shape: Border(),
        initiallyExpanded: inningNo == 1,
        title: Text(
          "${controller.getTeamName(inningNo)} - ${controller.getTeamScore(inningNo)} (${controller.getTeamOversDisplay(inningNo)} overs)",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        children: [
          _buildBattingTable(controller, inningNo),
          if (controller.getBowlingResults(inningNo).isNotEmpty)
            _buildBowlingTable(controller, inningNo),
        ],
      ),
    );
  }

  Widget _buildBattingTable(ResultController controller, int inningNo) {
    List<PlayerBattingResultModel> battingResults = controller
        .getBattingResults(inningNo);

    if (battingResults.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No batting data available'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          headingRowColor: WidgetStateProperty.all(
            Theme.of(Get.context!).colorScheme.secondary,
          ),
          columns: [
            DataColumn(label: Text("Batsman")),
            DataColumn(label: Text("Runs")),
            DataColumn(label: Text("Balls")),
            DataColumn(label: Text("4s")),
            DataColumn(label: Text("6s")),
            DataColumn(label: Text("SR")),
          ],
          rows:
              battingResults
                  .map(
                    (player) => _buildBatsmanRow(
                      player.playerName ?? 'Unknown',
                      player.dismissalInfo,
                      (player.runs ?? 0).toString(),
                      (player.balls ?? 0).toString(),
                      (player.fours ?? 0).toString(),
                      (player.sixes ?? 0).toString(),
                      player.strikeRate?.toStringAsFixed(1) ?? '0.0',
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  Widget _buildBowlingTable(ResultController controller, int inningNo) {
    List<PlayerBowlingResultModel> bowlingResults = controller
        .getBowlingResults(inningNo);

    if (bowlingResults.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No bowling data available'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 30,
          headingRowColor: WidgetStateProperty.all(
            Theme.of(Get.context!).colorScheme.secondary,
          ),
          columns: [
            DataColumn(label: Text("Bowler")),
            DataColumn(label: Text("Overs")),
            DataColumn(label: Text("R")),
            DataColumn(label: Text("W")),
            DataColumn(label: Text("ER")),
          ],
          rows:
              bowlingResults
                  .map(
                    (player) => _buildBowlerRow(
                      player.playerName ?? 'Unknown',
                      player.oversDisplay,
                      (player.runs ?? 0).toString(),
                      (player.wickets ?? 0).toString(),
                      player.economyRate?.toStringAsFixed(2) ?? '0.00',
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  Widget _buildOversTab(ResultController controller) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: Theme.of(Get.context!).primaryColor,
            tabs: [
              Tab(text: controller.getTeamName(1)),
              Tab(text: controller.getTeamName(2)),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildInningsOvers(controller, 1),
                _buildInningsOvers(controller, 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInningsOvers(ResultController controller, int inningNo) {
    List<OverSummaryModel> overs = controller.getTeamOvers(inningNo);

    if (overs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No over data available for ${controller.getTeamName(inningNo)}',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: overs.length,
      itemBuilder: (context, index) {
        OverSummaryModel over = overs[index];
        return _buildOverCard(
          context,
          over.overNumber ?? 0,
          over.calculatedTotalRuns,
          over.displayBallResults,
          bowlerName: over.bowlerName ?? 'Unknown',
        );
      },
    );
  }

  Widget _buildOverCard(
    BuildContext context,
    int overNum,
    int runs,
    List<String> balls, {
    String? bowlerName,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Over $overNum",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "$runs runs",
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    if (bowlerName != null)
                      Text(
                        bowlerName,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    alignment: WrapAlignment.end,
                    children:
                        balls.isNotEmpty
                            ? balls
                                .map((ball) => _buildBall(context, ball))
                                .toList()
                            : [
                              Text(
                                'No balls data',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBall(BuildContext context, String result) {
    Color color;
    Color textColor = Colors.white;

    switch (result.toUpperCase()) {
      case 'W':
      case '1W':
      case '2W':
      case '3W':
      case '4W':
      case '6W':
        color = Colors.red.shade700;
        break;
      case '4':
        color = Colors.green.shade700;
        break;
      case '6':
        color = Colors.purple.shade700;
        break;
      case 'WD':
      case 'NB':
        color = Colors.orange.shade600;
        break;
      case '•':
      case '0':
        color = Colors.grey.shade400;
        textColor = Colors.black87;
        break;
      default:
        if (result.contains('4')) {
          color = Colors.green.shade700;
        } else if (result.contains('6')) {
          color = Colors.purple.shade700;
        } else {
          color = Colors.blue.shade600;
        }
    }

    return CircleAvatar(
      radius: 14,
      backgroundColor: color,
      child: Text(
        result,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  DataRow _buildBowlerRow(
    String name,
    String o,
    String r,
    String w,
    String er,
  ) {
    return DataRow(
      cells: [
        DataCell(
          Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
        DataCell(Center(child: Text(o))),
        DataCell(Center(child: Text(r))),
        DataCell(
          Center(
            child: Text(w, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        DataCell(Center(child: Text(er))),
      ],
    );
  }

  DataRow _buildBatsmanRow(
    String name,
    String dismissal,
    String r,
    String b,
    String fours,
    String sixes,
    String sr,
  ) {
    return DataRow(
      cells: [
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(
                dismissal,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
        DataCell(Center(child: Text(r))),
        DataCell(Center(child: Text(b))),
        DataCell(Center(child: Text(fours))),
        DataCell(Center(child: Text(sixes))),
        DataCell(Center(child: Text(sr))),
      ],
    );
  }
}
