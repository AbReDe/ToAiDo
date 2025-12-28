import 'package:flutter/material.dart';
import 'package:flutter_app/screens/profil_page/profile_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_x/get.dart'; // URL için gerekli


// ==================================================
// 1. PROFİLİ DÜZENLE SAYFASI
// ==================================================
class EditProfileView extends StatelessWidget {
  final ProfileController controller = Get.find<ProfileController>();

  final TextEditingController nameInput = TextEditingController();
  final TextEditingController emailInput = TextEditingController();

  // Form doğrulama anahtarı
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  EditProfileView({Key? key}) : super(key: key) {
    // Sayfa açılırken mevcut verileri kutucuklara doldur
    nameInput.text = controller.fullName.value;
    emailInput.text = controller.email.value;
  }

  @override
  Widget build(BuildContext context) {
    // Resim URL'si için Base URL'i alıyoruz
    final String baseUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profili Düzenle", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey, // Form anahtarı
          child: Column(
            children: [
              // --- PROFİL FOTOĞRAFI ALANI ---
              Center(
                child: Stack(
                  children: [
                    // Profil Resmi
                    Obx(() {
                      String url = controller.avatarUrl.value;
                      String fullUrl = "";

                      // URL düzeltme mantığı
                      if (url.isNotEmpty) {
                        String cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
                        String cleanPath = url.startsWith('/') ? url : '/$url';
                        fullUrl = "$cleanBase$cleanPath";
                      }

                      return CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: fullUrl.isNotEmpty
                            ? NetworkImage(fullUrl)
                            : const NetworkImage("https://cdn-icons-png.flaticon.com/512/3135/3135715.png"),
                        onBackgroundImageError: (_, __) {
                          // Hata olursa varsayılan gösterilir
                        },
                      );
                    }),

                    // Kamera İkonu (Tıklanabilir)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: controller.pickAndUploadImage, // Resim yükleme fonksiyonu
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                              color: Color(0xFF1E3C72),
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // --- AD SOYAD INPUT ---
              TextFormField(
                controller: nameInput,
                decoration: InputDecoration(
                  labelText: "Ad Soyad",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person, color: Color(0xFF1E3C72)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.length < 3) {
                    return 'İsim en az 3 karakter olmalı';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // --- E-POSTA INPUT ---
              TextFormField(
                controller: emailInput,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "E-posta",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.email, color: Color(0xFF1E3C72)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'E-posta boş bırakılamaz';
                  }
                  if (!GetUtils.isEmail(value)) {
                    return 'Geçersiz e-posta formatı';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // --- KULLANICI ADI (Salt Okunur) ---
              TextFormField(
                initialValue: controller.username.value,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Kullanıcı Adı (Değiştirilemez)",
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                ),
              ),

              const SizedBox(height: 40),

              // --- KAYDET BUTONU ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                    // Validasyon kontrolü
                    if (_formKey.currentState!.validate()) {
                      controller.updateMyProfile(nameInput.text, emailInput.text);
                    } else {
                      Get.snackbar("Hata", "Lütfen bilgileri kontrol ediniz.",
                          backgroundColor: Colors.redAccent, colorText: Colors.white, snackPosition: SnackPosition.bottom);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3C72),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("DEĞİŞİKLİKLERİ KAYDET", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================================================
// 2. BİLDİRİMLER SAYFASI
// ==================================================
class NotificationsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bildirim Ayarları"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
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

// ==================================================
// 3. GİZLİLİK VE GÜVENLİK SAYFASI
// ==================================================
class SecurityView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gizlilik ve Güvenlik"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            leading: const Icon(Icons.lock_outline, color: Color(0xFF1E3C72)),
            title: const Text("Şifre Değiştir"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Get.snackbar("Bilgi", "Şifre değiştirme yakında eklenecek.");
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.devices, color: Color(0xFF1E3C72)),
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
            title: const Text("Hesabımı Sil", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () {
              Get.defaultDialog(
                title: "Hesabı Sil",
                middleText: "Bu işlem geri alınamaz. Emin misiniz?",
                textConfirm: "Evet, Sil",
                textCancel: "Hayır",
                confirmTextColor: Colors.white,
                buttonColor: Colors.red,
                onConfirm: () => Get.back(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ==================================================
// 4. YARDIM VE DESTEK SAYFASI
// ==================================================
class HelpView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yardım ve Destek"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: const Row(
                children: [
                  Icon(Icons.support_agent, size: 40, color: Color(0xFF1E3C72)),
                  SizedBox(width: 15),
                  Expanded(child: Text("Bir sorun mu yaşıyorsunuz? Ekibimiz 7/24 yanınızda.", style: TextStyle(fontSize: 15))),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildExpansionTile("Görev nasıl eklerim?", "Ana sayfadaki (+) butonuna tıklayarak yeni görev ekleyebilir, tarih ve saat seçebilirsiniz."),
            _buildExpansionTile("Proje nasıl oluştururum?", "Projeler sekmesine gidip sağ alttaki (+) butonuna basarak yeni bir proje başlatabilirsiniz."),
            _buildExpansionTile("AI Asistanı ücretli mi?", "Hayır, Google Gemini API anahtarınızı girerek ücretsiz kullanabilirsiniz."),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionTile(String title, String content) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.grey.shade200)),
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(content, style: const TextStyle(color: Colors.black87)),
          )
        ],
      ),
    );
  }
}