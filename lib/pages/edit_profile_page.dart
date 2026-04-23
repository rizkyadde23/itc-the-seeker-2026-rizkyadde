import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/member_model.dart';
import '../services/firestore_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

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
  String selectedStatus = "Active";

  bool isAdmin = false;
  bool isActive = true;
  bool isLoading = false;

  double? deviceWidth, deviceHeight;

  @override
  void initState() {
    super.initState();

    member = Get.arguments;

    nameController = TextEditingController(text: member.name);
    phoneController = TextEditingController(text: member.phone);
    instagramController = TextEditingController(text: member.instagram);
    bioController = TextEditingController(text: member.bio);

    selectedDivisionId = member.divisionId.isNotEmpty
        ? member.divisionId
        : null;

    selectedRole = ["Anggota", "Ketua", "Wakil"].contains(member.role)
        ? member.role
        : "Anggota";

    selectedStatus = ["Active", "inactive"].contains(member.status)
        ? member.status
        : "Active";

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
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Stack(
        children: [
          mainUI(),
          if (isLoading)
            Center(child: loadingWidget()),
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

  Padding mainUI() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: deviceWidth!*0.05),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            // 🔥 NAME
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nama"),
              validator: (v) => v!.isEmpty ? "Nama tidak boleh kosong" : null,
            ),

            const SizedBox(height: 10),

            // 🔥 PHONE
            TextFormField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Phone"),
            ),

            const SizedBox(height: 10),

            // 🔥 INSTAGRAM
            TextFormField(
              controller: instagramController,
              decoration: const InputDecoration(labelText: "Instagram"),
            ),

            const SizedBox(height: 10),

            // 🔥 BIO
            TextFormField(
              controller: bioController,
              decoration: const InputDecoration(labelText: "Bio"),
              maxLines: 3,
            ),

            const SizedBox(height: 20),

            if (isAdmin)
              DropdownButtonFormField<String>(
                initialValue: ["Active", "Inactive"].contains(selectedStatus)
                    ? selectedStatus
                    : "Active",
                items: ["Active", "Inactive"]
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value!;
                    isActive = selectedStatus == "Active" ? true : false;
                  });
                },
                decoration: const InputDecoration(labelText: "Status"),
              ),

            const SizedBox(height: 20),

            // 🔥 DIVISION (ADMIN ONLY)
            if (isAdmin && isActive)
              StreamBuilder(
                stream: service.getDivisions(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final divisions = snapshot.data!.docs;

                  return DropdownButtonFormField<String>(
                    initialValue:
                        divisions.any((d) => d.id == selectedDivisionId)
                        ? selectedDivisionId
                        : null,
                    hint: const Text("Pilih Divisi"),
                    items: divisions.map<DropdownMenuItem<String>>((d) {
                      return DropdownMenuItem(
                        value: d.id,
                        child: Text(d['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDivisionId = value;

                        // 🔥 reset role kalau division berubah
                        selectedRole = "Anggota";
                      });
                    },
                    decoration: const InputDecoration(labelText: "Division"),
                  );
                },
              ),

            const SizedBox(height: 20),

            // 🔥 ROLE (ADMIN ONLY)
            if (isAdmin && isActive)
              DropdownButtonFormField<String>(
                initialValue:
                    ["Anggota", "Ketua", "Wakil"].contains(selectedRole)
                    ? selectedRole
                    : "Anggota",
                items: ["Anggota", "Ketua", "Wakil"]
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: selectedDivisionId == null
                    ? null // 🔥 disable kalau belum pilih divisi
                    : (value) {
                        setState(() {
                          selectedRole = value!;
                        });
                      },
                decoration: const InputDecoration(labelText: "Role"),
              ),

            const SizedBox(height: 30),

            // 🔥 SAVE BUTTON
            MaterialButton(
              color: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 5,
              onPressed: updateProfile,
              child: const Text(
                "Save",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      // 🔥 VALIDASI ROLE KHUSUS
      if (isAdmin && (selectedRole == "Ketua" || selectedRole == "Wakil")) {
        if (selectedDivisionId == null || selectedDivisionId!.isEmpty) {
          Get.snackbar("Error", "Divisi wajib dipilih");
          return;
        }
      }

      Map<String, dynamic> updateData = {
        'name': nameController.text,
        'phone': phoneController.text,
        'instagram': instagramController.text,
        'bio': bioController.text,
      };

      // 🔥 HANDLE STATUS INACTIVE
      if (selectedStatus == "Inactive") {
        final oldDivisionId = member.divisionId;
        final oldRole = member.role;

        // 🔥 kalau dia Ketua → remove dari division
        if (oldRole == "Ketua" && oldDivisionId.isNotEmpty) {
          await service.removeLeader(oldDivisionId);
        }

        // 🔥 kalau dia Wakil → remove juga
        if (oldRole == "Wakil" && oldDivisionId.isNotEmpty) {
          await service.removeViceLeader(oldDivisionId);
        }

        // 🔥 reset data
        updateData['divisionId'] = null;
        updateData['role'] = 'Anggota';
        await service.deactivateMember(member);
      }

      // 🔥 hanya kirim division kalau valid
      if (selectedDivisionId != null && selectedDivisionId!.isNotEmpty) {
        updateData['divisionId'] = selectedDivisionId;
      }

      // 🔥 ROLE LOGIC (ADMIN ONLY)
      // 🔥 HANDLE ROLE CHANGE
      if (isAdmin && selectedDivisionId != null) {
        final oldDivisionId = member.divisionId;
        final oldRole = member.role;

        // 🔥 kalau sebelumnya Ketua → remove
        if (oldRole == "Ketua" &&
            oldDivisionId.isNotEmpty &&
            selectedRole != "Ketua") {
          await service.removeLeader(oldDivisionId);
        }

        // 🔥 kalau sebelumnya Wakil → remove
        if (oldRole == "Wakil" &&
            oldDivisionId.isNotEmpty &&
            selectedRole != "Wakil") {
          await service.removeViceLeader(oldDivisionId);
        }

        // 🔥 assign role baru
        if (selectedRole == "Ketua") {
          await service.assignLeader(
            divisionId: selectedDivisionId!,
            memberId: member.id,
          );
        } else if (selectedRole == "Wakil") {
          await service.assignViceLeader(
            divisionId: selectedDivisionId!,
            memberId: member.id,
          );
        }
      }

      await service.updateMemberPartial(member.id, updateData);

      Get.snackbar("Success", "Profile updated");
      await Future.delayed(Duration(seconds: 1));
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }
}
