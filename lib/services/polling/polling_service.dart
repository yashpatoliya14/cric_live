import 'package:cric_live/utils/import_exports.dart';

class PollingService {
  Timer? _timer;
  void startPolling({required Function fn, required int seconds}) {
    print("::::Polling happen:::");
    _timer = Timer.periodic(Duration(seconds: seconds), (timer) {
      print("function called in given seconds");
      fn();
    });
  }

  void stopPolling() {
    print("::::Polling stop:::");

    _timer?.cancel();
  }
}
