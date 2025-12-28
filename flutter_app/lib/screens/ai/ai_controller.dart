import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_x/get.dart';

import '../../models/chat_message_model.dart';
import '../../models/task.dart';
import '../../models/user_profile_model.dart';
import '../../services/ai_service.dart';
import '../../services/task_service.dart';
import '../../services/user_service.dart';
import '../homepage/home_controller.dart'; // <-- Eklendi
import 'package:intl/intl.dart'; // Tarih formatı için


class AIController extends GetxController {
  final AIService _service = Get.put(AIService());
  final UserService _userService = Get.put(UserService());
  final TaskService _taskService = Get.put(TaskService()); // <-- Eklendi
  final _storage = const FlutterSecureStorage();

  final TextEditingController textCtrl = TextEditingController(); // Sohbet için
  final TextEditingController topicCtrl = TextEditingController(); // Görev konusu için
  final ScrollController scrollCtrl = ScrollController();

  var messages = <ChatMessage>[].obs;

  // --- YENİ: ÖNERİLEN GÖREVLER LİSTESİ ---
  var generatedSuggestions = <String>[].obs;
  // ---------------------------------------

  var isLoading = false.obs;
  var isChatMode = true.obs;
  var hasApiKey = false.obs;

  @override
  void onInit() {
    super.onInit();
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


  // --- 1. GÖREVLERİ OLUŞTUR (AI'dan İste) ---
  void generateTasks() async {
    String topic = topicCtrl.text.trim();
    if (topic.isEmpty) {
      Get.snackbar("Uyarı", "Lütfen bir konu girin (Örn: Python Öğrenmek)");
      return;
    }

    // Klavyeyi kapat
    FocusManager.instance.primaryFocus?.unfocus();

    isLoading.value = true;
    generatedSuggestions.clear(); // Eski listeyi temizle

    try {
      // Servisteki generate fonksiyonunu çağır (Servisi güncellememiz gerekecek, aşağıda yazdım)
      // Şimdilik servisin döndüğü List<String>'i alıyoruz
      List<String> results = await _service.generateTaskSuggestions(topic);
      generatedSuggestions.value = results;

      if(results.isEmpty) {
        Get.snackbar("Bilgi", "Öneri bulunamadı veya bir hata oluştu.");
      }
    } catch (e) {
      Get.snackbar("Hata", "AI bağlantısında sorun: $e");
    } finally {
      isLoading.value = false;
    }
  }


  void addTaskToSystem(String title) async {
    // 1. Tarih Seçtir
    DateTime? pickedDate = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF1E3C72),
            colorScheme: const ColorScheme.light(primary: Color(0xFF1E3C72)),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return; // İptal etti

    // 2. Task Modelini Oluştur
    // Saat olarak şu anı verelim veya sabah 09:00 yapalım
    final DateTime finalDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, 9, 0);

    Task newTask = Task(
      title: title,
      description: "AI tarafından oluşturuldu",
      priority: "medium",
      status: "Yapılacak",
      dueDate: finalDate,
      repeat: "none",
      tags: ["AI"],
    );

    // 3. Servise Gönder
    Get.snackbar("Kaydediliyor", "$title ekleniyor...", showProgressIndicator: true);

    bool success = await _taskService.createTask(newTask);

    if (success) {
      // Listeden sil ki tekrar eklenmesin (Opsiyonel)
      generatedSuggestions.remove(title);

      // Home Controller'ı yenile
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fetchAllTasks();
      }

      Get.back(); // Snackbar kapat
      Get.snackbar("Başarılı", "Görev ${DateFormat('dd/MM').format(finalDate)} tarihine eklendi!",
          backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      Get.snackbar("Hata", "Kaydedilemedi.");
    }
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