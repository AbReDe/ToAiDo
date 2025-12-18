// lib/views/profile_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_app/screens/profil_page/profile_controller.dart';
import 'package:flutter_app/screens/profil_page/profile_sub_pages.dart';
import 'package:get_x/get.dart';

import '../friends/friends_view.dart';



class ProfileView extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());

  ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER (Aynı) ---
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
                Positioned(
                  bottom: -50,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage("https://cdn-icons-png.flaticon.com/512/3135/3135715.png"),
                      backgroundColor: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),

            // --- İSİM VE EMAIL ---
            Obx(() => Column(
              children: [
                Text(
                  controller.username.value,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                Text(
                  controller.email.value,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            )),

            const SizedBox(height: 24),

            // --- YENİ: İSTATİSTİK BARI ---
            // --- İSTATİSTİK BARI (GÜNCELLENMİŞ HALİ) ---
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
                    // 1. Toplam Görev
                    _buildStatItem("Toplam Görev", controller.totalTasks.value.toString(), Colors.blue),

                    _buildVerticalDivider(),

                    // 2. Tamamlanan Görev
                    _buildStatItem("Tamamlanan", controller.completedTasks.value.toString(), Colors.green),

                    _buildVerticalDivider(),

                    // 3. Arkadaşlar (Tıklanabilir ve Kırmızı Noktalı)
                    GestureDetector(
                      onTap: () {
                        // Arkadaşlar Sayfasına Git
                        Get.to(() => FriendsView());
                      },
                      child: Stack(
                        clipBehavior: Clip.none, // Noktanın dışarı taşmasına izin ver
                        alignment: Alignment.topRight,
                        children: [
                          _buildStatItem("Arkadaşlar", controller.friendsCount.value.toString(), Colors.orange),

                          // Eğer bekleyen istek varsa Kırmızı Nokta göster
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
                                  border: Border.all(color: Colors.white, width: 2), // Beyaz çerçeve
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

            // --- MENÜLER (Yönlendirmeli) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildProfileMenuItem(
                    icon: Icons.person_outline,
                    text: "Hesabımı Düzenle",
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
                    icon: Icons.vpn_key_outlined, // Anahtar ikonu
                    text: "AI API Ayarları",
                    onTap: controller.showApiKeyDialog, // Diyaloğu açar
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
    );
  }

  // İstatistik Widget'ı
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

  // Menü Widget'ı (Aynı)
  Widget _buildProfileMenuItem({required IconData icon, required String text, required VoidCallback onTap, Color textColor = const Color(0xFF1E3C72), Color iconColor = const Color(0xFF1E3C72), bool hideArrow = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
      child: ListTile(
        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor)),
        title: Text(text, style: TextStyle(fontWeight: FontWeight.w600, color: textColor == const Color(0xFF1E3C72) ? Colors.black87 : textColor)),
        trailing: hideArrow ? null : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}