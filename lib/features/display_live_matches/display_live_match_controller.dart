import 'dart:developer' as developer;

import 'package:cric_live/features/dashboard_view/dashboard_repo.dart';
import 'package:cric_live/services/polling/polling_service.dart';
import 'package:cric_live/utils/import_exports.dart';

class DisplayLiveMatchController extends GetxController {
  late DashboardRepo _repo;
  late PollingService _pollingService;

  //rx variable
  RxList<CreateMatchModel> matches = <CreateMatchModel>[].obs;
  RxList<CompleteMatchResultModel> matchesState =
      <CompleteMatchResultModel>[].obs;
  RxBool isLoading = false.obs;
  RxBool hasMatches = false.obs;
  RxString error = "".obs;
  RxBool isPollingActive = false.obs;

  ///on init function
  @override
  void onInit() {
    super.onInit();
    _repo = DashboardRepo();
    //Todo: might error occur
    _loadInitialMatches();
    _pollingService = PollingService();
    _pollingService.startPolling(fn: () => getMatchesState(), seconds: 60);
    _pollingService.startPolling(fn: () => getMatches(), seconds: 60);
  }

  Future<void> getMatches() async {
    try {
      final data = await _repo.getLiveMatches();
      if (data != null) {
        matches.assignAll(data);
        matches.refresh();
      }
    } catch (e) {
      error.value = e.toString();
      developer.log('Error in getMatches: $e');
    }
  }

  /// Load initial matches using simple approach
  Future<void> _loadInitialMatches() async {
    try {
      isLoading.value = true;
      error.value = "";
      matches.clear();
      matchesState.clear();

      await getMatches(); // fills matches

      for (var match in matches) {
        final data = await _repo.getLiveMatchesState(match);
        if (data != null) {
          developer.log('Loaded match: ${data.matchTitle}');
          matchesState.add(data);
        }
      }

      hasMatches.value = matchesState.isNotEmpty;
    } catch (e) {
      error.value = e.toString();
      developer.log('Error loading initial matches: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getMatchesState() async {
    try {
      isLoading.value = true;
      error.value = "";

      await _loadInitialMatches();
      return;
    } catch (e) {
      error.value = e.toString();
      developer.log('Error in manual refresh: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _pollingService.stopPolling();
    super.onClose();
  }
}
