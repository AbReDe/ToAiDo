// lib/controllers/project_detail_controller.dart

import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:intl/intl.dart';
import '../../../models/friend_model.dart';
import '../../../models/project.dart';
import '../../../models/task.dart';
import '../../../services/friend_service.dart';
import '../../../services/project_service.dart';
import '../../profil_page/profile_controller.dart';


class ProjectDetailController extends GetxController {
  final Project project;

  // Dependency Injection ile servisleri alıyoruz
  final ProjectService _projectService = Get.find<ProjectService>();
  final FriendService _friendService = Get.put(FriendService());

  ProjectDetailController(this.project);

  // --- Gözlemlenebilir Değişkenler ---
  var tasks = <Task>[].obs;
  var friends = <Friend>[].obs; // Davet listesi için
  var isLoading = false.obs;
  var currentUserId = 0.obs; // Giriş yapan kullanıcının ID'si

  // --- Görev Ekleme Formu Değişkenleri ---
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
  var selectedDate = DateTime.now().obs;
  var selectedTime = TimeOfDay.now().obs;
  var selectedPriority = "medium".obs;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUser(); // Önce kim olduğumuzu öğrenelim
    fetchProjectTasks();
    loadFriends();
  }

  // 1. Kendi ID'mizi ProfileController'dan alıyoruz
  void _loadCurrentUser() {
    if (Get.isRegistered<ProfileController>()) {
      try {
        // --- DÜZELTİLEN SATIR ---
        // .id (RxInt) olduğu için sonuna .value ekliyoruz
        currentUserId.value = Get.find<ProfileController>().id.value;
        // ------------------------
      } catch (e) {
        print("Kullanıcı ID alınamadı: $e");
      }
    }
  }

  // 2. Proje Görevlerini Çek
  void fetchProjectTasks() async {
    isLoading.value = true;
    tasks.value = await _projectService.getProjectTasks(project.id);
    isLoading.value = false;
  }

  // 3. Arkadaş Listesini Çek (Davet için)
  void loadFriends() async {
    friends.value = await _friendService.getFriends();
  }

  // 4. Görev Durumu Güncelle (Al / Bırak / Bitir)
  void handleTaskAction(Task task, String action) async {
    // action: 'assign', 'unassign', 'complete'
    bool success = await _projectService.updateTaskState(task.id!, action);

    if (success) {
      fetchProjectTasks(); // Listeyi yenile

      String message = "";
      if (action == "assign") message = "Görevi üstlendiniz!";
      if (action == "unassign") message = "Görevi bıraktınız.";
      if (action == "complete") message = "Tebrikler! Görev tamamlandı.";

      Get.snackbar("Başarılı", message,
          backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.bottom);
    } else {
      Get.snackbar("Hata", "İşlem gerçekleştirilemedi",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  // 5. Arkadaş Davet Et
  void inviteFriend(String username) async {
    Get.back(); // Diyaloğu kapat
    bool success = await _projectService.inviteMember(project.id, username);
    if (success) {
      Get.snackbar("Davet Gönderildi", "$username projeye eklendi!",
          backgroundColor: Colors.black87, colorText: Colors.white);
    } else {
      Get.snackbar("Hata", "Kullanıcı eklenemedi veya zaten ekli",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  // --- GÖREV EKLEME FONKSİYONLARI ---

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

  void saveTask() async {
    if (titleCtrl.text.isEmpty) {
      Get.snackbar("Uyarı", "Görev başlığı boş olamaz", snackPosition: SnackPosition.bottom);
      return;
    }

    Get.back(); // Paneli kapat
    isLoading.value = true;

    // Tarih birleştirme
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

    bool success = await _projectService.addProjectTask(project.id, newTask);

    if (success) {
      fetchProjectTasks(); // Yenile
      titleCtrl.clear();
      descCtrl.clear();
      Get.snackbar("Başarılı", "Görev projeye eklendi", backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      Get.snackbar("Hata", "Görev eklenemedi", backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
    isLoading.value = false;
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    super.onClose();
  }
}