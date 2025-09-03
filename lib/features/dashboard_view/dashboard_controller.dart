import 'package:cric_live/features/dashboard_view/dashboard_repo.dart';
import 'package:cric_live/services/auth/auth_service.dart';
import 'package:cric_live/services/auth/token_model.dart';
import 'package:cric_live/utils/import_exports.dart';

class DashboardController extends GetxController {
  late DashboardRepo _repo;

  RxString email = "".obs;
  @override
  void onInit() {
    _repo = DashboardRepo();
    fetchEmail();
    // TODO: implement onInit
    super.onInit();
  }

  fetchEmail() {
    AuthService authService = AuthService();
    TokenModel? model = authService.fetchInfoFromToken();
    log(model.toString());
    email.value = model?.email ?? "";

    email.refresh();
  }

  @override
  void onClose() {
    // TODO: implement onInit
    super.onClose();
  }
}
