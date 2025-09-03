// lib/features/create_team_view/create_team_view.dart

import 'package:cric_live/features/create_team_view/create_team_controller.dart';
import 'package:cric_live/utils/import_exports.dart'; // Assuming this contains CustomTextFormField

class CreateTeamView extends StatelessWidget {
  const CreateTeamView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller using Get.put()
    final controller = Get.put(CreateTeamController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create a New Team"),
        actions: [
          // Add a button to the app bar to finalize team creation
          TextButton(
            onPressed: controller.createTeam,
            child: const Text(
              "CREATE",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section for Team Name and Logo
            Row(
              children: [
                const CircleAvatar(
                  radius: 35,
                  child: Icon(Icons.camera_alt, size: 30),
                  // Add onPressed functionality for image picking later
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextFormField(
                    controller: controller.controllerName,
                    hintText: "e.g., The Champions",
                    labelText: "Team Name",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Section for Adding Players
            const Text(
              "Add Players",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            CustomTextFormField(
              // Use the correct controller for search
              controller: controller.controllerSearch,
              hintText: "Search by name or email...",
              labelText: "Search Players",
            ),
            const SizedBox(height: 12),

            // Display for selected players
            Obx(() {
              if (controller.selectedUsers.isEmpty) {
                return const SizedBox.shrink(); // Hide if no one is selected
              }
              return Container(
                padding: const EdgeInsets.only(bottom: 12),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children:
                      controller.selectedUsers.map((user) {
                        return Chip(
                          label: Text(user.username ?? 'Unknown'),
                          onDeleted: () => controller.deselectUser(user),
                        );
                      }).toList(),
                ),
              );
            }),

            const Divider(),

            // Reactive list that shows search results
            Expanded(
              child: Obx(() {
                if (controller.searchUsers.isEmpty) {
                  return const Center(
                    child: Text("No players found. Start searching!"),
                  );
                }
                return ListView.builder(
                  itemCount: controller.searchUsers.length,
                  itemBuilder: (context, index) {
                    final user = controller.searchUsers[index];
                    return ListTile(
                      title: Text(user.firstName ?? 'No Name'),
                      subtitle: Text(user.email ?? 'No Email'),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.green,
                        ),
                        onPressed: () => controller.selectUser(user),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
