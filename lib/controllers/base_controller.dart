import 'package:get/get.dart';

class BaseController extends GetxController {
  // Add common controller logic here, such as loading states or error handling

  final RxBool isLoading = false.obs;

  void setLoading(bool value) {
    isLoading.value = value;
  }
}
