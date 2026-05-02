import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../services/socket_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<SocketService>(SocketService(), permanent: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
  }
}
