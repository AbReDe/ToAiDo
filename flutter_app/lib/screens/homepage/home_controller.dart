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
    taskList.value = _allTasks.where((task) {
      // 1. Tarih boşsa gösterme
      if (task.dueDate == null) return false;

      // 2. Normal Görev: Seçilen tarihle görevin tarihi aynı mı?
      bool isSameDate = isSameDay(task.dueDate!, date);

      // 3. Tekrarlı Görev Mantığı
      bool isRecurring = false;

      if (task.repeat == 'daily') {
        // Günlükse: Görevin başlangıç tarihi, seçilen tarihten önce veya aynıysa göster
        // (Gelecekte başlayacak bir görevi bugünden gösterme)
        if (task.dueDate!.isBefore(date) || isSameDay(task.dueDate!, date)) {
          isRecurring = true;
        }
      }
      else if (task.repeat == 'weekly') {
        // Haftalıkse: Haftanın günü (Pazartesi=1, Salı=2...) aynı mı?
        if ((task.dueDate!.isBefore(date) || isSameDay(task.dueDate!, date)) &&
            task.dueDate!.weekday == date.weekday) {
          isRecurring = true;
        }
      }

      // Sonuç: Ya tarihi tutacak YA DA tekrar kuralına uyacak
      return isSameDate || isRecurring;
    }).toList();
  }

  void onDaySelected(DateTime selected, DateTime focused) {
    selectedDate.value = selected;
    focusedDate.value = focused;
    filterTasksByDate(selected); // Tekrar istek atma, elindekileri filtrele
  }


  // GÖREV DURUMU DEĞİŞTİR
  void toggleTaskStatus(int index) async {
    var task = taskList[index];

    // Seçili tarihi string formatına çevir (Backend'in beklediği format: YYYY-MM-DD)
    String dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);

    // Servise gönder
    bool success = await _taskService.toggleTaskDate(task.id!, dateStr);

    if(success) {
      fetchAllTasks(); // Listeyi yenile ki güncel halini görelim
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