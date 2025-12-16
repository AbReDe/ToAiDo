import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import '../../models/friend_model.dart';
import '../../services/friend_service.dart';
import '../profil_page/profile_controller.dart';

class FriendsController extends GetxController {
  final FriendService _service = Get.put(FriendService());

  var friendsList = <Friend>[].obs;
  var requestList = <Friend>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  void fetchAll() async {
    isLoading.value = true;
    friendsList.value = await _service.getFriends();
    requestList.value = await _service.getPendingRequests();

    // Profil ekranındaki "Arkadaş Sayısını" ve "Bildirim durumunu" güncelle
    // ProfileController'ı bulup veriyi güncelliyoruz
    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().friendsCount.value = friendsList.length;
      Get.find<ProfileController>().hasPendingRequests.value = requestList.isNotEmpty;
    }

    isLoading.value = false;
  }

  // İstek Gönder
  void sendRequest(String username) async {
    if(username.isEmpty) return;
    Get.back();
    String msg = await _service.sendRequest(username);
    Get.snackbar("Bilgi", msg, backgroundColor: Colors.black87, colorText: Colors.white);
  }

  // Kabul Et / Reddet
  void respond(int id, bool accept) async {
    String action = accept ? "accept" : "reject";
    bool success = await _service.respondRequest(id, action);
    if(success) {
      Get.snackbar("Başarılı", accept ? "Arkadaş eklendi!" : "İstek silindi");
      fetchAll(); // Listeyi yenile
    }
  }
}