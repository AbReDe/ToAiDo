
import 'package:flutter/material.dart';
import 'package:get_x/get.dart';

import '../../models/user_profile_model.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';


class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final UserService _userService = Get.put(UserService());

  // --- EKSİK OLAN 'ID' DEĞİŞKENİNİ BURAYA EKLİYORUZ ---
  var id = 0.obs; // Kullanıcının ID'si
  // ----------------------------------------------------

  var username = "...".obs;
  var email = "...".obs;
  var fullName = "...".obs;

  var totalTasks = 0.obs;
  var completedTasks = 0.obs;
  var friendsCount = 0.obs;
  var hasPendingRequests = false.obs;

  var isLoading = false.obs;

  @override
  void onInit() {
  super.onInit();
  loadUserProfile();
  }

  void loadUserProfile() async {
  isLoading.value = true;

  UserProfile? profile = await _userService.getMyProfile();

  if (profile != null) {
  // --- ID'Yİ KAYDETMEYİ UNUTMA ---
  id.value = profile.id;
  // -------------------------------

  username.value = profile.username;
  email.value = profile.email;
  fullName.value = profile.fullName ?? "";

  totalTasks.value = profile.totalTasks;
  completedTasks.value = profile.completedTasks;
  friendsCount.value = profile.friendsCount;
  }

  isLoading.value = false;
  }

  // --- PROFİL GÜNCELLEME ---
  Future<void> updateMyProfile(String newName, String newEmail) async {
    isLoading.value = true;
    bool success = await _userService.updateProfile(newName, newEmail);
    isLoading.value = false;

    if (success) {
      Get.back(); // Sayfayı kapat
      Get.snackbar("Başarılı", "Profil bilgileriniz güncellendi",
          backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.bottom);

      // Verileri tekrar çek ki ekrana yansısın
      loadUserProfile();
    }
  }

  void logout() async {
    Get.defaultDialog(
      title: "Çıkış Yap",
      middleText: "Hesabınızdan çıkış yapmak istediğinize emin misiniz?",
      textConfirm: "Evet, Çık",
      textCancel: "İptal",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF1E3C72),
      onConfirm: () async {
        // Sadece servisi çağır, yönlendirmeyi servis yapacak
        await _authService.logout();
      },
    );
  }
}