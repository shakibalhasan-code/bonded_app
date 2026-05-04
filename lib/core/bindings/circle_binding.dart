import 'package:get/get.dart';
import '../../controllers/circle_controller.dart';
import '../../controllers/profile_controller.dart';

class CircleBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CircleController(), permanent: true);
    Get.lazyPut(() => ProfileController(), fenix: true);
  }
}
