// lib/controllers/add_task_controller.dart

import 'package:flutter/material.dart';
import 'package:get_x/get.dart';

import '../../models/task.dart';
import '../../services/task_service.dart';
import '../homepage/home_controller.dart';

class AddTaskController extends GetxController {
  final TaskService _taskService = Get.find<TaskService>();
  final HomeController _homeController = Get.find<HomeController>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  // Tag için controller
  final TextEditingController tagController = TextEditingController();

  var selectedDate = DateTime.now().obs;
  var selectedTime = TimeOfDay.now().obs;
  var selectedPriority = "medium".obs;

  // --- YENİ DEĞİŞKENLER ---
  var selectedRepeat = "none".obs; // none, daily, weekly, monthly
  var tags = <String>[].obs; // Eklenen tagler listesi
  // ------------------------

  var isLoading = false.obs;

  // --- TAG İŞLEMLERİ ---
  void addTag() {
    String tag = tagController.text.trim();
    if (tag.isNotEmpty && !tags.contains(tag)) {
      tags.add(tag);
      tagController.clear();
    }
  }

  void removeTag(String tag) {
    tags.remove(tag);
  }

  // --- TARİH/SAAT/ÖNCELİK (Mevcut kodlar - Kısa tutuyorum) ---
  void pickDate(BuildContext context) async { /* ... Aynı kalsın ... */ }
  void pickTime(BuildContext context) async { /* ... Aynı kalsın ... */ }
  void setPriority(String p) => selectedPriority.value = p;

  // --- TEKRAR SEÇİMİ ---
  void setRepeat(String? val) {
    if(val != null) selectedRepeat.value = val;
  }

  // --- KAYDET ---
  void saveTask() async {
    if (titleController.text.isEmpty) {
      Get.snackbar("Uyarı", "Başlık giriniz");
      return;
    }

    isLoading.value = true;

    // Tarih birleştir
    final dt = selectedDate.value;
    final t = selectedTime.value;
    final finalDate = DateTime(dt.year, dt.month, dt.day, t.hour, t.minute);

    Task newTask = Task(
      title: titleController.text,
      description: descController.text,
      priority: selectedPriority.value,
      dueDate: finalDate,
      status: "Yapılacak",
      // Yeni alanlar
      repeat: selectedRepeat.value,
      tags: tags.toList(),
    );

    bool success = await _taskService.createTask(newTask);
    isLoading.value = false;

    if (success) {
      Get.back();
      Get.snackbar("Başarılı", "Görev eklendi!", backgroundColor: Colors.green, colorText: Colors.white);
      _homeController.fetchAllTasks();
    } else {
      Get.snackbar("Hata", "Eklenemedi");
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descController.dispose();
    tagController.dispose();
    super.onClose();
  }
}