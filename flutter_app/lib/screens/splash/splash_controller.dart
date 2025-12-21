import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_x/get.dart';
import '../auth_screens/view/login_view.dart';
import '../homepage/home_view.dart';


class SplashController extends GetxController {
  final _storage = const FlutterSecureStorage();

  @override
  void onInit() {
    super.onInit();
    _checkSession();
  }

  void _checkSession() async {
    // Biraz bekleme ekleyelim ki logo görünsün (Estetik açıdan)
    await Future.delayed(const Duration(seconds: 2));

    // 1. Hafızadaki token'ı oku
    String? token = await _storage.read(key: 'jwt_token');

    // 2. Karar ver
    if (token != null && token.isNotEmpty) {
      // Token varsa direkt Ana Sayfaya git
      print("✅ Oturum açık, Ana Sayfaya yönlendiriliyor...");
      Get.offAll(() => HomeView());
    } else {
      // Token yoksa Giriş Ekranına git
      print("❌ Oturum kapalı, Giriş Ekranına yönlendiriliyor...");
      Get.offAll(() => LoginView());
    }
  }
}