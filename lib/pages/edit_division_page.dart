import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditDivisionPage extends StatefulWidget {
  const EditDivisionPage({super.key});

  @override
  State<EditDivisionPage> createState() => _EditDivisionPageState();
}

class _EditDivisionPageState extends State<EditDivisionPage> {
  late QueryDocumentSnapshot division;

  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController descController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    division = Get.arguments;

    nameController = TextEditingController(text: division['name']);
    descController = TextEditingController(text: division['description']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Divisi")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 🔥 NAME
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nama Divisi"),
                validator: (v) => v!.isEmpty ? "Nama tidak boleh kosong" : null,
              ),

              const SizedBox(height: 16),

              // 🔥 DESCRIPTION
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: "Deskripsi Divisi",
                ),
                maxLines: 10,
              ),

              const SizedBox(height: 30),

              // 🔥 SAVE BUTTON
              ElevatedButton(
                onPressed: isLoading ? null : updateDivision,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> updateDivision() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('divisions')
          .doc(division.id)
          .update({
            'name': nameController.text,
            'description': descController.text,
          });

      Get.snackbar("Success", "Divisi berhasil diupdate");
      await Future.delayed(Duration(seconds: 1));
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }
}
