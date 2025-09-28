import 'package:cric_live/utils/import_exports.dart';

class SearchScreenBinding extends Bindings {
  @override
  void dependencies() {
    // Register API services if not already registered
    if (!Get.isRegistered<ApiServices>()) {
      Get.put(ApiServices(), permanent: true);
    }
    
    // Register search repository with proper dependency injection
    Get.lazyPut<ISearchRepository>(() => SearchRepositoryImpl(
      apiServices: Get.find<ApiServices>(),
    ));
    
    // Register search controller with proper dependency injection
    Get.lazyPut<SearchScreenController>(() => SearchScreenController(
      searchRepository: Get.find<ISearchRepository>(),
    ));
  }
}
