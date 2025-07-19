import 'package:cric_live/utils/import_exports.dart';

class ResultView extends StatelessWidget {
  const ResultView({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(APPBAR_RESULT),
          bottom: TabBar(tabs: const [Text("Scoreboard"), Text("Overs")]),
        ),
        body: TabBarView(
          children: [
            ListView(
              children: [
                ExpansionTile(
                  initiallyExpanded: true,
                  title: Text("Team-A  - 100/2"),
                  children: [_buildBatsman(context), _buildBowler(context)],
                ),
                ExpansionTile(
                  title: Text("Team-B  - 101/2"),
                  children: [_buildBatsman(context)],
                ),
              ],
            ),
            ListView(
              children: [for (int i = 0; i < 6; i++) _buildOvers(context)],
            ),
          ],
        ),
      ),
    );
  }

  _buildBatsman(context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DataTable(
        columnSpacing: 30,
        columns: [
          DataColumn(label: Text("Batsman")),
          DataColumn(label: Text("Runs")),
          DataColumn(label: Text("Balls")),
          DataColumn(label: Text("4s")),
          DataColumn(label: Text("6s")),
          DataColumn(label: Text("SR")),
        ],
        rows: [
          DataRow(
            cells: [
              DataCell(Column(children: [Text("player 1"), Text("not-out")])),
              DataCell(Text("45")),
              DataCell(Text("20")),
              DataCell(Text("2")),
              DataCell(Text("6")),
              DataCell(Text("200.00")),
            ],
          ),
          DataRow(
            cells: [
              DataCell(Column(children: [Text("player 2"), Text("not-out")])),
              DataCell(Text("20")),
              DataCell(Text("6")),
              DataCell(Text("0")),
              DataCell(Text("6")),
              DataCell(Text("200.00")),
            ],
          ),
        ],
      ),
    );
  }

  _buildBowler(context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DataTable(
        columnSpacing: 30,
        columns: [
          DataColumn(label: Text("Bowler")),
          DataColumn(label: Text("Overs")),
          DataColumn(label: Text("Balls")),
          DataColumn(label: Text("W")),
          DataColumn(label: Text("R")),
          DataColumn(label: Text("ER")),
        ],
        rows: [
          DataRow(
            cells: [
              DataCell(
                Column(
                  children: [
                    Text(
                      "player 1"
                      "",
                    ),
                    Text("not-out"),
                  ],
                ),
              ),
              DataCell(Text("45")),
              DataCell(Text("20")),
              DataCell(Text("2")),
              DataCell(Text("6")),
              DataCell(Text("200.00")),
            ],
          ),
        ],
      ),
    );
  }

  _buildOvers(context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(children: [Text("Ov 1"), Text("22 runs")]),
            for (int i = 0; i < 6; i++)
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: Text("1"),
              ),
          ],
        ),
      ),
    );
  }
}
