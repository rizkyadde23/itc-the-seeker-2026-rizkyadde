import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seeker/routes/app_routes.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final authService = AuthService();
  final firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: emailController),
            TextField(controller: passwordController, obscureText: true),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                final user = await authService.login(
                  emailController.text,
                  passwordController.text,
                );

                if (user != null) {
                  final role = await firestoreService.getUserRole(user.uid);

                  if (role == 'admin') {
                    Get.offAllNamed(AppRoutes.admin);
                  } else {
                    Get.offAllNamed(AppRoutes.home);
                  }
                }
              },
              child: Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
