import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_x/get.dart';
import '../../models/user_profile_model.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';

class ProfileController extends GetxController {
  // Servisleri Bağlıyoruz
  final AuthService _authService = Get.find<AuthService>();
  // UserService'i put ile ekliyoruz ki hafızada oluşsun
  final UserService _userService = Get.put(UserService());

  // Depolama ve Input Kontrolcüleri
  final _storage = const FlutterSecureStorage();
  final TextEditingController apiKeyController = TextEditingController();

  // --- UI GÜNCELLEYEN DEĞİŞKENLER (OBS) ---
  var id = 0.obs;
  var username = "...".obs;
  var email = "...".obs;
  var fullName = "...".obs;

  // İstatistikler
  var totalTasks = 0.obs;
  var completedTasks = 0.obs;
  var friendsCount = 0.obs;

  // Kırmızı nokta (Bildirim)
  var hasPendingRequests = false.obs;

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Controller başlar başlamaz veriyi çek
    print("📢 ProfileController Başlatıldı. Veriler çekiliyor...");
    loadUserProfile();
  }

  // --- 1. PROFİL BİLGİLERİNİ ÇEK ---
  void loadUserProfile() async {
    isLoading.value = true;

    UserProfile? profile = await _userService.getMyProfile();

    if (profile != null) {
      id.value = profile.id;
      username.value = profile.username;
      email.value = profile.email;
      fullName.value = profile.fullName ?? "";
      totalTasks.value = profile.totalTasks;
      completedTasks.value = profile.completedTasks;
      friendsCount.value = profile.friendsCount;

      // --- SENKRONİZASYON (KRİTİK) ---
      // Backend'den key geldiyse, yerel hafızayı güncelle
      if (profile.geminiApiKey != null && profile.geminiApiKey!.isNotEmpty) {
        print("✅ Backend'den API Key geldi, hafızaya yazılıyor: ${profile.geminiApiKey}");
        await _storage.write(key: 'gemini_api_key', value: profile.geminiApiKey);
      } else {
        print("⚠️ Backend'de API Key YOK (null).");
      }
      // -------------------------------
    }

    isLoading.value = false;
  }

  // --- 2. API KEY EKLEME DİYALOĞU ---
  void showApiKeyDialog() {


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
      textConfirm: "Sunucuya Kaydet",
      textCancel: "İptal",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF1E3C72),
      onConfirm: () async {
        if (apiKeyController.text.isEmpty) {
          Get.snackbar("Hata", "Lütfen bir anahtar girin.");
          return;
        }

        print("🖱️ Butona basıldı. Service çağrılıyor...");

        // 1. Önce servise gönderiyoruz ve cevabı BEKLİYORUZ (await)
        bool success = await _userService.updateProfile(
            apiKey: apiKeyController.text.trim()
        );

        print("🔙 Controller'a dönen sonuç: $success");

        if (success) {
          Get.back(); // Diyaloğu kapat

          // 2. Sadece sunucu kabul ederse yerel hafızaya yaz
          await _storage.write(key: 'gemini_api_key', value: apiKeyController.text.trim());

          Get.snackbar("Başarılı", "Anahtar sunucuya kaydedildi! ✅",
              backgroundColor: Colors.green, colorText: Colors.white);

          // Profili yenile ki her şey güncellensin
          loadUserProfile();
        } else {
          Get.snackbar("Hata", "Sunucuya bağlanılamadı veya hata oluştu.",
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      },
    );
  }
  // --- 3. PROFİL BİLGİLERİNİ GÜNCELLE (İsim & Email) ---
  Future<void> updateMyProfile(String newName, String newEmail) async {
    isLoading.value = true;

    // Sadece isim ve mail gönderiyoruz
    bool success = await _userService.updateProfile(fullName: newName, email: newEmail);

    isLoading.value = false;

    if (success) {
      Get.back(); // Sayfayı kapat
      Get.snackbar("Başarılı", "Profil bilgileriniz güncellendi",
          backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.bottom);

      // Ekrandaki verileri tazele
      loadUserProfile();
    } else {
      Get.snackbar("Hata", "Güncelleme başarısız oldu.",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // --- 4. ÇIKIŞ YAP ---
  void logout() async {
    Get.defaultDialog(
      title: "Çıkış Yap",
      middleText: "Hesabınızdan çıkış yapmak istediğinize emin misiniz?",
      textConfirm: "Evet, Çık",
      textCancel: "İptal",
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