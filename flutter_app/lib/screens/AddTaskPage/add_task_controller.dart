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

  var selectedDate = DateTime.now().obs;
  var selectedTime = TimeOfDay.now().obs;
  var selectedPriority = "medium".obs;
  var isLoading = false.obs;

  // --- EKSİK OLAN FONKSİYONLAR GERİ GELDİ ---

  // 1. Tarih Seçici
  void pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
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
    if (picked != null) selectedDate.value = picked;
  }

  // 2. Saat Seçici
  void pickTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime.value,
    );
    if (picked != null) selectedTime.value = picked;
  }

  // 3. Öncelik Ayarlayıcı
  void setPriority(String priority) {
    selectedPriority.value = priority;
  }

  // --- KAYDETME İŞLEMİ ---
  void saveTask() async {
    if (titleController.text.isEmpty) {
      Get.snackbar("Hata", "Başlık boş olamaz", snackPosition: SnackPosition.bottom, backgroundColor: Colors.orange);
      return;
    }

    isLoading.value = true;

    // Tarih ve Saati Birleştir
    final dt = selectedDate.value;
    final t = selectedTime.value;
    final DateTime finalDateTime = DateTime(dt.year, dt.month, dt.day, t.hour, t.minute);

    // Yeni Task Modeli
    Task newTask = Task(
      title: titleController.text,
      description: descController.text,
      status: "Yapılacak",
      priority: selectedPriority.value,
      dueDate: finalDateTime,
    );

    // Servise Gönder
    bool success = await _taskService.createTask(newTask);

    isLoading.value = false;

    if (success) {
      Get.back(); // Sayfayı kapat
      Get.snackbar("Başarılı", "Görev kaydedildi!", backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.bottom);

      // Listeyi yenile
      _homeController.fetchAllTasks();
    } else {
      Get.snackbar("Hata", "Görev kaydedilemedi", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descController.dispose();
    super.onClose();
  }
}