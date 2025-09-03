// lib/features/create_team_view/create_team_controller.dart

import 'package:cric_live/features/create_team_view/create_team_repo.dart';
import 'package:cric_live/features/signup_view/signup_model.dart';
import 'package:cric_live/utils/import_exports.dart';

class CreateTeamController extends GetxController {
  final CreateTeamRepo _repo = CreateTeamRepo();
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerSearch = TextEditingController();

  // Observable list for search results
  RxBool isLoading = false.obs;
  RxList<SignupModel> searchUsers = <SignupModel>[].obs;
  // Observable list for users selected for the team
  RxList<SignupModel> selectedUsers = <SignupModel>[].obs;

  // Debounce to prevent excessive API calls while typing
  final Rx<Timer?> _debounce = Rx<Timer?>(null);

  @override
  void onInit() {
    super.onInit();
    // Add a listener to the search controller to trigger search with a debounce
    controllerSearch.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce.value?.isActive ?? false) _debounce.value!.cancel();
    _debounce.value = Timer(const Duration(milliseconds: 500), () {
      if (controllerSearch.text.isNotEmpty) {
        searchUser();
      } else {
        searchUsers.clear(); // Clear results if search is empty
      }
    });
  }

  // Searches for users based on the text in the search controller
  searchUser() async {
    // Exclude already selected users from new search results
    final currentSelectedIds = selectedUsers.map((user) => user.uid).toSet();
    final results = await _repo.searchUser(controllerSearch.text) ?? [];
    searchUsers.value =
        results
            .where((user) => !currentSelectedIds.contains(user.uid))
            .toList();
  }

  // Adds a user to the selected list and removes them from the search list
  void selectUser(SignupModel user) {
    if (!selectedUsers.any((element) => element.uid == user.uid)) {
      selectedUsers.add(user);
      searchUsers.removeWhere((element) => element.uid == user.uid);
    }
  }

  // Removes a user from the selected list
  void deselectUser(SignupModel user) {
    selectedUsers.removeWhere((element) => element.uid == user.uid);
  }

  // Validates input and calls the repository to create the team
  createTeam() async {
    // CORRECTED: Check for a minimum of 2 players
    if (selectedUsers.length < 2) {
      Get.snackbar(
        "Invalid Team Size",
        "You must select at least 2 players to create a team.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (controllerName.text.isEmpty) {
      Get.snackbar(
        "Invalid Team Name",
        "Please enter a name for your team.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    isLoading.value = true;
    await _repo.createTeam(selectedUsers, controllerName.text);
    isLoading.value = false;

    Get.back(); // Go back to the previous screen on success
  }

  @override
  void onClose() {
    controllerName.dispose();
    controllerSearch.dispose();
    _debounce.value?.cancel();
    super.onClose();
  }
}
