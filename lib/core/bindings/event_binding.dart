import 'package:get/get.dart';
import '../../controllers/event_controller.dart';
import '../../controllers/create_event_controller.dart';

class EventBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EventController>(() => EventController());
    Get.lazyPut<CreateEventController>(() => CreateEventController());
  }
}
