// lib/views/register_view.dart

import 'package:flutter/material.dart';
import 'package:get_x/get.dart';

import '../controler/register_controller.dart';


class RegisterView extends StatelessWidget {
  final RegisterController controller = Get.put(RegisterController());

  RegisterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(minHeight: size.height),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E3C72),
                Color(0xFF2A5298),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                children: [
                  // --- ÜST KISIM ---
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                      const Text(
                        "Hesap Oluştur",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

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
                      key: controller.registerFormKey,
                      child: Column(
                        children: [
                          // Ad Soyad
                          _buildTextField(
                            controller: controller.fullNameController,
                            label: "Ad Soyad",
                            icon: Icons.badge_outlined,
                          ),
                          const SizedBox(height: 16),

                          // Kullanıcı Adı
                          _buildTextField(
                            controller: controller.usernameController,
                            label: "Kullanıcı Adı",
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 16),

                          // Email (isEmail: true gönderiyoruz)
                          _buildTextField(
                            controller: controller.emailController,
                            label: "E-posta Adresi",
                            icon: Icons.email_outlined,
                            inputType: TextInputType.emailAddress,
                            isEmail: true, // <-- BU PARAMETRE YENİ
                          ),
                          const SizedBox(height: 16),

                          // Şifre
                          Obx(() => _buildTextField(
                            controller: controller.passwordController,
                            label: "Şifre",
                            icon: Icons.lock_outline,
                            isPassword: true,
                            isObscure: controller.isPasswordHidden.value,
                            toggleVisibility: controller.togglePasswordVisibility,
                          )),
                          const SizedBox(height: 16),

                          // Şifre Tekrar
                          Obx(() => _buildTextField(
                            controller: controller.confirmPasswordController,
                            label: "Şifre Tekrar",
                            icon: Icons.lock_reset,
                            isPassword: true,
                            isObscure: controller.isConfirmPasswordHidden.value,
                            toggleVisibility: controller.toggleConfirmPasswordVisibility,
                          )),
                          const SizedBox(height: 24),

                          // Kayıt Ol Butonu
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: Obx(() => ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : controller.register,
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
                                "KAYIT OL",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                ),
                              ),
                            )),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- ZATEN HESABIM VAR ---
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Zaten hesabın var mı? ",
                        style: TextStyle(color: Colors.white),
                      ),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: const Text(
                          "Giriş Yap",
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

  // --- GELİŞTİRİLMİŞ HELPER WIDGET ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isObscure = false,
    bool isEmail = false, // <-- Yeni parametre
    VoidCallback? toggleVisibility,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? isObscure : false,
      keyboardType: inputType,
      enableSuggestions: !isPassword, // Şifrede öneri kapat
      autocorrect: !isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1E3C72)),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            isObscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: toggleVisibility,
        )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label boş bırakılamaz';
        }
        // İsim kontrolüne (Etikete) bağlı kalmak yerine parametreye bakıyoruz
        if (isEmail && !GetUtils.isEmail(value)) {
          return 'Geçerli bir e-posta girin';
        }
        if (isPassword && value.length < 6) {
          return 'Şifre en az 6 karakter olmalı';
        }
        return null;
      },
    );
  }
}