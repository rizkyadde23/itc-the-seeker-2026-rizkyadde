import 'package:get/get.dart';
import '../models/member_model.dart';
import '../services/firestore_service.dart';

class MemberController extends GetxController {
  final FirestoreService service = FirestoreService();

  var members = <Member>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    fetchMembers();
    super.onInit();
  }

  Future<void> fetchMembers() async {
    try {
      isLoading.value = true;
      final result = await service.getMembers();
      members.value = result;
    } catch (e) {
      print("ERROR: $e");
    } finally {
      isLoading.value = false;
    }
  }
}