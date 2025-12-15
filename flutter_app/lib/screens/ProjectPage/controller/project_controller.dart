// lib/controllers/project_controller.dart

import 'package:flutter/material.dart';
import 'package:get_x/get.dart';

import '../../../models/project.dart';
import '../../../services/project_service.dart';

class ProjectController extends GetxController {
  // Servisi dependency injection ile alıyoruz
  final ProjectService _service = Get.put(ProjectService());

  var projectList = <Project>[].obs; // Ekranda gösterilecek liste
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProjects(); // Açılışta verileri çek
  }

  // Verileri Çek
  void fetchProjects() async {
    isLoading.value = true;
    projectList.value = await _service.getProjects();
    isLoading.value = false;
  }

  // --- YENİ PROJE EKLEME DİYALOĞU ---
  void showAddProjectDialog() {
    final TextEditingController nameCtrl = TextEditingController();
    final TextEditingController descCtrl = TextEditingController();

    Get.defaultDialog(
      title: "Yeni Proje",
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3C72)),
      content: Column(
        children: [
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(
              labelText: "Proje Adı",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: descCtrl,
            decoration: const InputDecoration(
              labelText: "Açıklama (Opsiyonel)",
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      textConfirm: "Oluştur",
      textCancel: "İptal",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF1E3C72),
      onConfirm: () async {
        if (nameCtrl.text.isNotEmpty) {
          Get.back(); // Diyaloğu kapat
          isLoading.value = true;

          bool success = await _service.createProject(nameCtrl.text, descCtrl.text);

          if (success) {
            Get.snackbar("Başarılı", "Proje oluşturuldu",
                backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.bottom);
            fetchProjects(); // Listeyi yenile
          } else {
            Get.snackbar("Hata", "Proje oluşturulamadı",
                backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.bottom);
          }
          isLoading.value = false;
        } else {
          Get.snackbar("Uyarı", "Proje adı boş olamaz", snackPosition: SnackPosition.bottom);
        }
      },
    );
  }

  // --- PROJE SİLME ---
  void deleteProject(int id) {
    Get.defaultDialog(
        title: "Projeyi Sil?",
        middleText: "Bu projeyi silmek istediğine emin misin?",
        textConfirm: "Evet, Sil",
        textCancel: "Vazgeç",
        confirmTextColor: Colors.white,
        buttonColor: Colors.redAccent,
        onConfirm: () async {
          Get.back(); // Diyaloğu kapat
          isLoading.value = true;
          bool success = await _service.deleteProject(id);

          if (success) {
            fetchProjects(); // Listeyi yenile
            Get.snackbar("Silindi", "Proje başarıyla silindi", snackPosition: SnackPosition.bottom);
          }
          isLoading.value = false;
        }
    );
  }
}