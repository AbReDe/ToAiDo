import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import '../../../services/auth_service.dart';


class RegisterController extends GetxController {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();

  // Servisi çağır
  final AuthService _authService = Get.put(AuthService());

  var isPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;
  var isLoading = false.obs;

  void togglePasswordVisibility() => isPasswordHidden.value = !isPasswordHidden.value;
  void toggleConfirmPasswordVisibility() => isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;

  void register() async {
    if (registerFormKey.currentState!.validate()) {
      if (passwordController.text != confirmPasswordController.text) {
        Get.snackbar("Hata", "Şifreler uyuşmuyor!", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.bottom);
        return;
      }

      isLoading.value = true;

      // GERÇEK API İSTEĞİ
      bool success = await _authService.registerUser(
        usernameController.text,
        emailController.text,
        passwordController.text,
        fullNameController.text,
      );

      isLoading.value = false;

      if (success) {
        Get.snackbar("Tebrikler", "Kayıt başarılı! Şimdi giriş yapabilirsiniz.",
            backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.bottom);

        // Giriş sayfasına geri dön
        Get.back();
      }
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}