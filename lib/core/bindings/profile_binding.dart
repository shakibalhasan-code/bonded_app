import 'package:get/get.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/kyc_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    Get.lazyPut<KycController>(() => KycController(), fenix: true);
  }
}
