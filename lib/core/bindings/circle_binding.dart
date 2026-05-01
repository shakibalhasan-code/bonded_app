import 'package:get/get.dart';
import '../../controllers/circle_controller.dart';
import '../../controllers/profile_controller.dart';

class CircleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CircleController());
    Get.lazyPut(() => ProfileController());
  }
}
