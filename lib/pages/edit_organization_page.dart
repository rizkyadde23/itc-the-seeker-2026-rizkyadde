import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seeker/routes/app_routes.dart';
import '../services/firestore_service.dart';

class EditOrganizationPage extends StatefulWidget {
  const EditOrganizationPage({super.key});

  @override
  State<EditOrganizationPage> createState() => _EditOrganizationPageState();
}

class _EditOrganizationPageState extends State<EditOrganizationPage> {
  final service = FirestoreService();

  final nameController = TextEditingController();
  final descController = TextEditingController();
  final visionController = TextEditingController();
  final missionController = TextEditingController();
  GlobalKey<FormState> editOrgKey = GlobalKey();

  bool isSaving = false;
  double? deviceHeight, deviceWidth;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final data = await service.getOrganization();

    if (data != null) {
      nameController.text = data['name'] ?? '';
      descController.text = data['description'] ?? '';
      visionController.text = data['vision'] ?? '';
      missionController.text = data['mission'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Organization")),
      body: Stack(
        children: [
          mainUI(),
          if (isSaving) Center(child: loadingWidget()),
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
      padding: EdgeInsets.symmetric(horizontal: deviceWidth! * 0.05),
      child: Form(
        key: editOrgKey,
        child: Column(
          children: [
            TextFormField(
              controller: nameController,
              onSaved: (newValue) {
                setState(() {});
              },
              validator: (value) {
                if (value == '') {
                  return "Nama Tidak Boleh Kosong";
                }
                return null;
              },
              decoration: InputDecoration(labelText: "Nama Organisasi"),
            ),

            const SizedBox(height: 10),

            TextFormField(
              controller: descController,
              decoration: InputDecoration(labelText: "Deskripsi"),
              maxLines: 3,
            ),

            const SizedBox(height: 10),

            TextFormField(
              controller: visionController,
              decoration: InputDecoration(labelText: "Visi"),
              maxLines: 2,
            ),

            const SizedBox(height: 10),

            TextFormField(
              controller: missionController,
              decoration: InputDecoration(labelText: "Misi"),
              maxLines: 3,
            ),

            const SizedBox(height: 20),

            MaterialButton(
              color: Colors.green,
              minWidth: deviceWidth! * 0.7,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onPressed: isSaving ? null : save,
              child: const Text(
                "Save",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> save() async {
    if (editOrgKey.currentState!.validate()) {
      editOrgKey.currentState!.save();
      setState(() => isSaving = true);
      try {
        await service.updateOrganization({
          'name': nameController.text,
          'description': descController.text,
          'vision': visionController.text,
          'mission': missionController.text,
        });
        setState(() {
          isSaving = false;
        });
        Get.snackbar("Success", "Data organisasi diupdate");
      } catch (e) {
        Get.snackbar("Error", e.toString());
      } finally {
        setState(() => isSaving = false);
      }
    }
  }
}
