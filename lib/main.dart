import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seeker/pages/add_division_page.dart';
import 'package:seeker/pages/division_description_page.dart';
import 'package:seeker/pages/edit_division_page.dart';
import 'package:seeker/pages/edit_organization_page.dart';
import 'package:seeker/pages/edit_profile_page.dart';
import 'package:seeker/pages/home_page.dart';
import 'package:seeker/pages/inactive_member_page.dart';
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
      theme: ThemeData(
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.green[700],
          unselectedItemColor: const Color.fromARGB(255, 0, 0, 0),
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
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
        GetPage(name: '/inactive', page: () => InactiveMembersPage()),
        GetPage(name: '/division-desc', page: () => DivisionPage()),
        GetPage(name: '/edit-division', page: () => EditDivisionPage()),
        GetPage(name: '/edit-organization', page: () => EditOrganizationPage()),
      ],
    );
  }
}
