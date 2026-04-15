import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/member_controller.dart';

class StructurePage extends StatelessWidget {
  StructurePage({super.key});
  final MemberController controller = Get.put(MemberController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Struktur Organisasi")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.members.isEmpty) {
          return Center(child: Text("Tidak ada data"));
        }

        return ListView.builder(
          itemCount: controller.members.length,
          itemBuilder: (context, index) {
            final member = controller.members[index];

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(member.photoUrl),
              ),
              title: Text(member.name),
              subtitle: Text(member.role),
            );
          },
        );
      }),
    );
  }
}
