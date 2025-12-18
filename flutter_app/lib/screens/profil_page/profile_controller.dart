
import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../models/user_profile_model.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';


class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final UserService _userService = Get.put(UserService());


  var id = 0.obs;
  final TextEditingController apiKeyController = TextEditingController();
  final _storage = const FlutterSecureStorage();

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


  void showApiKeyDialog() async {
    // Mevcut key'i oku
    String? currentKey = await _storage.read(key: 'gemini_api_key');
    apiKeyController.text = currentKey ?? "";

    Get.defaultDialog(
      title: "AI Ayarları",
      titleStyle: const TextStyle(color: Color(0xFF1E3C72), fontWeight: FontWeight.bold),
      content: Column(
        children: [
          const Text(
            "Gemini API Anahtarınızı giriniz. Bu anahtar sadece telefonunuzda saklanır.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: apiKeyController,
            decoration: const InputDecoration(
              labelText: "Gemini API Key",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.key),
            ),
            obscureText: true, // Şifreli gibi görünsün
          ),
        ],
      ),
      textConfirm: "Kaydet",
      textCancel: "İptal",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF1E3C72),
      onConfirm: () async {
        if (apiKeyController.text.isNotEmpty) {
          await _storage.write(key: 'gemini_api_key', value: apiKeyController.text);
          Get.back();
          Get.snackbar("Başarılı", "API Anahtarı kaydedildi!",
              backgroundColor: Colors.green, colorText: Colors.white);
        }
      },
    );
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