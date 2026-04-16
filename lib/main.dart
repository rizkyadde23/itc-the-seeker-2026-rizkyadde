import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seeker/pages/add_division_page.dart';
import 'package:seeker/pages/edit_profile_page.dart';
import 'package:seeker/pages/home_page.dart';
import 'package:seeker/pages/login_page.dart';
import 'package:seeker/pages/structure_page.dart';
import 'package:seeker/pages/admin_page.dart';
import 'package:seeker/pages/profile_page.dart';
import 'package:seeker/pages/register_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      getPages: [
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/home', page: () => HomePage()),
        GetPage(name: '/structure', page: () => StructurePage()),
        GetPage(name: '/admin', page: () => AdminPage()),

        GetPage(
          name: '/profile',
          page: () => ProfilePage(),
          preventDuplicates: false,
        ),

        GetPage(name: '/register', page: () => RegisterPage()),
        GetPage(name: '/edit-profile', page: () => EditProfilePage()),
        GetPage(name: '/add-division', page: () => AddDivisionPage()),
      ],
    );
  }
}
