import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  String? selectedDivisionId;
  String selectedRole = "Anggota";

  bool isAdmin = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    member = Get.arguments;

    nameController = TextEditingController(text: member.name);
    phoneController = TextEditingController(text: member.phone);
    instagramController = TextEditingController(text: member.instagram);
    bioController = TextEditingController(text: member.bio);

    selectedDivisionId = member.divisionId;
    selectedRole = member.role;

    checkAdmin();
  }

  Future<void> checkAdmin() async {
    final role = await service.getCurrentUserRole();
    setState(() {
      isAdmin = role == 'admin';
    });
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
                validator: (v) => v!.isEmpty ? "Nama tidak boleh kosong" : null,
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

              if (isAdmin)
                // 🔥 DIVISION DROPDOWN
                StreamBuilder(
                  stream: service.getDivisions(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }

                    final divisions = snapshot.data!.docs;

                    return DropdownButtonFormField<String>(
                      initialValue: selectedDivisionId == 'general'
                          ? null
                          : selectedDivisionId,
                      hint: Text("Pilih Divisi"),
                      items: divisions.map<DropdownMenuItem<String>>((d) {
                        return DropdownMenuItem(
                          value: d.id,
                          child: Text(d['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDivisionId = value;
                        });
                      },
                      decoration: InputDecoration(labelText: "Division"),
                    );
                  },
                ),

              if (isAdmin)
                DropdownButtonFormField<String>(
                  initialValue: ["Anggota", "Ketua"].contains(selectedRole)
                      ? selectedRole
                      : null,
                  items: ["Anggota", "Ketua"]
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value!;
                    });
                  },
                  decoration: InputDecoration(labelText: "Role"),
                ),

              SizedBox(height: 30),

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
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      // 🔥 UPDATE BASIC DATA
      Map<String, dynamic> updateData = {
        'name': nameController.text,
        'phone': phoneController.text,
        'instagram': instagramController.text,
        'bio': bioController.text,
        'divisionId': selectedDivisionId ?? '',
      };

      // 🔥 ADMIN ONLY UPDATE ROLE
      if (isAdmin) {
        updateData['role'] = selectedRole;
      }

      await service.updateMemberPartial(member.id, updateData);

      Get.snackbar("Success", "Profile updated");

      Get.back(result: true);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }
}
