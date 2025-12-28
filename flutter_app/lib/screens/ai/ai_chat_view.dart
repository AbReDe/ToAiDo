import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:intl/intl.dart';
import '../../models/chat_message_model.dart';
import 'ai_controller.dart';

class AIChatView extends StatelessWidget {
  final AIController controller = Get.put(AIController());

  AIChatView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("AI Asistan", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E3C72),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // --- ÜST SEKMELER (SOHBET / GÖREV) ---
          Container(
            color: const Color(0xFF1E3C72),
            padding: const EdgeInsets.only(bottom: 15, left: 20, right: 20),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Obx(() => Row(
                children: [
                  _buildTabButton("Sohbet", true),
                  _buildTabButton("Görev Oluştur", false),
                ],
              )),
            ),
          ),

          // --- İÇERİK ALANI ---
          Expanded(
            child: Obx(() {
              // GÖREV MODU (GELECEKTE EKLENECEK)
              if (!controller.isChatMode.value) {
                return _buildTaskGenerator(context);
              }

              // SOHBET MODU
              return Column(
                children: [
                  // Mesaj Listesi
                  Expanded(
                    child: ListView.builder(
                      controller: controller.scrollCtrl,
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.messages.length,
                      itemBuilder: (context, index) {
                        return _buildMessageBubble(controller.messages[index]);
                      },
                    ),
                  ),

                  // Yükleniyor Göstergesi
                  if (controller.isLoading.value)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Yazıyor...", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                    ),

                  // Mesaj Yazma Alanı (TEK VE DOĞRU OLAN)
                  _buildInputArea(),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // --- WIDGETLAR ---

  Widget _buildTabButton(String text, bool isChat) {
    bool isSelected = controller.isChatMode.value == isChat;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.switchMode(isChat),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? const Color(0xFF1E3C72) : Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: Get.width * 0.75),
        decoration: BoxDecoration(
          color: msg.isUser ? const Color(0xFF1E3C72) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: msg.isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: msg.isUser ? Radius.zero : const Radius.circular(16),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: TextStyle(color: msg.isUser ? Colors.white : Colors.black87, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(msg.time),
              style: TextStyle(color: msg.isUser ? Colors.white70 : Colors.grey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  // --- İŞTE DÜZELTİLEN FONKSİYON (Tek Sefer Yazıldı) ---
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          // EĞER API KEY YOKSA ANAHTAR BUTONU GÖSTER
          Obx(() => !controller.hasApiKey.value
              ? IconButton(
            icon: const Icon(Icons.vpn_key_off, color: Colors.redAccent),
            onPressed: controller.showApiKeyDialog, // Diyaloğu tekrar açar
            tooltip: "API Key Gir",
          )
              : const SizedBox.shrink()
          ),

          Expanded(
            child: Obx(() => TextField(
              controller: controller.textCtrl,
              decoration: InputDecoration(
                hintText: controller.hasApiKey.value ? "Bir şeyler sor..." : "Mock modundasın...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onSubmitted: (_) => controller.sendMessage(),
            )),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: controller.sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: Color(0xFF1E3C72), shape: BoxShape.circle),
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskGenerator(BuildContext context) {
    return Column(
      children: [
        // 1. GİRİŞ ALANI
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Hedefin Nedir?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3C72)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller.topicCtrl,
                decoration: InputDecoration(
                  hintText: "Örn: 1 haftada Python öğrenmek",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.lightbulb_outline, color: Colors.orange),
                ),
              ),
              const SizedBox(height: 15),
              Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.generateTasks,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3C72),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Plan Oluştur", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              )),
            ],
          ),
        ),

        // 2. ÖNERİ LİSTESİ
        Expanded(
          child: Obx(() {
            if (controller.generatedSuggestions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.list_alt, size: 60, color: Colors.grey.shade300),
                    const SizedBox(height: 10),
                    const Text("Henüz bir plan oluşturulmadı.", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.generatedSuggestions.length,
              itemBuilder: (context, index) {
                String taskTitle = controller.generatedSuggestions[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade50,
                      child: const Icon(Icons.auto_awesome, color: Color(0xFF1E3C72), size: 20),
                    ),
                    title: Text(taskTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text("Tarih seçmek için butona basın"),
                    trailing: IconButton(
                      icon: const Icon(Icons.calendar_month, color: Colors.green, size: 30),
                      onPressed: () => controller.addTaskToSystem(taskTitle),
                      tooltip: "Takvime Ekle",
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}