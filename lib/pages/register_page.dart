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
  GlobalKey<FormState> registerFormKey = GlobalKey();
  bool isLoading = false;
  double? deviceHeight, deviceWidth;

  final authService = AuthService();
  final firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Register",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: deviceWidth! * 0.05),
          child: Stack(children: [mainUI(), if (isLoading) loadingWidget()]),
        ),
      ),
    );
  }

  Center loadingWidget() {
    return Center(
      child: Container(
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
      ),
    );
  }

  Column mainUI() {
    return Column(
      children: [registerForm(), SizedBox(height: 20), registerButton()],
    );
  }

  MaterialButton registerButton() {
    return MaterialButton(
      minWidth: deviceWidth! * 0.75,
      color: Colors.blue,
      onPressed: isLoading
          ? null
          : () async {
              await registerUser();
            },
      child: Text(
        "Register",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      ),
    );
  }

  Container registerForm() {
    return Container(
      height: deviceHeight! * 0.35,
      child: Form(
        key: registerFormKey,
        child: Column(
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Nama"),
              onSaved: (newValue) {
                setState(() {});
              },
              validator: (value) {
                if (value == '') {
                  return "Nama Tidak Boleh Kosong";
                }
                return null;
              },
            ),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
              onSaved: (newValue) {
                setState(() {
                  emailController.text = newValue!;
                });
              },
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
              onSaved: (newValue) {
                setState(() {
                  passwordController.text = newValue!;
                });
              },
              validator: (value) {
                if (value == null || value.length < 6) {
                  return "Password harus lebih dari 6 karakter";
                }
                return null;
              },
            ),
            TextFormField(
              controller: phoneController,
              decoration: InputDecoration(labelText: "Phone"),
              onSaved: (newValue) {
                setState(() {
                  phoneController.text = newValue!;
                });
              },
              validator: (value) {
                if (value == null || value.length < 9) {
                  return "Masukkan nomor dengan benar";
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> registerUser() async {
    try {
      if (registerFormKey.currentState!.validate()) {
        registerFormKey.currentState!.save();
        setState(() {
          isLoading = true;
        });
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
            divisionId: "",
            status: "Active",
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
          setState(() {
            isLoading = false;
          });
          Get.snackbar(
            "Register Success",
            "Registrasi Berhasil, Silahkan Login",
          );
          Get.offAllNamed(AppRoutes.login);
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Get.snackbar("Login Gagal :", "Masukkan Email dan Password Dengan Benar");
      await Future.delayed(Duration(seconds: 3));
      Get.back();
    }
  }
}
