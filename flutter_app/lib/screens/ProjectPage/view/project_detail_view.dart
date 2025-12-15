// lib/views/project_detail_view.dart

import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:intl/intl.dart';

import '../../../models/project.dart';
import '../controller/project_detail_controller.dart';

class ProjectDetailView extends StatelessWidget {
  final Project project;

  // Controller'ı tag ile başlatıyoruz ki her proje için ayrı controller olsun
  late final ProjectDetailController controller;

  ProjectDetailView({Key? key, required this.project}) : super(key: key) {
    controller = Get.put(ProjectDetailController(project), tag: project.id.toString());
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Görevler ve Ekip
      child: Scaffold(
        appBar: AppBar(
          title: Text(project.name),
          backgroundColor: const Color(0xFF1E3C72),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.check_circle_outline), text: "Görevler"),
              Tab(icon: Icon(Icons.group), text: "Ekip"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTasksTab(),
            _buildTeamTab(),
          ],
        ),

        // GÖREV EKLE BUTONU (Sadece Görevler sekmesindeyken mantıklı ama burada genel duralım)
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddTaskDialog(context),
          label: const Text("Görev Ekle"),
          icon: const Icon(Icons.add_task),
          backgroundColor: const Color(0xFF1E3C72),
        ),
      ),
    );
  }

  // --- 1. SEKME: GÖREVLER ---
  Widget _buildTasksTab() {
    return Obx(() {
      if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());

      if (controller.tasks.isEmpty) {
        return const Center(child: Text("Bu projede henüz görev yok."));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.tasks.length,
        itemBuilder: (context, index) {
          var task = controller.tasks[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.orangeAccent,
                child: Icon(Icons.work, color: Colors.white, size: 20),
              ),
              title: Text(task.title),
              subtitle: Text(task.status),
              trailing: const Icon(Icons.more_vert),
            ),
          );
        },
      );
    });
  }

  // --- 2. SEKME: EKİP ---
  Widget _buildTeamTab() {
    return Column(
      children: [
        // Davet Et Butonu
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showInviteDialog(),
              icon: const Icon(Icons.person_add),
              label: const Text("Arkadaşını Davet Et"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),

        // Üye Listesi (Şimdilik Statik Görünebilir, Backend'den çekince burası dolacak)
        Expanded(
          child: ListView(
            children: const [
              ListTile(
                leading: CircleAvatar(child: Text("S")),
                title: Text("Sen (Yönetici)"),
                subtitle: Text("Online"),
              ),
              // Buraya diğer üyeler gelecek
            ],
          ),
        ),
      ],
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    // Controller'daki değişkenleri sıfırla (gerekirse) veya mevcut haliyle aç

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // İçerik kadar yer kapla
            children: [
              const Text("Projeye Görev Ekle", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3C72))),
              const SizedBox(height: 20),

              // Başlık
              TextField(
                controller: controller.titleCtrl,
                decoration: InputDecoration(
                  labelText: "Görev Başlığı",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Açıklama
              TextField(
                controller: controller.descCtrl,
                decoration: InputDecoration(
                  labelText: "Açıklama",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Tarih ve Saat Seçimi
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.pickDate(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(12)),
                        child: Obx(() => Text(DateFormat('dd/MM/yyyy').format(controller.selectedDate.value))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.pickTime(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(12)),
                        child: Obx(() => Text(controller.selectedTime.value.format(context))),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Öncelik Seçimi
              const Text("Öncelik:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _priorityChip("Düşük", "low", Colors.green),
                  _priorityChip("Orta", "medium", Colors.orange),
                  _priorityChip("Yüksek", "high", Colors.redAccent),
                ],
              )),

              const SizedBox(height: 24),

              // Kaydet Butonu
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.saveTask,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3C72)),
                  child: const Text("GÖREVİ EKLE", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true, // Klavye açılınca yukarı kaysın
    );
  }


  void _showInviteDialog() {
    final TextEditingController _ctrl = TextEditingController();
    Get.defaultDialog(
      title: "Takıma Davet Et",
      content: Column(
        children: [
          const Text("Kullanıcı adını girin:"),
          const SizedBox(height: 10),
          TextField(
            controller: _ctrl,
            decoration: const InputDecoration(hintText: "Örn: salim"),
          ),
        ],
      ),
      textConfirm: "Davet Gönder",
      textCancel: "Vazgeç",
      confirmTextColor: Colors.white,
     // onConfirm: () => controller.inviteMember(_ctrl.text),
    );
  }

  Widget _priorityChip(String label, String value, Color color) {
    bool isSelected = controller.selectedPriority.value == value;
    return GestureDetector(
      onTap: () => controller.setPriority(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          border: Border.all(color: isSelected ? color : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black87)),
      ),
    );
  }
}