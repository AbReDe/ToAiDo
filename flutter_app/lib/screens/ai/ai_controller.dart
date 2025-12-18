import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_x/get.dart';

import '../../models/chat_message_model.dart';
import '../../services/ai_service.dart'; // <-- Eklendi


class AIController extends GetxController {
  final AIService _service = Get.put(AIService());
  final _storage = const FlutterSecureStorage(); // <-- Depolama eklendi

  final TextEditingController textCtrl = TextEditingController();
  final ScrollController scrollCtrl = ScrollController();

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
    String? key = await _storage.read(key: 'gemini_api_key');

    if (key == null || key.isEmpty) {
      hasApiKey.value = false;

      // 1. Önce kullanıcıya uyarı mesajı ekle
      messages.add(ChatMessage(
        text: "Merhaba! 👋 Ben ToAiDo Asistan.\n\n⚠️ Şu an API Anahtarın girili değil. Bu yüzden sadece basit (Mock) cevaplar verebilirim.\n\nGerçek yapay zeka deneyimi için lütfen API anahtarını gir.",
        isUser: false,
        time: DateTime.now(),
      ));

      // 2. Otomatik olarak API Key girme penceresini aç
      Future.delayed(const Duration(milliseconds: 500), () {
        showApiKeyDialog();
      });

    } else {
      hasApiKey.value = true;
      messages.add(ChatMessage(
        text: "Merhaba! Ben ToAiDo Asistan. 🧠\nGemini AI aktif. Sana nasıl yardımcı olabilirim?",
        isUser: false,
        time: DateTime.now(),
      ));
    }
  }

  // --- API KEY GİRME DİYALOĞU ---
  void showApiKeyDialog() {
    final TextEditingController keyInput = TextEditingController();

    Get.defaultDialog(
        title: "API Anahtarı Gerekli",
        titleStyle: const TextStyle(color: Color(0xFF1E3C72), fontWeight: FontWeight.bold),
        content: Column(
          children: [
            const Icon(Icons.vpn_key, size: 40, color: Colors.orangeAccent),
            const SizedBox(height: 10),
            const Text(
              "Yapay zekayı tam kapasite kullanmak için Google Gemini API anahtarınızı giriniz.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: keyInput,
              decoration: const InputDecoration(
                labelText: "API Key Yapıştır",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () async {
                // Google AI Studio linkini açmak için url_launcher kullanılabilir
                // Şimdilik sadece bilgi verelim
                Get.snackbar("Bilgi", "aistudio.google.com adresinden ücretsiz alabilirsiniz.",
                    backgroundColor: Colors.black87, colorText: Colors.white, snackPosition: SnackPosition.top);
              },
              child: const Text("Anahtarım yok, nasıl alırım?", style: TextStyle(fontSize: 12)),
            )
          ],
        ),
        textConfirm: "Kaydet",
        textCancel: "Daha Sonra",
        confirmTextColor: Colors.white,
        buttonColor: const Color(0xFF1E3C72),
        onConfirm: () async {
          if (keyInput.text.isNotEmpty) {
            await _storage.write(key: 'gemini_api_key', value: keyInput.text.trim());
            hasApiKey.value = true;
            Get.back(); // Diyaloğu kapat

            Get.snackbar("Süper!", "API Anahtarı kaydedildi. Artık yapay zeka aktif! 🚀",
                backgroundColor: Colors.green, colorText: Colors.white);

            // Teşekkür mesajı ekle
            messages.add(ChatMessage(
                text: "Teşekkürler! Anahtar kaydedildi. Artık her şeyi sorabilirsin. 🚀",
                isUser: false,
                time: DateTime.now()
            ));
          } else {
            Get.snackbar("Hata", "Lütfen geçerli bir anahtar girin.", backgroundColor: Colors.red, colorText: Colors.white);
          }
        },
        onCancel: () {
          // İptal ederse Mock modda devam edebilir
          Get.snackbar("Uyarı", "Mock (Taklit) modunda devam ediliyor.", backgroundColor: Colors.orange, colorText: Colors.white);
        }
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