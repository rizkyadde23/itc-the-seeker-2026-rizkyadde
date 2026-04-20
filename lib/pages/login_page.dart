import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seeker/routes/app_routes.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  double? deviceHeight, deviceWidth;

  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final authService = AuthService();

  final firestoreService = FirestoreService();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          "ITC DIRECTORY",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: deviceWidth! * 0.05),
                child: mainUI(),
              ),
            ),
          ),

          if (isLoading) Center(child: loadingWidget()),
        ],
      ),
    );
  }

  Container loadingWidget() {
    return Container(
      alignment: Alignment.center,
      width: deviceWidth! * 0.30,
      height: deviceHeight! * 0.15,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black, blurRadius: 5, spreadRadius: 1),
        ],
      ),
      child: CircularProgressIndicator(
        color: const Color.fromARGB(255, 41, 117, 248),
      ),
    );
  }

  Column mainUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        hintText(),
        loginForm(),

        Container(height: deviceHeight! * 0.4),

        loginButton(),
        registerButton(),
      ],
    );
  }

  TextButton registerButton() {
    return TextButton(
      onPressed: () {
        Get.toNamed(AppRoutes.register);
      },
      child: Text(
        "Belum punya akun? Register",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.blue,
        ),
      ),
    );
  }

  MaterialButton loginButton() {
    return MaterialButton(
      color: Colors.blue,
      textColor: Colors.white,
      minWidth: deviceWidth! * 0.75,
      onPressed: isLoading
          ? null
          : () async {
              await loginUser();
            },
      child: Text(
        "Login",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      ),
    );
  }

  Future<void> loginUser() async {
    if (loginFormKey.currentState!.validate()) {
      loginFormKey.currentState!.save();
      setState(() {
        isLoading = true;
      });

      try {
        final user = await authService.login(
          emailController.text,
          passwordController.text,
        );

        if (user != null) {
          final role = await firestoreService.getUserRole(user.uid);
          setState(() {
            isLoading = false;
          });
          if (role == 'admin') {
            Get.snackbar("Login Berhasil", "Selamat Datang Di ITC Directory");
            Get.offAllNamed(AppRoutes.admin);
          } else {
            Get.snackbar("Login Berhasil", "Selamat Datang Di ITC Directory");
            Get.offAllNamed(AppRoutes.home);
          }
        }
      } on Exception catch (e) {
        setState(() {
          isLoading = false;
        });
        Get.snackbar(
          "Login Gagal :",
          "Masukkan Email dan Password Dengan Benar",
        );
        await Future.delayed(Duration(seconds: 3));
        Get.back();
      }
    }
  }

  Container loginForm() {
    return Container(
      height: deviceHeight! * 0.23,
      child: Form(
        key: loginFormKey,
        child: Column(
          children: [
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
              onSaved: (newValue) => setState(() {
                emailController.text = newValue!;
              }),
              validator: (value) {
                bool result = value!.contains(
                  RegExp(
                    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
                  ),
                );
                return result ? null : "Masukkan Email Dengan Benar!";
              },
            ),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Password"),
              onSaved: (newValue) => setState(() {
                passwordController.text = newValue!;
              }),
              validator: (value) {
                if (value == null || value.length < 6) {
                  return "Password harus lebih dari 6 karakter";
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Container hintText() {
    return Container(
      padding: EdgeInsets.only(top: deviceHeight! * 0.05),
      alignment: AlignmentGeometry.centerLeft,
      child: Text(
        "Log Into ITC Directory",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      ),
    );
  }
}
