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

  bool isLoading = true;
  bool isSaving = false;

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

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Organization")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Nama Organisasi"),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: descController,
              decoration: InputDecoration(labelText: "Deskripsi"),
              maxLines: 3,
            ),

            const SizedBox(height: 10),

            TextField(
              controller: visionController,
              decoration: InputDecoration(labelText: "Visi"),
              maxLines: 2,
            ),

            const SizedBox(height: 10),

            TextField(
              controller: missionController,
              decoration: InputDecoration(labelText: "Misi"),
              maxLines: 3,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: isSaving ? null : save,
              child: isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> save() async {
    setState(() => isSaving = true);

    try {
      await service.updateOrganization({
        'name': nameController.text,
        'description': descController.text,
        'vision': visionController.text,
        'mission': missionController.text,
      });

      Get.snackbar("Success", "Data organisasi diupdate");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      setState(() => isSaving = false);
    }
  }
}
