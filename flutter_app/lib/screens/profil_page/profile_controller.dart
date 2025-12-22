import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_x/get.dart';
import 'package:image_picker/image_picker.dart'; // Fotoğraf seçimi için

import '../../models/user_profile_model.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';

class ProfileController extends GetxController {
  // Servisleri güvenli bir şekilde çağırıyoruz
  final AuthService _authService = Get.put(AuthService());
  final UserService _userService = Get.put(UserService());

  final _storage = const FlutterSecureStorage();
  final TextEditingController apiKeyController = TextEditingController();
  final ImagePicker _picker = ImagePicker(); // Resim seçici

  // --- UI GÜNCELLEYEN DEĞİŞKENLER ---
  var id = 0.obs;
  var username = "...".obs;
  var email = "...".obs;
  var fullName = "...".obs;

  // TEK SEFER TANIMLANMALI (Hata buradaydı)
  var avatarUrl = "".obs;

  // İstatistikler
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

  // --- PROFİL YÜKLE ---
  void loadUserProfile() async {
    try {
      isLoading.value = true;
      print("🔄 Profil verileri çekiliyor...");

      UserProfile? profile = await _userService.getMyProfile();

      if (profile != null) {
        print("✅ Profil bulundu: ${profile.username}");

        id.value = profile.id;
        username.value = profile.username;
        email.value = profile.email;
        fullName.value = (profile.fullName != null && profile.fullName!.isNotEmpty)
            ? profile.fullName!
            : profile.username;

        // Avatar URL'sini al
        avatarUrl.value = profile.avatarUrl ?? "";

        totalTasks.value = profile.totalTasks;
        completedTasks.value = profile.completedTasks;
        friendsCount.value = profile.friendsCount;

        // API Key senkronizasyonu
        if (profile.geminiApiKey != null && profile.geminiApiKey!.isNotEmpty) {
          await _storage.write(key: 'gemini_api_key', value: profile.geminiApiKey);
        }
      } else {
        fullName.value = "Veri Alınamadı";
        username.value = "Hata";
      }
    } catch (e) {
      print("❌ Profil Yükleme Hatası: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- FOTOĞRAF SEÇ VE YÜKLE ---
  void pickAndUploadImage() async {
    try {
      // Galeriyi aç
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        Get.snackbar("Yükleniyor", "Fotoğraf sunucuya yükleniyor...", showProgressIndicator: true);

        // Servise gönder
        String? newUrl = await _userService.uploadAvatar(image);

        if (newUrl != null) {
          avatarUrl.value = newUrl; // Ekranı güncelle
          // Cache sorunu olmaması için URL'nin sonuna timestamp ekleyebilirsin ama şimdilik gerek yok
          Get.snackbar("Başarılı", "Profil fotoğrafı güncellendi!", backgroundColor: Colors.green, colorText: Colors.white);
        } else {
          Get.snackbar("Hata", "Yükleme başarısız oldu.", backgroundColor: Colors.red, colorText: Colors.white);
        }
      }
    } catch (e) {
      Get.snackbar("Hata", "Resim seçilemedi: $e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // --- API KEY KAYDETME ---
  void showApiKeyDialog() {
    apiKeyController.clear();

    Get.defaultDialog(
      title: "AI Ayarları",
      content: Column(
        children: [
          const Text("API Anahtarınız buluta kaydedilecektir.", style: TextStyle(fontSize: 12)),
          const SizedBox(height: 10),
          TextField(
            controller: apiKeyController,
            decoration: const InputDecoration(
              labelText: "Gemini API Key",
              hintText: "AI Studio'dan aldığınız key",
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      textConfirm: "Kaydet",
      textCancel: "İptal",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF1E3C72),
      onConfirm: () async {
        if (apiKeyController.text.isNotEmpty) {
          bool success = await _userService.updateProfile(
              apiKey: apiKeyController.text.trim()
          );

          if (success) {
            Get.back();
            await _storage.write(key: 'gemini_api_key', value: apiKeyController.text.trim());
            Get.snackbar("Başarılı", "Anahtar sunucuya kaydedildi! ✅",
                backgroundColor: Colors.green, colorText: Colors.white);
            loadUserProfile();
          } else {
            Get.snackbar("Hata", "Kaydedilemedi.", backgroundColor: Colors.red, colorText: Colors.white);
          }
        }
      },
    );
  }

  // --- PROFİL BİLGİLERİNİ GÜNCELLE ---
  Future<void> updateMyProfile(String newName, String newEmail) async {
    isLoading.value = true;
    bool success = await _userService.updateProfile(fullName: newName, email: newEmail);
    isLoading.value = false;

    if (success) {
      Get.back();
      Get.snackbar("Başarılı", "Profil güncellendi", backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.bottom);
      loadUserProfile();
    } else {
      Get.snackbar("Hata", "Güncelleme başarısız.", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // --- ÇIKIŞ YAP ---
  void logout() async {
    Get.defaultDialog(
      title: "Çıkış Yap",
      middleText: "Çıkış yapmak istediğinize emin misiniz?",
      textConfirm: "Evet",
      textCancel: "Hayır",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF1E3C72),
      onConfirm: () async {
        await _authService.logout();
      },
    );
  }

  @override
  void onClose() {
    apiKeyController.dispose();
    super.onClose();
  }
}