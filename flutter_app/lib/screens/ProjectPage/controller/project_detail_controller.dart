// lib/controllers/project_detail_controller.dart

import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:intl/intl.dart'; // Tarih formatı için
import '../../../models/project.dart';
import '../../../models/task.dart';
import '../../../services/project_service.dart';


class ProjectDetailController extends GetxController {
  final Project project;
  ProjectDetailController(this.project);

  final ProjectService _service = Get.find<ProjectService>();

  var tasks = <Task>[].obs;
  var isLoading = false.obs;

  // --- FORM DEĞİŞKENLERİ ---
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  var selectedDate = DateTime.now().obs;
  var selectedTime = TimeOfDay.now().obs;
  var selectedPriority = "medium".obs;

  @override
  void onInit() {
    super.onInit();
    fetchProjectTasks();
  }

  void fetchProjectTasks() async {
    isLoading.value = true;
    tasks.value = await _service.getProjectTasks(project.id);
    isLoading.value = false;
  }

  // --- TARİH VE SAAT SEÇİCİLER (Add Task ile aynı mantık) ---
  void pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) selectedDate.value = picked;
  }

  void pickTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime.value,
    );
    if (picked != null) selectedTime.value = picked;
  }

  void setPriority(String p) => selectedPriority.value = p;

  // --- KAYDET ---
  void saveTask() async {
    if (titleCtrl.text.isEmpty) {
      Get.snackbar("Uyarı", "Başlık boş olamaz");
      return;
    }

    // Tarih birleştir
    final dt = selectedDate.value;
    final t = selectedTime.value;
    final finalDate = DateTime(dt.year, dt.month, dt.day, t.hour, t.minute);

    Task newTask = Task(
        title: titleCtrl.text,
        description: descCtrl.text,
        priority: selectedPriority.value,
        dueDate: finalDate,
        status: "Yapılacak"
    );

    Get.back(); // Formu kapat

    bool success = await _service.addProjectTask(project.id, newTask);

    if (success) {
      Get.snackbar("Başarılı", "Görev projeye eklendi", backgroundColor: Colors.green, colorText: Colors.white);
      fetchProjectTasks(); // Listeyi yenile

      // Formu temizle
      titleCtrl.clear();
      descCtrl.clear();
    } else {
      Get.snackbar("Hata", "Görev eklenemedi");
    }
  }
}