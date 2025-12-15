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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Yeni Görev",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BAŞLIK BAŞLIĞI ---
            const Text("Başlık", style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: controller.titleController,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: "Örn: Backend API Tasarımı",
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- AÇIKLAMA ---
            const Text("Açıklama (Opsiyonel)", style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: controller.descController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Detayları buraya yaz...",
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- TARİH VE SAAT SEÇİMİ (Yan Yana) ---
            Row(
              children: [
                // Tarih Kısmı
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Tarih", style: TextStyle(color: Colors.grey, fontSize: 14)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => controller.pickDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, color: Color(0xFF1E3C72), size: 20),
                              const SizedBox(width: 8),
                              Obx(() => Text(
                                DateFormat('dd/MM/yyyy').format(controller.selectedDate.value),
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Saat Kısmı
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Saat", style: TextStyle(color: Colors.grey, fontSize: 14)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => controller.pickTime(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, color: Color(0xFF1E3C72), size: 20),
                              const SizedBox(width: 8),
                              Obx(() => Text(
                                controller.selectedTime.value.format(context),
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- ÖNCELİK (PRIORITY) ---
            const Text("Öncelik", style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 12),
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPriorityChip("Düşük", "low", Colors.green),
                _buildPriorityChip("Orta", "medium", Colors.orange),
                _buildPriorityChip("Yüksek", "high", Colors.redAccent),
              ],
            )),

            const SizedBox(height: 40),

            // --- OLUŞTUR BUTONU ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3C72),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                ),
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "GÖREV OLUŞTUR",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }

  // Öncelik Butonu Widget'ı
  Widget _buildPriorityChip(String label, String value, Color color) {
    bool isSelected = controller.selectedPriority.value == value;
    return GestureDetector(
      onTap: () => controller.setPriority(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 0 : 1.5,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}