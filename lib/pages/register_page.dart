import 'package:flutter/material.dart';
import 'package:seeker/models/member_model.dart';
import 'package:seeker/routes/app_routes.dart';
import 'package:seeker/services/auth_service.dart';
import 'package:seeker/services/firestore_service.dart';
import 'package:get/get.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();

  final authService = AuthService();
  final firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Nama"),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Password"),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: "Phone"),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                await registerUser();
              },
              child: Text("Register"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> registerUser() async {
  try {
    final user = await authService.register(
      emailController.text,
      passwordController.text,
    );

    if (user != null) {
      // 🔥 1. create member
      final member = Member(
        id: '',
        name: nameController.text,
        role: "Anggota",
        divisionId: "general",
        photoUrl: "",
        periodId: "2025",
        bio: "",
        email: emailController.text,
        phone: phoneController.text,
        instagram: "",
      );

      final memberId = await firestoreService.createMember(member);

      // 🔥 2. create user
      await firestoreService.createUser(
        user.uid,
        emailController.text,
        memberId,
      );

      // 🔥 3. redirect
      Get.offAllNamed(AppRoutes.profile, arguments: memberId);
    }
  } catch (e) {
    print("ERROR: $e");

    Get.snackbar(
      "Register Gagal",
      e.toString(),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
}
