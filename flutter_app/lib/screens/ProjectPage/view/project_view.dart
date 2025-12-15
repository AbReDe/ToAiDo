// lib/views/project_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_app/screens/ProjectPage/controller/project_controller.dart';
import 'package:flutter_app/screens/ProjectPage/view/project_detail_view.dart';
import 'package:get_x/get.dart';

import '../../../models/project.dart';


class ProjectView extends StatelessWidget {
  final ProjectController controller = Get.put(ProjectController());

  ProjectView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      // SAĞ ALTTAKİ EKLEME BUTONU
      floatingActionButton: FloatingActionButton(
        onPressed: controller.showAddProjectDialog,
        backgroundColor: const Color(0xFF1E3C72),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: Column(
        children: [
          // --- BAŞLIK ALANI ---
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

          const SizedBox(height: 10),

          // --- IZGARA (GRID) LİSTE ---
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
                  crossAxisCount: 2, // Yan yana 2 kutu
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85, // Kutuların boy/en oranı
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

  // --- PROJE KARTI TASARIMI ---
  Widget _buildProjectCard(Project project) {
    return GestureDetector(
      onLongPress: () => controller.deleteProject(project.id), // Uzun basınca sil
      onTap: () {
        // DETAY SAYFASINA GİT
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
            // İkon Kutusu
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3C72).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.rocket_launch, color: Color(0xFF1E3C72)),
            ),

            const Spacer(),

            // Proje Adı
            Text(
              project.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 4),

            // Açıklama
            Text(
              project.description ?? "Açıklama yok",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),

            const SizedBox(height: 10),

            // Alt Bilgi
            Row(
              children: [
                const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text("Yönetici: Sen", style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
              ],
            )
          ],
        ),
      ),
    );
  }
}