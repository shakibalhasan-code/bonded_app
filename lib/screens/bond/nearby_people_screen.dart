import 'package:bonded_app/models/bond_user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../controllers/bond_controller.dart';
import '../../widgets/bond/bond_user_card.dart';

class NearbyPeopleScreen extends StatelessWidget {
  const NearbyPeopleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BondController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B0B3B)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Nearby People",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B0B3B),
          ),
        ),
      ),
      body: Obx(
        () => controller.isLoadingNearby.value
            ? const Center(child: CircularProgressIndicator())
            : controller.filteredNearbyPeople.isEmpty
                ? const Center(child: Text("No one nearby found"))
                : ListView.builder(
                    padding: EdgeInsets.all(24.w),
                    itemCount: controller.filteredNearbyPeople.length,
                    itemBuilder: (context, index) {
                      return BondUserCard(
                        connection: controller.filteredNearbyPeople[index],
                        status: BondStatus.nearby,
                      );
                    },
                  ),
      ),
    );
  }
}
