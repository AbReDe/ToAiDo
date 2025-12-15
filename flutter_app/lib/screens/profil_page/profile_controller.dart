
import 'package:flutter/material.dart';
import 'package:get_x/get.dart';

import '../../models/user_profile_model.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';


class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  // User Service'i çağırıyoruz
  final UserService _userService = Get.put(UserService());

  // Gözlemlenebilir Değişkenler
  var username = "...".obs;
  var email = "...".obs;
  var fullName = "...".obs; // Düzenleme ekranı için lazım

  var totalTasks = 0.obs;
  var completedTasks = 0.obs;
  var friendsCount = 0.obs;

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  // --- GERÇEK VERİYİ ÇEK ---
  void loadUserProfile() async {
    isLoading.value = true;

    UserProfile? profile = await _userService.getMyProfile();

    if (profile != null) {
      username.value = profile.username;
      email.value = profile.email;
      fullName.value = profile.fullName ?? ""; // Null gelirse boş yap

      // İstatistikler Backend'den geliyor!
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