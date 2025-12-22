// lib/views/friends_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_x/get.dart';

import 'friends_controller.dart'; // URL için gerekli


class FriendsView extends StatelessWidget {
  final FriendsController controller = Get.put(FriendsController());

  FriendsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Arkadaşlar"),
          centerTitle: true,
          backgroundColor: const Color(0xFF1E3C72),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "Arkadaşlarım"),
              Tab(text: "Gelen İstekler"),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () => _showSearchBottomSheet(context),
            )
          ],
        ),
        body: TabBarView(
          children: [
            // SEKME 1: ARKADAŞ LİSTESİ
            Obx(() => controller.friendsList.isEmpty
                ? const Center(child: Text("Henüz arkadaşın yok."))
                : ListView.builder(
              itemCount: controller.friendsList.length,
              itemBuilder: (context, index) {
                var friend = controller.friendsList[index];
                return ListTile(
                  // --- GÜNCELLENEN KISIM ---
                  leading: _buildUserAvatar(friend.avatarUrl, friend.fullName),
                  // -------------------------
                  title: Text(friend.fullName),
                  subtitle: Text("@${friend.username}"),
                  trailing: const Icon(Icons.check_circle, color: Colors.green),
                );
              },
            )),

            // SEKME 2: BEKLEYEN İSTEKLER
            Obx(() => controller.requestList.isEmpty
                ? const Center(child: Text("Bekleyen istek yok."))
                : ListView.builder(
              itemCount: controller.requestList.length,
              itemBuilder: (context, index) {
                var req = controller.requestList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    // --- GÜNCELLENEN KISIM ---
                    leading: _buildUserAvatar(req.avatarUrl, req.fullName),
                    // -------------------------
                    title: Text(req.fullName),
                    subtitle: const Text("Arkadaşlık isteği gönderdi"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green, size: 30),
                          onPressed: () => controller.respond(req.id, true),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red, size: 30),
                          onPressed: () => controller.respond(req.id, false),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )),
          ],
        ),
      ),
    );
  }

  // --- MODERN ARAMA PANELİ ---
  void _showSearchBottomSheet(BuildContext context) {
    controller.searchCtrl.clear();
    controller.searchResults.clear();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        height: 500,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),

            const Text("Kullanıcı Ara", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3C72))),
            const SizedBox(height: 15),

            TextField(
              controller: controller.searchCtrl,
              onChanged: controller.onSearchChanged,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Kullanıcı adı veya isim girin...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: Obx(() {
                if (controller.isSearching.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.searchCtrl.text.isNotEmpty && controller.searchResults.isEmpty) {
                  return const Center(child: Text("Kullanıcı bulunamadı.", style: TextStyle(color: Colors.grey)));
                }

                return ListView.separated(
                  itemCount: controller.searchResults.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    var user = controller.searchResults[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      // --- GÜNCELLENEN KISIM ---
                      leading: _buildUserAvatar(user.avatarUrl, user.fullName),
                      // -------------------------
                      title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("@${user.username}"),
                      trailing: ElevatedButton(
                        onPressed: () => controller.sendRequest(user.username),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3C72),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: const Text("Ekle", style: TextStyle(color: Colors.white)),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // --- RESİM GÖSTERME YARDIMCISI ---
  Widget _buildUserAvatar(String? partialUrl, String fullName) {
    // 1. Base URL'i al (IP Adresi)
    String baseUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';

    // 2. Eğer backend'den resim yolu geldiyse birleştir
    String? fullUrl;
    if (partialUrl != null && partialUrl.isNotEmpty) {
      fullUrl = "$baseUrl$partialUrl";
    }

    return CircleAvatar(
      radius: 24,
      backgroundColor: const Color(0xFF1E3C72),
      // Resim varsa NetworkImage, yoksa null
      backgroundImage: fullUrl != null ? NetworkImage(fullUrl) : null,
      // Resim yoksa İsmin Baş Harfi
      child: fullUrl == null
          ? Text(
        fullName.isNotEmpty ? fullName[0].toUpperCase() : "?",
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      )
          : null,
    );
  }
}