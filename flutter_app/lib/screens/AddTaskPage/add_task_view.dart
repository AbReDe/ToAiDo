// lib/views/add_task_view.dart

import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:intl/intl.dart';
import 'add_task_controller.dart';

class AddTaskView extends StatelessWidget {
  final AddTaskController controller = Get.put(AddTaskController());

  AddTaskView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Yeni Görev", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BAŞLIK
            const Text("Başlık", style: TextStyle(color: Colors.grey)),
            TextField(
              controller: controller.titleController,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(hintText: "Görev adı..."),
            ),
            const SizedBox(height: 20),

            // AÇIKLAMA
            const Text("Açıklama", style: TextStyle(color: Colors.grey)),
            TextField(
              controller: controller.descController,
              maxLines: 2,
              decoration: const InputDecoration(hintText: "Detaylar..."),
            ),
            const SizedBox(height: 20),

            // ETİKETLER (TAG)
            const Text("Etiketler (Tag)", style: TextStyle(color: Colors.grey)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.tagController,
                    decoration: const InputDecoration(hintText: "Örn: yazılım, spor..."),
                    onSubmitted: (_) => controller.addTag(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Color(0xFF1E3C72)),
                  onPressed: controller.addTag,
                )
              ],
            ),
            const SizedBox(height: 10),
            Obx(() => Wrap(
              spacing: 8,
              children: controller.tags.map((tag) => Chip(
                label: Text("#$tag"),
                backgroundColor: Colors.blue.shade50,
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => controller.removeTag(tag),
              )).toList(),
            )),

            const SizedBox(height: 20),

            // ZAMAN VE TEKRAR
            Row(
              children: [
                // Tarih ve Saat
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Zaman", style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 10,
                        children: [
                          // Tarih Seçici
                          Obx(() {
                            bool isRepeat = controller.selectedRepeat.value != "none";
                            return ActionChip(
                              avatar: Icon(Icons.calendar_today, size: 16, color: isRepeat ? Colors.grey : const Color(0xFF1E3C72)),
                              label: Text(
                                isRepeat ? "Bugünden başla" : DateFormat('dd/MM').format(controller.selectedDate.value),
                                style: TextStyle(color: isRepeat ? Colors.grey : Colors.black),
                              ),
                              onPressed: isRepeat ? null : () => controller.pickDate(context),
                            );
                          }),
                          // Saat Seçici
                          ActionChip(
                            avatar: const Icon(Icons.access_time, size: 16, color: Color(0xFF1E3C72)),
                            label: Obx(() => Text(controller.selectedTime.value.format(context))),
                            onPressed: () => controller.pickTime(context),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // --- TEKRAR SEÇİMİ (BURASI EKSİKTİ, EKLENDİ) ---
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Tekrar", style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 5),
                      Obx(() => DropdownButtonFormField<String>(
                        value: controller.selectedRepeat.value,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: "none", child: Text("Yok", style: TextStyle(fontSize: 13))),
                          DropdownMenuItem(value: "daily", child: Text("Her Gün", style: TextStyle(fontSize: 13))),
                          DropdownMenuItem(value: "weekly", child: Text("Haftalık", style: TextStyle(fontSize: 13))),
                        ],
                        onChanged: controller.setRepeat,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ÖNCELİK
            const Text("Öncelik", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _priorityOption("Düşük", "low", Colors.green),
                _priorityOption("Orta", "medium", Colors.orange),
                _priorityOption("Yüksek", "high", Colors.redAccent),
              ],
            )),

            const SizedBox(height: 40),

            // KAYDET BUTONU
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.saveTask,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3C72)),
                child: const Text("GÖREVİ KAYDET", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priorityOption(String label, String value, Color color) {
    bool isSelected = controller.selectedPriority.value == value;
    return GestureDetector(
      onTap: () => controller.setPriority(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          border: Border.all(color: isSelected ? color : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
      ),
    );
  }
}