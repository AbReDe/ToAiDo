// lib/views/project_detail_view.dart

import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:intl/intl.dart';

import '../../../models/project.dart';
import '../../../models/task.dart';
import '../controller/project_detail_controller.dart';


class ProjectDetailView extends StatelessWidget {
  final Project project;
  late final ProjectDetailController controller;

  ProjectDetailView({Key? key, required this.project}) : super(key: key) {
    // Her proje için benzersiz bir controller oluşturuyoruz (Tag kullanarak)
    controller = Get.put(ProjectDetailController(project), tag: project.id.toString());
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text(project.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: const Color(0xFF1E3C72),
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(icon: Icon(Icons.list_alt), text: "Görevler"),
              Tab(icon: Icon(Icons.people_outline), text: "Ekip"),
            ],
          ),
        ),

        // GÖREV EKLEME BUTONU
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddTaskBottomSheet(context),
          label: const Text("Görev Ekle"),
          icon: const Icon(Icons.add),
          backgroundColor: const Color(0xFF1E3C72),
        ),

        body: TabBarView(
          children: [
            _buildTasksTab(),
            _buildTeamTab(context),
          ],
        ),
      ),
    );
  }

  // --- SEKME 1: GÖREVLER ---
  Widget _buildTasksTab() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.tasks.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment_outlined, size: 60, color: Colors.grey.shade300),
              const SizedBox(height: 10),
              const Text("Henüz görev yok.", style: TextStyle(color: Colors.grey, fontSize: 16)),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 80),
        itemCount: controller.tasks.length,
        itemBuilder: (context, index) {
          Task task = controller.tasks[index];
          return _buildSmartTaskCard(task);
        },
      );
    });
  }

  // --- AKILLI GÖREV KARTI (RENKLİ & İŞLEVSEL) ---
  Widget _buildSmartTaskCard(Task task) {
    // Mantıksal Kontroller
    bool isCompleted = task.status == "Tamamlandı";
    bool isUnassigned = task.ownerId == null;
    bool isMine = task.ownerId == controller.currentUserId.value;

    // Renk Teması
    Color statusColor;
    String statusText;

    if (isCompleted) {
      statusColor = Colors.green;
      statusText = "Tamamlandı";
    } else if (isMine) {
      statusColor = Colors.blue;
      statusText = "Sende";
    } else if (isUnassigned) {
      statusColor = Colors.orange;
      statusText = "Boşta";
    } else {
      statusColor = Colors.purple;
      statusText = task.ownerName ?? "Atandı";
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Üst Kısım: Başlık ve Etiket
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? Colors.grey : Colors.black87,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                )
              ],
            ),

            const SizedBox(height: 8),

            // 2. Açıklama (Varsa)
            if (task.description != null && task.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  task.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ),

            // 3. Tarih ve Butonlar
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  task.dueDate != null ? DateFormat('dd MMM HH:mm').format(task.dueDate!) : "--",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),

                const Spacer(),

                // AKSİYON BUTONLARI
                if (!isCompleted) ...[
                  // Durum: Kimse almamış -> "AL"
                  if (isUnassigned)
                    SizedBox(
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () => controller.handleTaskAction(task, "assign"),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3C72), shape: const StadiumBorder()),
                        child: const Text("Üstlen", style: TextStyle(fontSize: 12, color: Colors.white)),
                      ),
                    ),

                  // Durum: Ben almışım -> "BIRAK" veya "BİTİR"
                  if (isMine) ...[
                    SizedBox(
                      height: 32,
                      child: OutlinedButton(
                        onPressed: () => controller.handleTaskAction(task, "unassign"),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent, shape: const StadiumBorder()),
                        child: const Text("Bırak", style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () => controller.handleTaskAction(task, "complete"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: const StadiumBorder()),
                        child: const Text("Bitir", style: TextStyle(fontSize: 12, color: Colors.white)),
                      ),
                    ),
                  ],
                ],
              ],
            )
          ],
        ),
      ),
    );
  }

  // --- SEKME 2: EKİP ---
  Widget _buildTeamTab(BuildContext context) {
    return Column(
      children: [
        // Davet Kartı
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Column(
            children: [
              const Icon(Icons.group_add, size: 40, color: Color(0xFF1E3C72)),
              const SizedBox(height: 10),
              const Text("Ekibini Büyüt", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              const Text("Arkadaşlarını projeye davet ederek görevleri paylaşabilirsin.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () => _showInviteDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3C72),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Arkadaş Davet Et", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),

        // Üye Listesi Başlığı
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text("Proje Üyeleri", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),

        // Üye Listesi (Mock Veri - İleride API'den gelecek)
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              Card(
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: Color(0xFF1E3C72), child: Text("S", style: TextStyle(color: Colors.white))),
                  title: Text("Sen (Yönetici)"),
                  subtitle: Text("Online"),
                  trailing: Icon(Icons.shield, color: Colors.blue),
                ),
              ),
              // Backend 'getProjectMembers' endpoint'i yazılınca burası dolacak
            ],
          ),
        ),
      ],
    );
  }

  // --- DAVET DİYALOĞU ---
  void _showInviteDialog() {
    Get.defaultDialog(
      title: "Arkadaşlarını Seç",
      titlePadding: const EdgeInsets.only(top: 20),
      contentPadding: const EdgeInsets.all(20),
      content: SizedBox(
        height: 300,
        width: 300,
        child: Obx(() {
          if (controller.friends.isEmpty) {
            return const Center(child: Text("Arkadaş listen boş. Önce Profil > Arkadaşlar kısmından arkadaş ekle."));
          }

          return ListView.separated(
            itemCount: controller.friends.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              var friend = controller.friends[index];
              return ListTile(
                leading: CircleAvatar(child: Text(friend.fullName[0])),
                title: Text(friend.fullName),
                subtitle: Text("@${friend.username}"),
                trailing: IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF1E3C72)),
                  onPressed: () => controller.inviteFriend(friend.username),
                ),
              );
            },
          );
        }),
      ),
      textCancel: "Kapat",
    );
  }

  // --- GÖREV EKLEME PANELİ (BOTTOM SHEET) ---
  void _showAddTaskBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              const Text("Yeni Görev Oluştur", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3C72))),
              const SizedBox(height: 20),

              // Başlık
              TextField(
                controller: controller.titleCtrl,
                decoration: InputDecoration(
                  labelText: "Görev Başlığı",
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 16),

              // Açıklama
              TextField(
                controller: controller.descCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: "Açıklama (Opsiyonel)",
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 16),

              // Tarih ve Saat
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.pickDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Color(0xFF1E3C72), size: 20),
                            const SizedBox(width: 8),
                            Obx(() => Text(DateFormat('dd/MM/yyyy').format(controller.selectedDate.value), style: const TextStyle(fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.pickTime(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, color: Color(0xFF1E3C72), size: 20),
                            const SizedBox(width: 8),
                            Obx(() => Text(controller.selectedTime.value.format(context), style: const TextStyle(fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Öncelik
              const Text("Öncelik Seviyesi", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _priorityChip("Düşük", "low", Colors.green),
                  _priorityChip("Orta", "medium", Colors.orange),
                  _priorityChip("Yüksek", "high", Colors.redAccent),
                ],
              )),

              const SizedBox(height: 30),

              // Kaydet Butonu
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: controller.saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3C72),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  child: const Text("GÖREVİ EKLE", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20), // Klavye payı
            ],
          ),
        ),
      ),
      isScrollControlled: true, // Tam ekran açılmasına izin ver
    );
  }

  // Öncelik Seçim Kutusu
  Widget _priorityChip(String label, String value, Color color) {
    bool isSelected = controller.selectedPriority.value == value;
    return GestureDetector(
      onTap: () => controller.setPriority(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}