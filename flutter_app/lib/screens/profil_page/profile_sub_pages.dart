// lib/views/profile_sub_pages.dart

import 'package:flutter/material.dart';
import 'package:flutter_app/screens/profil_page/profile_controller.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_x/get.dart'; // URL için
 // Controller Yolu

// --- 1. HESABI DÜZENLE SAYFASI ---
class EditProfileView extends StatelessWidget {
  final ProfileController controller = Get.find<ProfileController>();
  final TextEditingController nameInput = TextEditingController();
  final TextEditingController emailInput = TextEditingController();

  EditProfileView({Key? key}) : super(key: key) {
    // Sayfa açılırken mevcut verileri inputlara doldur
    nameInput.text = controller.fullName.value;
    emailInput.text = controller.email.value;
  }

  @override
  Widget build(BuildContext context) {
    // Base URL'i al (Resim göstermek için)
    final String baseUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';

    return Scaffold(
      appBar: AppBar(title: const Text("Profili Düzenle"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // --- PROFİL FOTOĞRAFI ALANI ---
            Center(
              child: Stack(
                children: [
                  // PROFİL RESMİ
                  Obx(() {
                    String baseUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';
                    if (baseUrl.endsWith('/')) baseUrl = baseUrl.substring(0, baseUrl.length - 1);

                    String avatarPath = controller.avatarUrl.value;
                    if (avatarPath.isNotEmpty && !avatarPath.startsWith('/')) {
                      avatarPath = '/$avatarPath';
                    }

                    String fullUrl = avatarPath.isNotEmpty ? "$baseUrl$avatarPath" : "";

                    return CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: fullUrl.isNotEmpty
                          ? NetworkImage(fullUrl)
                          : const NetworkImage("https://cdn-icons-png.flaticon.com/512/3135/3135715.png"),
                      onBackgroundImageError: (_, __) {
                        print("❌ Edit Sayfası Resim Hatası");
                      },
                    );
                  }),

                  // KAMERA İKONU (Tıklanabilir)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: controller.pickAndUploadImage, // <-- FONKSİYON BURAYA
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Color(0xFF1E3C72), shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),

            // INPUTLAR
            _buildTextField("Ad Soyad", nameInput),
            const SizedBox(height: 16),
            _buildTextField("E-posta", emailInput),

            // Kullanıcı adı değiştirilemez olsun (readonly)
            const SizedBox(height: 16),
            TextFormField(
              initialValue: controller.username.value,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Kullanıcı Adı (Değiştirilemez)",
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 40),

            // KAYDET BUTONU
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () {
                  // Controller'daki güncelleme fonksiyonunu çağır
                  controller.updateMyProfile(nameInput.text, emailInput.text);
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3C72)),
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("DEĞİŞİKLİKLERİ KAYDET", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// --- 2. BİLDİRİMLER SAYFASI ---
class NotificationsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bildirim Ayarları"), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSwitchTile("Görev Hatırlatıcıları", true),
          _buildSwitchTile("Yeni Proje Davetleri", true),
          _buildSwitchTile("Takım Mesajları", false),
          _buildSwitchTile("Uygulama Güncellemeleri", true),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool val) {
    var isOn = val.obs;
    return Obx(() => SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      value: isOn.value,
      activeColor: const Color(0xFF1E3C72),
      onChanged: (v) => isOn.value = v,
    ));
  }
}

// --- 3. GİZLİLİK VE GÜVENLİK ---
class SecurityView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gizlilik ve Güvenlik"), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text("Şifre Değiştir"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.devices),
            title: const Text("Aktif Cihazlar"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          const Divider(),
          const SizedBox(height: 20),
          const Text("Hesap Verileri", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text("Hesabımı Sil", style: TextStyle(color: Colors.red)),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// --- 4. YARDIM VE DESTEK ---
class HelpView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Yardım ve Destek"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  const Icon(Icons.support_agent, size: 40, color: Color(0xFF1E3C72)),
                  const SizedBox(width: 15),
                  const Expanded(child: Text("Bir sorun mu yaşıyorsunuz? Ekibimiz 7/24 yanınızda.")),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ExpansionTile(title: const Text("Görev nasıl eklerim?"), children: const [Padding(padding: EdgeInsets.all(15.0), child: Text("Ana sayfadaki (+) butonuna tıklayarak yeni görev ekleyebilirsiniz."))]),
            ExpansionTile(title: const Text("Proje nasıl oluştururum?"), children: const [Padding(padding: EdgeInsets.all(15.0), child: Text("Projeler sekmesinden yeni proje oluşturabilirsiniz."))]),
            ExpansionTile(title: const Text("AI Asistanı ücretli mi?"), children: const [Padding(padding: EdgeInsets.all(15.0), child: Text("Hayır, AI özellikleri şu an için tamamen ücretsizdir."))]),
          ],
        ),
      ),
    );
  }
}