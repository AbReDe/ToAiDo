// lib/views/friends_view.dart

import 'package:flutter/material.dart';
import 'package:get_x/get.dart';

import 'friends_controller.dart';

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
              onPressed: () => _showAddDialog(context),
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
                  leading: CircleAvatar(child: Text(friend.fullName[0])),
                  title: Text(friend.fullName),
                  subtitle: Text("@${friend.username}"),
                  trailing: const Icon(Icons.chat_bubble_outline),
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
                    leading: CircleAvatar(backgroundColor: Colors.orange, child: Text(req.fullName[0])),
                    title: Text(req.fullName),
                    subtitle: Text("Arkadaşlık isteği gönderdi"),
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

  void _showAddDialog(BuildContext context) {
    final TextEditingController _ctrl = TextEditingController();
    Get.defaultDialog(
      title: "Arkadaş Ekle",
      content: TextField(
        controller: _ctrl,
        decoration: const InputDecoration(hintText: "Kullanıcı adı girin (örn: salim)"),
      ),
      textConfirm: "İstek Gönder",
      textCancel: "İptal",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF1E3C72),
      onConfirm: () => controller.sendRequest(_ctrl.text),
    );
  }
}