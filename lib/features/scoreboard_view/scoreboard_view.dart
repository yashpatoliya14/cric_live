import 'package:cric_live/utils/import_exports.dart';

class ScoreboardView extends StatelessWidget {
  const ScoreboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        appBar: AppBar(title: Text(APPBAR_SCOREBOARD)),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("TEAM A  vs TEAM B"),
                        ),
                      ],
                    ),

                    SizedBox(height: 5),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("59/2", style: GoogleFonts.abel(fontSize: 50)),
                      ],
                    ),

                    SizedBox(height: 5),

                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,

                          children: [
                            Text(
                              "Overs : 10",
                              style: GoogleFonts.aBeeZee(fontSize: 20),
                            ),
                            Text(
                              "Inning : 1st",
                              style: GoogleFonts.aBeeZee(fontSize: 20),
                            ),
                            Text(
                              "CRR : 5.5",
                              style: GoogleFonts.aBeeZee(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            "Batsman",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "Runs",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "Balls",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "4s",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "6s",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "SR",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text("player 1"),
                          Text("12"),
                          Text("14"),
                          Text("2"),
                          Text("0"),
                          Text("112"),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text("player 2"),
                          Text("48"),
                          Text("36"),
                          Text("6"),
                          Text("3"),
                          Text("153"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            "Bowler",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "Overs",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "Balls",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "4s",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "6s",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "ER",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text("player 3"),
                          Text("12"),
                          Text("10"),
                          Text("3"),
                          Text("0"),
                          Text("5.5"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      for (int i = 0; i < 6; i++)
                        CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          child: Text("1"),
                        ),
                    ],
                  ),
                ),
              ),

              Card(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton(
                            onPressed: () {},
                            child: Text("Wicket"),
                          ),
                          OutlinedButton(onPressed: () {}, child: Text("Wide")),
                          OutlinedButton(
                            onPressed: () {},
                            child: Text("No-Ball"),
                          ),
                          ElevatedButton(onPressed: () {}, child: Text("Undo")),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(onPressed: () {}, child: Text("1")),
                          TextButton(onPressed: () {}, child: Text("2")),
                          TextButton(onPressed: () {}, child: Text("3")),
                          OutlinedButton(
                            onPressed: () {},
                            child: Text("Retire"),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(onPressed: () {}, child: Text("4")),
                          TextButton(onPressed: () {}, child: Text("5")),
                          TextButton(onPressed: () {}, child: Text("6")),
                          OutlinedButton(onPressed: () {}, child: Text("Swap")),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.toNamed(NAV_RESULT);
                },
                child: Text(END_MATCH),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
