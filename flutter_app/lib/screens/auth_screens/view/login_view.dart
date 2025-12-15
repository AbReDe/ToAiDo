import 'package:flutter/material.dart';
import 'package:flutter_app/screens/auth_screens/view/register_view.dart';
import 'package:get_x/get.dart';

import '../controler/login_controller.dart';

 // Controller'ı import etmeyi unutma

class LoginView extends StatelessWidget {
  // Controller'ı sayfaya bağlıyoruz
  final LoginController controller = Get.put(LoginController());

  LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ekran boyutlarını al
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: size.height,
          decoration: const BoxDecoration(
            // Modern bir Gradient Arkaplan (Maviden Mora)
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E3C72), // Koyu Teknoloji Mavisi
                Color(0xFF2A5298), // Açık Mavi
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- LOGO ve BAŞLIK KISMI ---
                  const Icon(
                    Icons.task_alt_rounded, // To-Do'yu çağrıştıran ikon
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "ToAiDo",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Yapay Zeka Destekli Proje Yönetimi",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // --- FORM KARTI ---
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: controller.loginFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Giriş Yap",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3C72),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Kullanıcı Adı Input
                          TextFormField(
                            controller: controller.usernameController,
                            decoration: _inputDecoration("Kullanıcı Adı", Icons.person_outline),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lütfen kullanıcı adınızı girin';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Şifre Input (Obx ile sarmaladık çünkü durum değişiyor)
                          Obx(() => TextFormField(
                            controller: controller.passwordController,
                            obscureText: controller.isPasswordHidden.value,
                            decoration: _inputDecoration(
                              "Şifre",
                              Icons.lock_outline,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.isPasswordHidden.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: controller.togglePasswordVisibility,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return 'Şifre en az 6 karakter olmalı';
                              }
                              return null;
                            },
                          )),

                          const SizedBox(height: 10),
                          // Şifremi Unuttum (Opsiyonel)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text("Şifremi Unuttum?", style: TextStyle(color: Colors.grey)),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Giriş Yap Butonu
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: Obx(() => ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : controller.login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E3C72),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                              ),
                              child: controller.isLoading.value
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                "GİRİŞ YAP",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white // Yazı rengi beyaz
                                ),
                              ),
                            )),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- KAYIT OL LİNKİ ---
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Hesabın yok mu? ",
                        style: TextStyle(color: Colors.white),
                      ),
                      GestureDetector(
                        onTap: () {
                          // RegisterView sayfasına git (import etmeyi unutma!)
                          Get.to(() => RegisterView());
                        },
                        child: const Text(
                          "Kayıt Ol",
                          style: TextStyle(
                            color: Colors.yellowAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Tekrar eden kodları önlemek için Input Decoration Metodu
  InputDecoration _inputDecoration(String label, IconData icon, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF1E3C72)),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1E3C72), width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}