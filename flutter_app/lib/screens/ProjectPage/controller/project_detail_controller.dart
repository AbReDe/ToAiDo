// lib/controllers/project_detail_controller.dart

import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:intl/intl.dart';
import '../../../models/friend_model.dart';
import '../../../models/project.dart';
import '../../../models/projectmember.dart';
import '../../../models/task.dart';
import '../../../services/friend_service.dart';
import '../../../services/project_service.dart';
import '../../profil_page/profile_controller.dart';

class ProjectDetailController extends GetxController {
  final Project project;

  final ProjectService _projectService = Get.find<ProjectService>();
  final FriendService _friendService = Get.put(FriendService());

  ProjectDetailController(this.project);

  var tasks = <Task>[].obs;
  var friends = <Friend>[].obs;
  var members = <ProjectMember>[].obs;

  var isLoading = false.obs;
  var currentUserId = 0.obs;

  // --- SADECE SEÇİM DEĞİŞKENLERİ BURADA KALIYOR ---
  var selectedDate = DateTime.now().obs;
  var selectedTime = TimeOfDay.now().obs;
  var selectedPriority = "medium".obs;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUser();
    fetchProjectTasks();
    loadFriends();
    fetchMembers();
    fetchMembers();
  }

  void _loadCurrentUser() {
    if (Get.isRegistered<ProfileController>()) {
      try {
        currentUserId.value = Get.find<ProfileController>().id.value;
      } catch (e) {
        print("Kullanıcı ID alınamadı: $e");
      }
    }
  }

  void fetchProjectTasks() async {
    isLoading.value = true;
    try {
      tasks.value = await _projectService.getProjectTasks(project.id);
    } catch (e) {
      print("Görev çekme hatası: $e");
    }
    isLoading.value = false;
  }

  void loadFriends() async {
    try {
      friends.value = await _friendService.getFriends();
    } catch (e) {
      print("Arkadaş listesi hatası: $e");
    }
  }

  Future<void> fetchMembers() async {
    try {
      var list = await _projectService.getProjectMembers(project.id);
      members.value = list;
    } catch (e) {
      print("Üye çekme hatası: $e");
    }
  }

  void handleTaskAction(Task task, String action) async {
    bool success = await _projectService.updateTaskState(task.id!, action);
    if (success) {
      fetchProjectTasks();
      Get.snackbar("Başarılı", "İşlem gerçekleştirildi", backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.bottom);
    } else {
      Get.snackbar("Hata", "İşlem yapılamadı", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.bottom);
    }
  }

  void inviteFriend(String username) async {
    Get.back();
    bool success = await _projectService.inviteMember(project.id, username);
    if (success) {
      Get.snackbar("Davet Gönderildi", "$username projeye davet edildi!", backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.bottom);
    } else {
      Get.snackbar("Hata", "Kullanıcı zaten ekli veya bulunamadı", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.bottom);
    }
  }

  // --- TARİH VE SAAT SEÇİMİ ---
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

  void pickTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime.value,
    );
    if (picked != null) selectedTime.value = picked;
  }

  void setPriority(String p) => selectedPriority.value = p;

  // --- GÖREV KAYDETME (ARTIK PARAMETRE ALIYOR) ---
  // Controller'ları buradan sildik, View'dan string olarak gelecekler
  void saveTask(String title, String description) async {
    if (title.isEmpty) {
      Get.snackbar("Uyarı", "Görev başlığı boş olamaz", snackPosition: SnackPosition.bottom);
      return;
    }

    Get.back(); // Paneli kapat

    isLoading.value = true;

    final dt = selectedDate.value;
    final t = selectedTime.value;
    final finalDate = DateTime(dt.year, dt.month, dt.day, t.hour, t.minute);

    Task newTask = Task(
        title: title,
        description: description,
        priority: selectedPriority.value,
        dueDate: finalDate,
        status: "Yapılacak"
    );

    bool success = await _projectService.addProjectTask(project.id, newTask);

    // Sayfa kapandıysa işlemi durdur
    if (isClosed) return;

    isLoading.value = false;

    if (success) {
      fetchProjectTasks();
      Get.snackbar("Başarılı", "Görev projeye eklendi", backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.bottom);
    } else {
      Get.snackbar("Hata", "Görev eklenemedi", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.bottom);
    }
  }
}