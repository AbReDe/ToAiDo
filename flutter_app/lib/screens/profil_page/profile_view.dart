// lib/views/profile_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_app/screens/profil_page/profile_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // URL için gerekli
import 'package:get_x/get.dart';
import 'profile_sub_pages.dart';
import '../friends/friends_view.dart';

class ProfileView extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());

  ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Base URL'i alıyoruz (Resim yolunu birleştirmek için)
    final String baseUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: RefreshIndicator(
        onRefresh: () async {
          controller.loadUserProfile();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // --- HEADER ---
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 180,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                  ),

                  // --- PROFİL FOTOĞRAFI (GÜNCELLENEN KISIM) ---
                  Positioned(
                    bottom: -50,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Obx(() {
                        // 1. URL TEMİZLİĞİ
                        String baseUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';
                        // Base URL'in sonundaki / işaretini kaldır
                        if (baseUrl.endsWith('/')) {
                          baseUrl = baseUrl.substring(0, baseUrl.length - 1);
                        }

                        String avatarPath = controller.avatarUrl.value;
                        String fullUrl = "";

                        if (avatarPath.isNotEmpty) {
                          // Avatar path'in başındaki / işaretini garantiye al
                          if (!avatarPath.startsWith('/')) {
                            avatarPath = '/$avatarPath';
                          }
                          fullUrl = "$baseUrl$avatarPath";
                        }

                        // Debug İçin Konsola Bas (Hata varsa buradan anlarız)
                        if (fullUrl.isNotEmpty) {
                          print("🖼️ Yüklenmeye Çalışılan Resim: $fullUrl");
                        }

                        // 2. RESİM YÜKLEME ARACI
                        return CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: fullUrl.isNotEmpty
                              ? NetworkImage(fullUrl)
                              : const NetworkImage("https://cdn-icons-png.flaticon.com/512/3135/3135715.png"),
                          // Eğer resim yüklenirken hata olursa (404 vs.) bunu çalıştır:
                          onBackgroundImageError: (exception, stackTrace) {
                            print("❌ Resim Yükleme Hatası: $exception");
                          },
                          child: fullUrl.isEmpty
                              ? null // Resim yoksa ikon gösterme (varsayılan network image gösterir)
                              : null,
                        );
                      }),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 60),

              // --- KULLANICI ADI VE EMAIL ---
              Obx(() => Column(
                children: [
                  if (controller.isLoading.value)
                    const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  else ...[
                    Text(
                      controller.fullName.value,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    Text(
                      "@${controller.username.value}",
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      controller.email.value,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ]
                ],
              )),

              const SizedBox(height: 24),

              // --- İSTATİSTİK BARI ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem("Toplam", controller.totalTasks.value.toString(), Colors.blue),
                      _buildVerticalDivider(),
                      _buildStatItem("Biten", controller.completedTasks.value.toString(), Colors.green),
                      _buildVerticalDivider(),

                      // Arkadaşlar (Tıklanabilir)
                      GestureDetector(
                        onTap: () {
                          Get.to(() => FriendsView());
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topRight,
                          children: [
                            _buildStatItem("Arkadaşlar", controller.friendsCount.value.toString(), Colors.orange),

                            // Kırmızı Nokta
                            if (controller.hasPendingRequests.value)
                              Positioned(
                                top: -2,
                                right: 5,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  )),
                ),
              ),

              const SizedBox(height: 30),

              // --- MENÜLER ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildProfileMenuItem(
                      icon: Icons.edit,
                      text: "Profili Düzenle",
                      onTap: () => Get.to(() => EditProfileView()),
                    ),
                    _buildProfileMenuItem(
                      icon: Icons.notifications_none,
                      text: "Bildirimler",
                      onTap: () => Get.to(() => NotificationsView()),
                    ),
                    _buildProfileMenuItem(
                      icon: Icons.security,
                      text: "Gizlilik ve Güvenlik",
                      onTap: () => Get.to(() => SecurityView()),
                    ),
                    _buildProfileMenuItem(
                      icon: Icons.help_outline,
                      text: "Yardım ve Destek",
                      onTap: () => Get.to(() => HelpView()),
                    ),
                    _buildProfileMenuItem(
                      icon: Icons.vpn_key,
                      text: "AI API Ayarları",
                      textColor: const Color(0xFF1E3C72),
                      onTap: controller.showApiKeyDialog,
                    ),
                    const SizedBox(height: 20),
                    _buildProfileMenuItem(
                      icon: Icons.logout,
                      text: "Çıkış Yap",
                      textColor: Colors.redAccent,
                      iconColor: Colors.redAccent,
                      onTap: controller.logout,
                      hideArrow: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- YARDIMCI WIDGETLAR ---
  Widget _buildStatItem(String label, String count, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 30, width: 1, color: Colors.grey.shade300);
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color textColor = const Color(0xFF1E3C72),
    Color iconColor = const Color(0xFF1E3C72),
    bool hideArrow = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(text, style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
        trailing: hideArrow ? null : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}