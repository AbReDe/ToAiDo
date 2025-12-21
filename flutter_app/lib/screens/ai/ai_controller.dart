import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_x/get.dart';

import '../../models/chat_message_model.dart';
import '../../models/user_profile_model.dart';
import '../../services/ai_service.dart';
import '../../services/user_service.dart'; // <-- Eklendi


class AIController extends GetxController {
  final AIService _service = Get.put(AIService());
  final _storage = const FlutterSecureStorage(); // <-- Depolama eklendi

  final TextEditingController textCtrl = TextEditingController();
  final ScrollController scrollCtrl = ScrollController();
  final UserService _userService = Get.put(UserService());

  var messages = <ChatMessage>[].obs;
  var isLoading = false.obs;
  var isChatMode = true.obs;

  // API Key var mı yok mu takip edelim
  var hasApiKey = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Ekran açılınca kontrol et
    checkApiKeyAndWelcome();
  }

  // --- API KEY KONTROLÜ VE KARŞILAMA ---
  void checkApiKeyAndWelcome() async {
    // 1. Önce Profili Çekiyoruz (Veritabanına bakıyoruz)
    UserProfile? profile = await _userService.getMyProfile();

    // 2. Profilde key var mı?
    if (profile != null && profile.geminiApiKey != null && profile.geminiApiKey!.isNotEmpty) {
      hasApiKey.value = true;
      // Key'i servisin kullanabilmesi için yerel hafızaya geri yazalım (Caching)
      // Bu sayede AI Service her seferinde profile gitmek zorunda kalmaz
      await _storage.write(key: 'gemini_api_key', value: profile.geminiApiKey);

      messages.add(ChatMessage(
        text: "Merhaba ${profile.username}! 🧠\nAPI Anahtarın doğrulandı. Sana nasıl yardımcı olabilirim?",
        isUser: false,
        time: DateTime.now(),
      ));
    }
    else {
      // Key Yoksa
      hasApiKey.value = false;
      await _storage.delete(key: 'gemini_api_key'); // Varsa sil

      messages.add(ChatMessage(
        text: "Merhaba! 👋\n\n⚠️ Sistemde kayıtlı API Anahtarın bulunamadı.\nLütfen 'AI API Ayarları' butonuna basarak anahtarını kaydet.",
        isUser: false,
        time: DateTime.now(),
      ));

      // Otomatik açılması yerine kullanıcı butona bassın (Daha az rahatsız edici)
    }
  }

  // --- API KEY GİRME DİYALOĞU ---
  void showApiKeyDialog() {
    final TextEditingController keyInput = TextEditingController();

    Get.defaultDialog(
      title: "API Anahtarı",
      content: Column(
        children: [
          const Text("Gemini API Anahtarını gir ve sunucuya kaydet.", textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
          const SizedBox(height: 10),
          TextField(
            controller: keyInput,
            decoration: const InputDecoration(labelText: "API Key", border: OutlineInputBorder()),
          ),
        ],
      ),
      textConfirm: "Kaydet",
      textCancel: "İptal",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF1E3C72),
      onConfirm: () async {
        if (keyInput.text.isNotEmpty) {
          Get.back(); // Diyaloğu kapat

          // Sunucuya Kaydet (UserService kullanıyoruz)
          bool success = await _userService.updateProfile(
              apiKey: keyInput.text.trim()
          );

          if (success) {
            hasApiKey.value = true;
            // Yerel hafızaya da yazalım ki anında kullanılsın
            await _storage.write(key: 'gemini_api_key', value: keyInput.text.trim());

            Get.snackbar("Başarılı", "Anahtar sunucuya ve cihaza kaydedildi! ✅",
                backgroundColor: Colors.green, colorText: Colors.white);

            messages.add(ChatMessage(text: "Anahtar kaydedildi! Hazırım. 🚀", isUser: false, time: DateTime.now()));
          } else {
            Get.snackbar("Hata", "Sunucuya kaydedilemedi.");
          }
        }
      },
    );
  }

  // --- MOD DEĞİŞTİRME ---
  void switchMode(bool chatMode) {
    isChatMode.value = chatMode;
  }

  // --- MESAJ GÖNDERME ---
  void sendMessage() async {
    String msg = textCtrl.text.trim();
    if (msg.isEmpty) return;

    messages.add(ChatMessage(text: msg, isUser: true, time: DateTime.now()));
    textCtrl.clear();
    _scrollToBottom();

    isLoading.value = true;

    // Servise gönder
    String? response = await _service.sendMessage(msg);

    isLoading.value = false;

    messages.add(ChatMessage(
        text: response ?? "Hata oluştu.",
        isUser: false,
        time: DateTime.now()
    ));
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollCtrl.hasClients) {
        scrollCtrl.animateTo(
          scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}