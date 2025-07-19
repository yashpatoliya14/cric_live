import 'package:cric_live/utils/import_exports.dart';

class CreateMatchView extends StatelessWidget {
  CreateMatchView({super.key});

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> _formKey = GlobalKey();
    return GetX<CreateMatchController>(
      init: CreateMatchController(),
      builder:
          (controller) => Form(
            key: _formKey,
            child: Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,

              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildCircleAvatar(
                              title: "Team A",
                              onPressed: () {
                                Get.toNamed(NAV_SELECT_TEAM);
                              },
                            ),
                            _buildCircleAvatar(
                              title: "Team B",
                              onPressed: () {
                                Get.toNamed(NAV_SELECT_TEAM);
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitle("Toss Winner"),
                          SizedBox(height: 5),
                          _buildRadioButton(
                            title1: TEAM_A,
                            title2: TEAM_B,
                            currentValue: controller.tossWinnerTeam.value,
                            onChanged: controller.onTossWinnerTeamChanged,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitle("Choose bat or bowl"),
                          SizedBox(height: 5),
                          _buildRadioButton(
                            title1: BAT,
                            title2: BOWL,
                            currentValue: controller.batOrBowl.value,
                            onChanged: controller.onbatOrBowlChanged,
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      _buildTitle("Match Settings"),
                      Column(
                        children: [
                          Row(
                            children: [
                              _buildCheckBox(
                                val: controller.isNoBall.value,
                                onChanged: controller.onNoBallChanged,
                                label: "Allow No-ball Runs",
                              ),
                              SizedBox(width: 5),
                              if (controller.isNoBall.value)
                                Container(
                                  width: 50,
                                  child: TextFormField(
                                    textAlign: TextAlign.center,
                                    controller: controller.controllerNoBallRun,

                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^[0-9]{1}$'),
                                      ),
                                    ],
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                            ],
                          ),
                          Row(
                            children: [
                              _buildCheckBox(
                                val: controller.isWide.value,
                                onChanged: controller.onWideChanged,
                                label: "Allow Wide Runs",
                              ),

                              if (controller.isWide.value)
                                Container(
                                  width: 50,
                                  child: TextFormField(
                                    textAlign: TextAlign.center,
                                    controller: controller.controllerWideRun,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^[0-9]{1}$'),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      _buildTitle("Overs"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 100,
                            child: TextFormField(
                              controller: controller.controllerOvers,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "overs",
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null) {
                                  return "Please enter a overs";
                                }
                                return null;
                              },
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d{0,3}$'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Get.toNamed(NAV_SCOREBOARD);
                        },
                        style: Theme.of(context).elevatedButtonTheme.style,
                        child: const Text(START_MATCH),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  _buildCheckBox({
    required bool val,
    required Function onChanged,
    required String label,
  }) {
    return Row(
      children: [
        Checkbox(value: val, onChanged: (value) => onChanged(value)),

        Text(label),
      ],
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

  _buildRadioButton({
    required String title1,
    required String title2,
    required String currentValue,
    required Function onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: RadioListTile(
            value: title1,
            groupValue: currentValue,
            onChanged: (value) => onChanged(value),
            title: Text(title1),
          ),
        ),
        Expanded(
          child: RadioListTile(
            value: title2,
            groupValue: currentValue,
            onChanged: (value) => onChanged(value),
            title: Text(title2),
          ),
        ),
      ],
    );
  }

  _buildTitle(String title) {
    return Row(
      children: [
        Expanded(
          child: Container(height: 2, color: Colors.blueGrey, child: Text("")),
        ),
        Padding(padding: const EdgeInsets.all(8.0), child: Text(title)),
        Expanded(
          child: Container(height: 2, color: Colors.blueGrey, child: Text("")),
        ),
      ],
    );
  }
}
