import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'detail_page.dart';

class StructurePage extends StatelessWidget {
  final divisions = [
    "Divisi IT",
    "Divisi HR",
    "Divisi Marketing",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Struktur Organisasi")),
      body: ListView.builder(
        itemCount: divisions.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(divisions[index]),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Get.to(() => DetailPage(
                    divisionName: divisions[index],
                  ));
            },
          );
        },
      ),
    );
  }
}