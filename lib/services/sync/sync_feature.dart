import 'package:cric_live/utils/import_exports.dart';

class SyncFeature {
  Future<void> updateMatch({required int matchId}) async {
    try {
      final Database db = await MyDatabase().database;
      List<Map<String, dynamic>> matches = await db.rawQuery(
        '''
          Select * from $TBL_MATCHES
          where id = ? and matchIdOnline is not null
        ''',
        [matchId],
      );
      if (matches.isEmpty) {
        log("⚠️ No match found with id=$matchId and matchIdOnline != null");
        syncAllMatches();
        return;
      }
      CreateMatchModel model = CreateMatchModel().fromMap(matches[0]);

      ApiServices _services = ApiServices();

      final res = await _services.put(
        "/CL_Matches/UpdateMatch/${model.matchIdOnline}",
        model.toMap(),
      );
      if (res.statusCode == 200) {
        log(
          "Success to update a match details ::::::::::::::::fromSync:::::::::::::UPDATE MATCH",
        );
      } else if (res.statusCode == 500) {
        log("Server error");
      }
    } catch (e) {
      log("Error in syncMatchUpdate");
      log(e.toString());
    }
  }

  Future<void> syncAllMatches() async {
    try {
      final Database db = await MyDatabase().database;
      List<Map<String, dynamic>> matches = await db.rawQuery('''
          Select * from $TBL_MATCHES
          where matchIdOnline is null
        ''');
      if (matches.isEmpty) {
        return;
      }
      ApiServices _services = ApiServices();
      List<int> onlineIds = [];
      for (var match in matches) {
        // Wrap in matchDto
        final res = await _services.post("/CL_Matches/CreateMatch", match);

        if (res.statusCode == 200 && res.body.isNotEmpty) {
          try {
            Map<String, dynamic> result = jsonDecode(res.body);
            if (result["matchId"] != null) {
              onlineIds.add(result["matchId"]);
            } else {
              log("⚠️ matchId missing in response: ${res.body}");
            }
          } catch (e) {
            log("⚠️ JSON decode failed: ${res.body}");
          }
        } else {
          log("⚠️ API failed: ${res.statusCode}, ${res.body}");
        }
      }

      for (int i = 0; i < onlineIds.length; i++) {
        CreateMatchModel? data = CreateMatchModel().fromMap(matches[i]);

        if (data == null || data.id == null) {
          log("⚠️ CreateMatchModel parsing failed for: ${matches[i]}");
          continue;
        }

        await db.rawUpdate(
          '''
    update $TBL_MATCHES
    set matchIdOnline = ?
    where id = ?
    ''',
          [onlineIds[i], data.id],
        );
      }
    } catch (e) {
      log("Error in syncAllMatches");
      log(e.toString());
    }
  }

  Future<void> syncMatchUpdate({required int matchId}) async {
    try {
      // final Database db = await MyDatabase().database;
      // List<Map<String, dynamic>> matches = await db.rawQuery(
      //   '''
      //     Select * from $TBL_MATCHES
      //     where id = ? and matchIdOnline is not null
      //   ''',
      //   [matchId],
      // );
      //
      // if (matches.isEmpty) {
      //   log("⚠️ No match found with id=$matchId and matchIdOnline != null");
      //   return;
      // }
      // CreateMatchModel model = CreateMatchModel().fromMap(matches[0]);

      // ApiServices _services = ApiServices();
      // final res = await _services.put("/CL_Matches/UpdateMatchState", {
      //   "matchState": model.matchState,
      //   "matchId": model.matchIdOnline,
      // });
      // if (res.statusCode == 200) {
      //   log("Success to update a state");
      // } else if (res.statusCode == 500) {
      //   log("Server error");
      // }
      updateMatch(matchId: matchId);
    } catch (e) {
      log("Error in syncMatchUpdate");
      log(e.toString());
    }
  }

  /// Enhanced connectivity check and callback execution
  Future<void> checkConnectivity(Function callback) async {
    try {
      // Use a network-based connectivity check instead of the problematic plugin
      bool hasConnection = await _networkBasedConnectivityCheck();

      if (hasConnection) {
        // Execute callback if connected
        await callback();
        print("✅ Internet connection available - Sync executed successfully");
      } else {
        print("❌ No network connection available for sync.");
      }
    } catch (e, s) {
      print("Error checking connectivity: $e");
      print(s);
    }
  }

  /// Network-based connectivity check that bypasses the problematic plugin
  Future<bool> _networkBasedConnectivityCheck() async {
    try {
      // Method 1: Try DNS lookup to Google
      final List<InternetAddress> result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (e) {
      print('DNS lookup failed: $e');
    }

    try {
      // Method 2: Try connecting to a reliable server
      final socket = await Socket.connect(
        '8.8.8.8',
        53,
        timeout: const Duration(seconds: 5),
      );
      socket.destroy();
      return true;
    } catch (e) {
      print('Socket connection failed: $e');
    }

    try {
      // Method 3: Try HTTP request to a reliable endpoint
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      final request = await client.getUrl(Uri.parse('https://www.google.com'));
      final response = await request.close();
      client.close();

      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print('HTTP request failed: $e');
    }

    print('❌ All connectivity tests failed - No internet connection');
    return false;
  }

  /// Get current connection status description
  Future<String> _getConnectionDescription() async {
    bool hasConnection = await _networkBasedConnectivityCheck();
    return hasConnection
        ? 'Internet connection available'
        : 'No internet connection';
  }

  /// Listen for connectivity changes using periodic checks
  Timer? _connectivityTimer;
  bool _lastConnectionStatus = false;

  void listenForChanges() {
    // Check connectivity every 10 seconds
    _connectivityTimer = Timer.periodic(const Duration(seconds: 10), (
      timer,
    ) async {
      try {
        bool currentStatus = await _networkBasedConnectivityCheck();

        // Only act on status changes
        if (currentStatus != _lastConnectionStatus) {
          String connectionDesc = await _getConnectionDescription();

          if (currentStatus) {
            print("🟢 $connectionDesc - Attempting sync...");
            // Trigger sync when connection is restored
            syncAllMatches();
          } else {
            print("🔴 Connection lost!");
          }

          print("📶 Connection changed: $connectionDesc");
          _lastConnectionStatus = currentStatus;
        }
      } catch (e) {
        print('Connectivity check error: $e');
      }
    });

    // Do an initial check
    _performInitialConnectivityCheck();
  }

  void _performInitialConnectivityCheck() async {
    try {
      _lastConnectionStatus = await _networkBasedConnectivityCheck();
      String connectionDesc = await _getConnectionDescription();
      print('📶 Initial connection status: $connectionDesc');
    } catch (e) {
      print('Initial connectivity check failed: $e');
    }
  }

  /// Stop listening for connectivity changes
  void stopListening() {
    _connectivityTimer?.cancel();
    _connectivityTimer = null;
    print("🛑 Connectivity monitoring stopped.");
  }

  /// Check if currently connected to internet
  Future<bool> hasInternetConnection() async {
    return await _networkBasedConnectivityCheck();
  }

  /// Execute a function only if internet is available
  Future<void> executeWithConnection(
    Function callback, {
    Function()? onNoConnection,
  }) async {
    if (await hasInternetConnection()) {
      await callback();
    } else {
      print('No internet connection available');
      onNoConnection?.call();
    }
  }
}
