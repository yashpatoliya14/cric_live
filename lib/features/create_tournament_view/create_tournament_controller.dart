import 'package:cric_live/utils/import_exports.dart';

class CreateTournamentController extends GetxController {
  final CreateTournamentRepo _repo = CreateTournamentRepo();
  final AuthService _authService = AuthService();

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController formatController = TextEditingController();
  final TextEditingController scorerSearchController = TextEditingController();

  // Reactive search text
  final RxString searchText = ''.obs;

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxBool isCreatingTournament = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

  // Date variables
  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime> endDate = DateTime.now().add(Duration(days: 7)).obs;

  // Users and selection
  final RxList<UserModel> allUsers = <UserModel>[].obs;
  //search based
  final RxList<UserModel> filteredUsers = <UserModel>[].obs;
  final RxList<UserModel> selectedScorers = <UserModel>[].obs;

  // Teams
  final RxList<TeamModel> selectedTeams = <TeamModel>[].obs;

  // Form validation
  final RxBool isFormValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
    _setupListeners();
  }

  Future<void> _initializeData() async {
    await fetchAllUsers();
  }

  void _setupListeners() {
    // Listen to scorer search changes
    scorerSearchController.addListener(_filterUsers);

    // Listen to form changes for validation
    nameController.addListener(_validateForm);
    locationController.addListener(_validateForm);
    formatController.addListener(_validateForm);
  }

  /// Fetch all users from API
  Future<void> fetchAllUsers() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      List<UserModel> users = await _repo.getAllUsers();
      allUsers.assignAll(users);
      filteredUsers.assignAll(users);
    } catch (e) {
      errorMessage.value = 'Failed to fetch users: ${e.toString()}';
      log('Error fetching users: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter users based on search text
  void _filterUsers() {
    String searchText = scorerSearchController.text.toLowerCase();
    if (searchText.isEmpty) {
      filteredUsers.assignAll(allUsers);
    } else {
      List<UserModel> filtered =
          allUsers.where((user) {
            String fullName = user.fullDisplayName.toLowerCase();
            String userName = (user.userName ?? '').toLowerCase();
            String email = (user.email ?? '').toLowerCase();

            return fullName.contains(searchText) ||
                userName.contains(searchText) ||
                email.contains(searchText);
          }).toList();

      filteredUsers.assignAll(filtered);
    }
  }

  /// Add scorer to selected list
  void addScorer(UserModel user) {
    if (!selectedScorers.any((scorer) => scorer.uid == user.uid)) {
      selectedScorers.add(user);
      scorerSearchController.clear();
      _validateForm();
    }
  }

  /// Remove scorer from selected list
  void removeScorer(UserModel user) {
    selectedScorers.removeWhere((scorer) => scorer.uid == user.uid);
    _validateForm();
  }

  /// Add team to selected list
  void addTeam(TeamModel team) {
    if (!selectedTeams.any((t) => t.id == team.id)) {
      selectedTeams.add(team);
      _validateForm();
    }
  }

  /// Remove team from selected list
  void removeTeam(TeamModel team) {
    selectedTeams.removeWhere((t) => t.id == team.id);
    _validateForm();
  }

  /// Validate form inputs
  void _validateForm() {
    bool nameValid = nameController.text.trim().isNotEmpty;
    bool locationValid = locationController.text.trim().isNotEmpty;
    bool formatValid = formatController.text.trim().isNotEmpty;
    bool teamsValid = selectedTeams.length >= 2;

    isFormValid.value = nameValid && locationValid && formatValid && teamsValid;
  }

  /// Select start date
  Future<void> selectStartDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (picked != null) {
      startDate.value = picked;
      // Ensure end date is after start date
      if (endDate.value.isBefore(picked)) {
        endDate.value = picked.add(Duration(days: 1));
      }
    }
  }

  /// Select end date
  Future<void> selectEndDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate.value,
      firstDate: startDate.value,
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (picked != null) {
      endDate.value = picked;
    }
  }

  /// Create tournament with all validations and API calls
  Future<void> createTournament() async {
    if (!isFormValid.value) {
      errorMessage.value =
          'Please fill all required fields and select at least 2 teams';
      return;
    }

    try {
      isCreatingTournament.value = true;
      errorMessage.value = '';
      successMessage.value = '';

      // Get current user ID as host
      var tokenModel = _authService.fetchInfoFromToken();
      if (tokenModel?.uid == null) {
        throw Exception('User not authenticated');
      }

      // Create scorers list
      List<ScorerModel> scorers =
          selectedScorers
              .map(
                (user) =>
                    ScorerModel(scorerId: user.uid, username: user.userName),
              )
              .toList();

      // Create tournament model
      CreateTournamentModel tournament = CreateTournamentModel(
        tournamentId: 0,
        name: nameController.text.trim(),
        location: locationController.text.trim(),
        startDate: startDate.value,
        endDate: endDate.value,
        format: formatController.text.trim(),
        hostId: tokenModel!.uid!,
        createdAt: DateTime.now(),
        scorers: scorers,
      );

      // Create tournament
      int? tournamentId = await _repo.createTournament(tournament);

      if (tournamentId != null) {
        // Create tournament team associations
        await _createTournamentTeams(tournamentId);

        successMessage.value = 'Tournament created successfully!';
        Get.snackbar(
          'Success',
          'Tournament created successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.toNamed(
          NAV_TOURNAMENT_DISPLAY,
          arguments: {
            "tournamentId": tournamentId,
            "hostId":
                tokenModel.uid, // Pass the hostId which is the creator's uid
          },
        );
        // Clear form after successful creation
        _clearForm();
      } else {
        throw Exception('Tournament created but failed to get tournament ID');
      }
    } catch (e) {
      errorMessage.value = 'Failed to create tournament: ${e.toString()}';
      Get.snackbar(
        'Error',
        'Failed to create tournament: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      log('Error creating tournament: $e');
    } finally {
      isCreatingTournament.value = false;
    }
  }

  /// Create tournament team associations
  Future<void> _createTournamentTeams(int tournamentId) async {
    for (TeamModel team in selectedTeams) {
      TournamentTeamModel tournamentTeam = TournamentTeamModel(
        tournamentId: tournamentId,
        teamId: team.id,
      );
      log(tournamentTeam.toJson().toString());
      await _repo.createTournamentTeam(tournamentTeam);
    }
  }

  /// Clear form after successful creation
  void _clearForm() {
    nameController.clear();
    locationController.clear();
    formatController.clear();
    scorerSearchController.clear();
    selectedScorers.clear();
    selectedTeams.clear();
    startDate.value = DateTime.now();
    endDate.value = DateTime.now().add(Duration(days: 7));
    _validateForm();
  }

  @override
  void onClose() {
    nameController.dispose();
    locationController.dispose();
    formatController.dispose();
    scorerSearchController.dispose();
    super.onClose();
  }
}
