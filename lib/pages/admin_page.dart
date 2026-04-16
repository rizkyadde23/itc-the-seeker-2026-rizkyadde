import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seeker/routes/app_routes.dart';
import '../controllers/member_controller.dart';

class AdminPage extends StatelessWidget {
  AdminPage({super.key});
  final controller = Get.put(MemberController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Panel")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(AppRoutes.addMember);
        },
        child: Icon(Icons.add),
      ),
      body: Obx(() {
        return ListView.builder(
          itemCount: controller.members.length,
          itemBuilder: (context, index) {
            final member = controller.members[index];

            return ListTile(
              title: Text(member.name),
              subtitle: Text(member.role),

              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✏️ EDIT
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Get.toNamed(AppRoutes.editMember, arguments: member);
                    },
                  ),

                  // 🗑 DELETE
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      controller.deleteMember(member.id);
                    },
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
