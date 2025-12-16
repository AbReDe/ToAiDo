// lib/controllers/project_controller.dart

import 'package:flutter/material.dart';
import 'package:get_x/get.dart';

import '../../../models/project.dart';
import '../../../models/project_invitation_model.dart';
import '../../../services/project_service.dart';

class ProjectController extends GetxController {
  final ProjectService _service = Get.put(ProjectService());

  // Projeler ve Davetler Listesi
  var projectList = <Project>[].obs;
  var invitations = <ProjectInvitation>[].obs;

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProjects();     // Projelerimi getir
    fetchInvitations();  // Bana gelen davetleri getir
  }

  // 1. Projeleri Çek
  void fetchProjects() async {
    isLoading.value = true;
    projectList.value = await _service.getProjects();
    isLoading.value = false;
  }

  // 2. Davetleri Çek
  void fetchInvitations() async {
    invitations.value = await _service.getInvitations();
  }

  // 3. Daveti Cevapla (Kabul/Red)
  void respondToInvite(int id, bool accept) async {
    String action = accept ? "accept" : "reject";
    bool success = await _service.respondInvitation(id, action);

    if (success) {
      fetchInvitations(); // Davet listesini temizle
      if (accept) fetchProjects(); // Kabul ettiysem projeyi listeye ekle
      Get.snackbar("Başarılı", accept ? "Projeye katıldınız!" : "Davet reddedildi",
          backgroundColor: accept ? Colors.green : Colors.red, colorText: Colors.white);
    }
  }

  // 4. Yeni Proje Ekleme Diyaloğu
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
            decoration: const InputDecoration(labelText: "Proje Adı", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: descCtrl,
            decoration: const InputDecoration(labelText: "Açıklama (Opsiyonel)", border: OutlineInputBorder()),
          ),
        ],
      ),
      textConfirm: "Oluştur",
      textCancel: "İptal",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF1E3C72),
      onConfirm: () async {
        if (nameCtrl.text.isNotEmpty) {
          Get.back(); // Kapat
          isLoading.value = true;
          bool success = await _service.createProject(nameCtrl.text, descCtrl.text);

          if (success) {
            Get.snackbar("Başarılı", "Proje oluşturuldu", backgroundColor: Colors.green, colorText: Colors.white);
            fetchProjects(); // Listeyi yenile
          } else {
            Get.snackbar("Hata", "Proje oluşturulamadı", backgroundColor: Colors.red, colorText: Colors.white);
          }
          isLoading.value = false;
        }
      },
    );
  }

  // 5. Proje Sil
  void deleteProject(int id) {
    Get.defaultDialog(
        title: "Projeyi Sil?",
        middleText: "Bu projeyi silmek istediğine emin misin?",
        textConfirm: "Evet, Sil",
        textCancel: "Vazgeç",
        confirmTextColor: Colors.white,
        buttonColor: Colors.redAccent,
        onConfirm: () async {
          Get.back();
          isLoading.value = true;
          bool success = await _service.deleteProject(id);
          if (success) {
            fetchProjects();
            Get.snackbar("Silindi", "Proje silindi", snackPosition: SnackPosition.bottom);
          }
          isLoading.value = false;
        }
    );
  }
}