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
  String selectedGeneralRole = "General";
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

    selectedDivisionId =
        member.divisionId.isNotEmpty ? member.divisionId : '';

    selectedRole = [
      "Anggota",
      "Kepala Divisi",
      "Wakil Kepala Divisi",
    ].contains(member.role)
        ? member.role
        : "Anggota";

    selectedGeneralRole = [
      "General",
      "Ketua Umum",
      "Wakil Ketua Umum",
    ].contains(member.globalRole)
        ? member.globalRole
        : "General";

    selectedStatus = ["Active", "Inactive"].contains(member.status)
        ? member.status
        : "Active";

    isActive = selectedStatus == "Active";

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
      child: const CircularProgressIndicator(),
    );
  }

  Padding mainUI() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: deviceWidth! * 0.05),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nama"),
              validator: (v) => v!.isEmpty ? "Nama tidak boleh kosong" : null,
            ),

            const SizedBox(height: 10),

            TextFormField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Phone"),
            ),

            const SizedBox(height: 10),

            TextFormField(
              controller: instagramController,
              decoration: const InputDecoration(labelText: "Instagram"),
            ),

            const SizedBox(height: 10),

            TextFormField(
              controller: bioController,
              decoration: const InputDecoration(labelText: "Bio"),
              maxLines: 3,
            ),

            const SizedBox(height: 20),

            // STATUS
            if (isAdmin)
              DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                items: ["Active", "Inactive"]
                    .map((r) =>
                        DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value!;
                    isActive = value == "Active";
                  });
                },
                decoration: const InputDecoration(labelText: "Status"),
              ),

            const SizedBox(height: 20),

            // DIVISION
            if (isAdmin && isActive)
              StreamBuilder(
                stream: service.getDivisions(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final divisions = snapshot.data!.docs;

                  return DropdownButtonFormField<String>(
                    initialValue: divisions.any(
                            (d) => d.id == selectedDivisionId)
                        ? selectedDivisionId
                        : '',
                    items: divisions.map<DropdownMenuItem<String>>((d) {
                      return DropdownMenuItem(
                        value: d.id,
                        child: Text(d['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDivisionId = value;
                        selectedRole = "Anggota";
                      });
                    },
                    decoration:
                        const InputDecoration(labelText: "Division"),
                  );
                },
              ),

            const SizedBox(height: 20),

            // DIVISION ROLE
            if (isAdmin && isActive)
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                items: [
                  "Anggota",
                  "Kepala Divisi",
                  "Wakil Kepala Divisi"
                ]
                    .map((r) =>
                        DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: selectedDivisionId == ''
                    ? null
                    : (value) {
                        setState(() {
                          selectedRole = value!;
                        });
                      },
                decoration: const InputDecoration(labelText: "Role"),
              ),

            const SizedBox(height: 30),

            // GENERAL ROLE
            if (isAdmin && isActive)
              DropdownButtonFormField<String>(
                initialValue: selectedGeneralRole,
                items: ["General", "Ketua Umum", "Wakil Ketua Umum"]
                    .map((r) =>
                        DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedGeneralRole = value!;
                  });
                },
                decoration:
                    const InputDecoration(labelText: "General Role"),
              ),

            const SizedBox(height: 30),

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
      Map<String, dynamic> updateData = {
        'name': nameController.text,
        'phone': phoneController.text,
        'instagram': instagramController.text,
        'bio': bioController.text,
      };

      // 🔥 HANDLE INACTIVE
      if (selectedStatus == "Inactive") {
        if (member.role == "Kepala Divisi") {
          await service.removeHead(member.divisionId);
        }

        if (member.role == "Wakil Kepala Divisi") {
          await service.removeViceHead(member.divisionId);
        }

        if (member.globalRole == "Ketua Umum") {
          await service.removeGeneralLeader();
        }

        if (member.globalRole == "Wakil Ketua Umum") {
          await service.removeGeneralViceLeader();
        }

        updateData['divisionId'] = '';
        updateData['role'] = 'Anggota';

        await service.updateMemberPartial(member.id, updateData);
        return;
      }

      // 🔥 DIVISION
      if (selectedDivisionId != '' && selectedDivisionId != null) {
        updateData['divisionId'] = selectedDivisionId;
      }

      // 🔥 HANDLE DIVISION ROLE
      if (isAdmin && selectedDivisionId != '') {
        if (member.role == "Kepala Divisi" &&
            selectedRole != "Kepala Divisi") {
          await service.removeHead(member.divisionId);
        }

        if (member.role == "Wakil Kepala Divisi" &&
            selectedRole != "Wakil Kepala Divisi") {
          await service.removeViceHead(member.divisionId);
        }

        if (selectedRole == "Kepala Divisi") {
          await service.assignHead(
            divisionId: selectedDivisionId!,
            memberId: member.id,
          );
        } else if (selectedRole == "Wakil Kepala Divisi") {
          await service.assignViceHead(
            divisionId: selectedDivisionId!,
            memberId: member.id,
          );
        }
      }

      // 🔥 HANDLE GENERAL ROLE (SOURCE OF TRUTH = ORGANIZATION)
      if (isAdmin) {
        if (member.globalRole == "Ketua Umum" &&
            selectedGeneralRole != "Ketua Umum") {
          await service.removeGeneralLeader();
        }

        if (member.globalRole == "Wakil Ketua Umum" &&
            selectedGeneralRole != "Wakil Ketua Umum") {
          await service.removeGeneralViceLeader();
        }

        if (selectedGeneralRole == "Ketua Umum") {
          await service.assignGeneralLeader(memberId: member.id);
        } else if (selectedGeneralRole == "Wakil Ketua Umum") {
          await service.assignGeneralViceLeader(memberId: member.id);
        }
      }

      // 🔥 UPDATE BASIC DATA ONLY
      await service.updateMemberPartial(member.id, updateData);

      // 🔥 FINAL SYNC
      await service.syncOrganizationRoles();

      Get.snackbar("Success", "Profile updated");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }
}