import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seeker/routes/app_routes.dart';

import '../services/firestore_service.dart';

class AddDivisionPage extends StatefulWidget {
  @override
  State<AddDivisionPage> createState() => _AddDivisionPageState();
}

class _AddDivisionPageState extends State<AddDivisionPage> {
  final service = FirestoreService();
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tambah Divisi")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Nama Divisi"),
                validator: (v) => v!.isEmpty ? "Nama tidak boleh kosong" : null,
              ),

              SizedBox(height: 20),

              TextFormField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: "Deskripsi Divisi",
                  hintText: "Opsional",
                ),
              ),

              SizedBox(height: 20),

              ElevatedButton(
                onPressed: isLoading ? null : addDivision,
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Tambah Divisi"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addDivision() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await service.addDivision(nameController.text, descController.text);

      Get.snackbar("Success", "Divisi berhasil ditambahkan");

      Get.offAllNamed(AppRoutes.admin);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }
}
