import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import '../../models/friend_model.dart';
import '../../models/projectmember.dart';
import '../../services/friend_service.dart';
import '../profil_page/profile_controller.dart';

class FriendsController extends GetxController {
  final FriendService _service = Get.put(FriendService());

  var friendsList = <Friend>[].obs;
  var requestList = <Friend>[].obs;
  var isLoading = false.obs;
  var searchResults = <ProjectMember>[].obs; // Sonuçlar
  var isSearching = false.obs;
  final TextEditingController searchCtrl = TextEditingController();
  Timer? _debounce; // Her tuşa basınca istek atmasın, biraz beklesin


  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Kullanıcı yazmayı bıraktıktan 500ms sonra ara
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.length >= 2) {
        isSearching.value = true;
        searchResults.value = await _service.searchUsers(query);
        isSearching.value = false;
      } else {
        searchResults.clear();
      }
    });
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