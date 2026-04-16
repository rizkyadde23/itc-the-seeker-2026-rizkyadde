import 'package:flutter/material.dart';
import '../models/member_model.dart';

class EditMemberPage extends StatelessWidget {
  final Member member;

  const EditMemberPage({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Anggota")),
      body: Text(member.name),
    );
  }
}