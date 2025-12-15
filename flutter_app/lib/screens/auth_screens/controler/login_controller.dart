import 'package:flutter/material.dart';
import 'package:get_x/get.dart';

import '../../../services/auth_service.dart';
import '../../homepage/home_view.dart';


class LoginController extends GetxController {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  // Servisi çağırıyoruz
  final AuthService _authService = Get.put(AuthService());

  var isPasswordHidden = true.obs;
  var isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void login() async {
    if (loginFormKey.currentState!.validate()) {
      isLoading.value = true;

      // GERÇEK API İSTEĞİ BURADA YAPILIYOR
      bool success = await _authService.loginUser(
        usernameController.text,
        passwordController.text,
      );

      isLoading.value = false;

      if (success) {
        Get.snackbar("Başarılı", "Giriş yapıldı, yönlendiriliyorsunuz...",
            backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.bottom);


        Get.offAll(() => HomeView());
        print("---> ANA SAYFAYA GİDİLECEK <---");
      }
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}