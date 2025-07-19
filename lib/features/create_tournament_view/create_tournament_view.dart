import 'package:cric_live/utils/import_exports.dart';

class CreateTournamentView extends StatelessWidget {
  const CreateTournamentView({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateTournamentController());
    GlobalKey<FormState> _formKey = GlobalKey();
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(title: Text(APPBAR_CREATE_TOURNAMENT)),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextFormField(
                  controller: controller.controllerHostName,
                  labelText: "Hostname",
                  validator: (value) {
                    if (value == null) {
                      return "Enter a Hostname";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                _buildTextFormField(
                  controller: controller.controllerFormats,
                  labelText: "Formats",
                  validator: (value) {
                    if (value == null) {
                      return "Enter a Formats";
                    }
                    return null;
                  },
                ),

                SizedBox(height: 10),
                _buildTextFormField(
                  controller: controller.controllerTournamentName,
                  labelText: "Tournament Name",
                  validator: (value) {
                    if (value == null) {
                      return "Enter a Tournament Name";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                _buildTextFormField(
                  controller: controller.controllerLocation,
                  labelText: "Location",
                  validator: (value) {
                    if (value == null) {
                      return "Enter a Location";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                Row(
                  spacing: 20,
                  children: [
                    Expanded(
                      child: _buildTextFormField(
                        controller: controller.controllerStartDate,
                        validator: () {},
                        readOnly: true,
                        labelText: "Start date",
                        onTap: () async {
                          DateTime selectedStartDate =
                              await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(
                                      DateTime.now().year + 5,
                                      12,
                                      31,
                                    ),
                                  )
                                  as DateTime;

                          controller.controllerStartDate.text =
                              "${selectedStartDate.day}/${selectedStartDate.month}/${selectedStartDate.year}";
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildTextFormField(
                        controller: controller.controllerStartDate,
                        validator: () {},
                        readOnly: true,
                        labelText: "End date",
                        onTap: () async {
                          DateTime selectedStartDate =
                              await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(
                                      DateTime.now().year + 5,
                                      12,
                                      31,
                                    ),
                                  )
                                  as DateTime;

                          controller.controllerStartDate.text =
                              "${selectedStartDate.day}/${selectedStartDate.month}/${selectedStartDate.year}";
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {},
                  child: Text("Create Tournament"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildTextFormField({
    required TextEditingController controller,
    required Function validator,
    Function? onTap,
    Function? onChanged,
    bool? readOnly,
    required String labelText,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly ?? false,
      validator: (value) => validator(value),
      decoration: InputDecoration(labelText: labelText),
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },
    );
  }
}
