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
  double? deviceHeight, deviceWidth;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    division = Get.arguments;

    nameController = TextEditingController(text: division['name']);
    descController = TextEditingController(text: division['description']);
  }

  Container loadingWidget(double deviceHeight, double deviceWidth) {
    return Container(
      alignment: Alignment.center,
      width: deviceWidth * 0.30,
      height: deviceHeight * 0.15,
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

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Divisi")),
      body: Stack(
        children: [
          mainUI(deviceWidth!),
          if (isLoading)
            Center(child: loadingWidget(deviceHeight!, deviceWidth!)),
        ],
      ),
    );
  }

  Padding mainUI(double deviceWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.05),
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
              decoration: const InputDecoration(labelText: "Deskripsi Divisi"),
              maxLines: 10,
            ),

            const SizedBox(height: 30),

            // 🔥 SAVE BUTTON
            MaterialButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              minWidth: deviceWidth * 0.7,
              color: Colors.green,
              onPressed: isLoading ? null : updateDivision,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
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
      setState(() {
        isLoading = false;
      });
      await Future.delayed(Duration(seconds: 1));
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }
}
