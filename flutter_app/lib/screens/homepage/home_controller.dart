// lib/controllers/home_controller.dart


import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/task.dart';
import '../../services/task_service.dart'; // Tarih karşılaştırması için


class HomeController extends GetxController {
  final TaskService _taskService = Get.put(TaskService());

  var selectedDate = DateTime.now().obs;
  var focusedDate = DateTime.now().obs;
  var selectedIndex = 0.obs;

  // Task Model Listesi (Artık Map değil, Task sınıfı kullanıyoruz)
  var taskList = <Task>[].obs;
  var isLoading = false.obs;

  // Tüm görevleri tutan ana havuz (Serverdan hepsini bir kere çekip, tarihe göre filtreleriz)
  var _allTasks = <Task>[];

  @override
  void onInit() {
    super.onInit();
    fetchAllTasks(); // Uygulama açılınca verileri çek
  }

  // --- API'DEN GÖREVLERİ ÇEK ---
  void fetchAllTasks() async {
    isLoading.value = true;
    _allTasks = await _taskService.getTasks();
    filterTasksByDate(selectedDate.value); // Seçili güne göre filtrele
    isLoading.value = false;
  }

  // --- TARİHE GÖRE FİLTRELEME ---
  void filterTasksByDate(DateTime date) {
    // Backend'den gelen tarih ile seçilen tarihi karşılaştır
    taskList.value = _allTasks.where((task) {
      if (task.dueDate == null) return false;
      return isSameDay(task.dueDate!, date);
    }).toList();
  }

  void onDaySelected(DateTime selected, DateTime focused) {
    selectedDate.value = selected;
    focusedDate.value = focused;
    filterTasksByDate(selected); // Tekrar istek atma, elindekileri filtrele
  }

  // --- DURUM GÜNCELLEME (TOGGLE) ---
  void toggleTaskStatus(int index) async {
    var task = taskList[index];
    String newStatus = task.status == "Tamamlandı" ? "Yapılacak" : "Tamamlandı";

    // 1. Önce UI'da hızlıca güncelle (Kullanıcı beklemesin)
    // Task sınıfı 'final' olduğu için kopyasını oluşturup değiştirmeliyiz (veya modeli final yapmayabilirsin)
    // Şimdilik listeyi yeniden çekelim, en temizi:

    bool success = await _taskService.updateTaskStatus(task.id!, newStatus);
    if(success) {
      fetchAllTasks(); // Verileri tazeleyelim
    }
  }

  // --- GÖREV SİLME ---
  void deleteTask(int index) async {
    var task = taskList[index];
    bool success = await _taskService.deleteTask(task.id!);

    if (success) {
      taskList.removeAt(index);
      Get.snackbar("Silindi", "Görev başarıyla silindi", snackPosition: SnackPosition.bottom);
      // Arkaplanda ana listeyi de güncelle
      fetchAllTasks();
    }
  }

  void changeTabIndex(int index) => selectedIndex.value = index;
}