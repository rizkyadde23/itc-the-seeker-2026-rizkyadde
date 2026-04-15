import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  final String divisionName;

  DetailPage({required this.divisionName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(divisionName)),
      body: ListView(
        children: [
          ListTile(title: Text("Nama Anggota 1"), subtitle: Text("Role")),
          ListTile(title: Text("Nama Anggota 2"), subtitle: Text("Role")),
        ],
      ),
    );
  }
}
