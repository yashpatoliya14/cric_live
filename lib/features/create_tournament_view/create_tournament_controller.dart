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
  final RxList<UserModel> searchedUsers = <UserModel>[].obs;
  final RxList<UserModel> selectedScorers = <UserModel>[].obs;
  
  // Search state
  final RxBool isSearching = false.obs;
  final RxString lastSearchQuery = ''.obs;

  // Teams
  final RxList<TeamModel> selectedTeams = <TeamModel>[].obs;

  // Form validation
  final RxBool isFormValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    log('CreateTournamentController onInit started');
    _initializeData();
    _setupListeners();
    log('CreateTournamentController onInit completed');
  }

  Future<void> _initializeData() async {
    // Don't fetch users initially - only search when user types
    log('Tournament creation initialized - users will be loaded on search');
    
    // Test user parsing with sample API data
    testUserParsing();
  }

  void _setupListeners() {
    // Listen to form changes for validation
    nameController.addListener(_validateForm);
    locationController.addListener(_validateForm);
    formatController.addListener(_validateForm);
    
    // Note: Search is now triggered manually via search button, not on text changes
  }

  /// Fetch all users from API
  Future<void> fetchAllUsers() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      List<UserModel> users = await _repo.getAllUsers();
      allUsers.assignAll(users);
    } catch (e) {
      errorMessage.value = 'Failed to fetch users: ${e.toString()}';
      log('Error fetching users: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Search users from API based on query
  Future<void> searchUsers() async {
    try {
      String query = scorerSearchController.text.trim();
      
      // Don't search if query is empty
      if (query.isEmpty) {
        searchedUsers.clear();
        Get.snackbar(
          'Search Required',
          'Please enter a search term',
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade800,
        );
        return;
      }
      
      // Don't search if same as last search
      if (query == lastSearchQuery.value) {
        return;
      }
      
      // Set loading state
      isSearching.value = true;
      errorMessage.value = '';
      lastSearchQuery.value = query;
      
      List<UserModel> users = await _repo.searchUsers(query);
      
      // Update search results
      searchedUsers.assignAll(users);
      
      if (users.isEmpty) {
        Get.snackbar(
          'No Results',
          'No users found for "$query"',
          backgroundColor: Colors.blue.shade100,
          colorText: Colors.blue.shade800,
        );
      }
      
    } catch (e) {
      errorMessage.value = 'Search failed: ${e.toString()}';
      log('Error searching users: $e');
      searchedUsers.clear();
      
      Get.snackbar(
        'Search Error',
        'Failed to search users. Please try again.',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isSearching.value = false;
    }
  }
  
  /// Clear search results
  void clearSearch() {
    scorerSearchController.clear();
    searchedUsers.clear();
    lastSearchQuery.value = '';
    errorMessage.value = '';
  }

  /// Add scorer to selected list
  void addScorer(UserModel user) {
    if (!isUserSelected(user)) {
      selectedScorers.add(user);
      _validateForm();
      
      // Show success message
      Get.snackbar(
        'Scorer Added',
        '${user.fullDisplayName} added as scorer',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        duration: Duration(seconds: 2),
      );
    }
  }
  
  /// Check if user is already selected
  bool isUserSelected(UserModel user) {
    return selectedScorers.any((scorer) => scorer.uid == user.uid);
  }
  
  /// Test method to validate user parsing with sample data
  void testUserParsing() {
    Map<String, dynamic> sampleUserData = {
      "uid": 2,
      "username": "yashpatoliya59",
      "email": "yashpatoliya59@gmail.com",
      "password": "",
      "firstName": "yash",
      "gender": "male",
      "lastName": "patel",
      "isVerified": 1,
      "role": "user",
      "profilePhoto": " "
    };
    
    log('Testing user parsing with sample data: $sampleUserData');
    
    try {
      UserModel testUser = UserModel.fromJson(sampleUserData);
      log('Parsed user successfully:');
      log('  - UID: ${testUser.uid}');
      log('  - Username: ${testUser.userName}');
      log('  - FirstName: ${testUser.firstName}');
      log('  - LastName: ${testUser.lastName}');
      log('  - Email: ${testUser.email}');
      log('  - Display Name: ${testUser.displayName}');
      log('  - Full Display Name: ${testUser.fullDisplayName}');
    } catch (e) {
      log('Error parsing test user: $e');
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
    Future.delayed(Duration(milliseconds: 2000));
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
