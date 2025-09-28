// lib/features/create_team_view/create_team_view.dart

import 'package:cric_live/utils/import_exports.dart';

class CreateTeamView extends StatelessWidget {
  const CreateTeamView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateTeamController>();

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: CommonAppHeader(
        title: "Create Team",
        subtitle: "Build your team",
        leadingIcon: Icons.group_add,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTeamInfoSection(controller),
                  const SizedBox(height: 24),
                  _buildSelectedPlayersSection(controller),
                  const SizedBox(height: 24),
                  _buildAddPlayerSection(controller),
                  const SizedBox(
                    height: 80,
                  ), // Extra space to avoid bottom button overlap
                ],
              ),
            ),
          ),
          _buildCreateButton(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamInfoSection(CreateTeamController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: Colors.deepOrange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Team Information",
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                  height: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Team Name",
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextFormField(
                textCapitalization: TextCapitalization.sentences,
                controller: controller.controllerName,
                hintText: "e.g., The Champions",
                labelText: "",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedPlayersSection(CreateTeamController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.people, color: Colors.green, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Selected Players",
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[800],
                        height: 1.0,
                      ),
                    ),
                    Obx(
                      () => Text(
                        "${controller.selectedPlayers.length} players selected",
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: Colors.grey[600],
                          height: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.selectedPlayers.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.person_add_outlined,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "No players selected yet",
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Search and add players to your team",
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }
            return Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children:
                  controller.selectedPlayers.map((player) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.deepOrange.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.deepOrange,
                            child: Text(
                              player.playerName!.substring(0, 1).toUpperCase(),
                              style: GoogleFonts.nunito(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            player.playerName ?? "",
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.deepOrange[700],
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => controller.removePlayer(player),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.red[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAddPlayerSection(CreateTeamController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.person_add, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                "Add Player",
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                  height: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  controller: controller.controllerPlayerName,
                  hintText: "Enter player name...",
                  labelText: "Player Name",
                  onFieldSubmitted: (_) => controller.addPlayer(),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: controller.addPlayer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      "Add",
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton(CreateTeamController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(
          () => SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed:
                  controller.isLoading.value ? null : controller.createTeam,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade500,
              ),
              child:
                  controller.isLoading.value
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Creating Team...",
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "CREATE TEAM",
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ),
      ),
    );
  }
}
