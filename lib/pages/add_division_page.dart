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
  double? deviceHeight, deviceWidth;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: Text("Tambah Divisi")),
      body: Stack(
        children: [
          mainUI(),
          if (isLoading)
            Center(child: loadingWidget()),
        ],
      ),
    );
  }

  Padding mainUI() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: deviceWidth! * 0.05),
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

            MaterialButton(
              minWidth: deviceWidth! * 0.7,
              color: Colors.green,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onPressed: isLoading ? null : addDivision,
              child: Text(
                "Tambah Divisi",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
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

  Future<void> addDivision() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await service.addDivision(nameController.text, descController.text);

      Get.snackbar("Success", "Divisi berhasil ditambahkan");
      setState(() {
        isLoading = false;
      });
      Get.offAllNamed(AppRoutes.admin);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }
}
