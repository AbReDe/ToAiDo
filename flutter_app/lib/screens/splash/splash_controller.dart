import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_x/get.dart';
import '../../services/user_service.dart';
import '../auth_screens/view/login_view.dart';
import '../homepage/home_view.dart';


class SplashController extends GetxController {
  final _storage = const FlutterSecureStorage();
  final UserService _userService = Get.put(UserService()); // Servisi çağır

  @override
  void onInit() {
    super.onInit();
    _checkSession();
  }

  void _checkSession() async {
    // Logo görünsün diye azıcık bekletelim
    await Future.delayed(const Duration(seconds: 2));

    // 1. Token var mı?
    String? token = await _storage.read(key: 'jwt_token');

    if (token == null || token.isEmpty) {
      print("❌ Token yok. Giriş ekranına gidiliyor.");
      Get.offAll(() => LoginView());
      return;
    }

    // 2. Token GEÇERLİ Mİ? (Backend'e soruyoruz)
    print("❓ Token var, geçerliliği kontrol ediliyor...");

    // getMyProfile fonksiyonu 401 (Hata) alırsa null döner
    var profile = await _userService.getMyProfile();

    if (profile != null) {
      print("✅ Token geçerli. Hoşgeldin ${profile.username}");
      Get.offAll(() => HomeView());
    } else {
      print("⛔ Token süresi dolmuş. Giriş ekranına atılıyor.");
      // Eski token'ı silelim ki temiz olsun
      await _storage.delete(key: 'jwt_token');
      Get.offAll(() => LoginView());
    }
  }
}