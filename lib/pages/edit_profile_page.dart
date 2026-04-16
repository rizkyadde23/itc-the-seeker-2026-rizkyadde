import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seeker/routes/app_routes.dart';

import '../models/member_model.dart';
import '../services/firestore_service.dart';

class EditProfilePage extends StatefulWidget {
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final service = FirestoreService();

  late Member member;

  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController instagramController;
  late TextEditingController bioController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    member = Get.arguments;

    nameController = TextEditingController(text: member.name);
    phoneController = TextEditingController(text: member.phone);
    instagramController = TextEditingController(text: member.instagram);
    bioController = TextEditingController(text: member.bio);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 🔥 NAME
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Nama"),
                validator: (value) =>
                    value!.isEmpty ? "Nama tidak boleh kosong" : null,
              ),

              SizedBox(height: 10),

              // 🔥 PHONE
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(labelText: "Phone"),
              ),

              SizedBox(height: 10),

              // 🔥 INSTAGRAM
              TextFormField(
                controller: instagramController,
                decoration: InputDecoration(labelText: "Instagram"),
              ),

              SizedBox(height: 10),

              // 🔥 BIO
              TextFormField(
                controller: bioController,
                decoration: InputDecoration(labelText: "Bio"),
                maxLines: 3,
              ),

              SizedBox(height: 20),

              // 🔥 SAVE BUTTON
              ElevatedButton(
                onPressed: isLoading ? null : updateProfile,
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => isLoading = true);

    try {

      await service.updateMember(member.id, {
        'name': nameController.text,
        'phone': phoneController.text,
        'instagram': instagramController.text,
        'bio': bioController.text,
      });


      Get.snackbar("Success", "Profile berhasil diupdate");


      Get.offAllNamed(AppRoutes.structure);

    } catch (e) {
      print("ERROR: $e");
      Get.snackbar("Error", e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }
}
