// lib/views/project_view.dart

import 'package:flutter/material.dart';
import 'package:get_x/get.dart';

import '../../../models/project.dart';
import '../../../models/project_invitation_model.dart';
import '../controller/project_controller.dart';
import 'project_detail_view.dart'; // Detay sayfasına gitmek için bu gerekli

class ProjectView extends StatelessWidget {
  final ProjectController controller = Get.put(ProjectController());

  ProjectView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      // Sağ Alt Buton
      floatingActionButton: FloatingActionButton(
        onPressed: controller.showAddProjectDialog,
        backgroundColor: const Color(0xFF1E3C72),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: Column(
        children: [
          // --- ÜST BAŞLIK ---
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30)
              ),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Projelerim",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E3C72)),
                ),
                Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${controller.projectList.length} Proje",
                    style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold),
                  ),
                )),
              ],
            ),
          ),

          // --- DAVETLER KISMI (Varsa görünür) ---
          Obx(() {
            if (controller.invitations.isEmpty) return const SizedBox.shrink();

            return Container(
              height: 140,
              margin: const EdgeInsets.only(top: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.invitations.length,
                itemBuilder: (context, index) {
                  var invite = controller.invitations[index];
                  return _buildInviteCard(invite);
                },
              ),
            );
          }),

          const SizedBox(height: 10),

          // --- PROJE LİSTESİ (GRID) ---
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.projectList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 10),
                      const Text("Henüz hiç projen yok.", style: TextStyle(color: Colors.grey)),
                      const Text("Yeni bir tane oluşturarak başla!", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: controller.projectList.length,
                itemBuilder: (context, index) {
                  return _buildProjectCard(controller.projectList[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // Davet Kartı Tasarımı
  Widget _buildInviteCard(ProjectInvitation invite) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3C72),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.mail_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Proje Daveti",
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            invite.projectName,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
          Text(
            "Gönderen: @${invite.senderUsername}",
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => controller.respondToInvite(invite.id, false),
                child: const Text("Reddet", style: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => controller.respondToInvite(invite.id, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1E3C72),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  minimumSize: const Size(0, 30),
                ),
                child: const Text("Katıl"),
              ),
            ],
          )
        ],
      ),
    );
  }

  // Proje Kartı Tasarımı
  Widget _buildProjectCard(Project project) {
    return GestureDetector(
      onLongPress: () => controller.deleteProject(project.id),
      onTap: () {
        // DETAY SAYFASINA GİT (project_detail_view.dart'a)
        Get.to(() => ProjectDetailView(project: project));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3C72).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.rocket_launch, color: Color(0xFF1E3C72)),
            ),
            const Spacer(),
            Text(
              project.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              project.description ?? "Açıklama yok",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                // Sahibi kim? (ID kontrolü yapılabilir ama şimdilik statik)
                Text("Proje", style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
              ],
            )
          ],
        ),
      ),
    );
  }
}