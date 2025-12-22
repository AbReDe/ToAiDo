import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_x/get.dart';

import '../screens/auth_screens/view/login_view.dart';

class AuthService extends GetConnect {
  // Token'ı güvenli saklamak için kasa
  final _storage = const FlutterSecureStorage();
  final String _baseUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';

  @override
  void onInit() {


    print("------------------------------------------------");
    print("🚀 AUTH SERVICE BAŞLATILIYOR");
    print("🌐 Hedef URL: $_baseUrl");
    print("------------------------------------------------");



    httpClient.baseUrl = _baseUrl;

    httpClient.timeout = const Duration(seconds: 10);
  }

  // --- KAYIT OL (REGISTER) ---
  Future<bool> registerUser(String username, String email, String password, String fullName) async {
    try {
      final response = await post(
        '/auth/register',
        {
          "username": username,
          "email": email,
          "password": password,
          "full_name": fullName,
        },
      );

      if (response.status.hasError) {
        print("Kayıt Hatası: ${response.bodyString}"); // Hata ayıklama için
        Get.snackbar("Hata", response.body['detail'] ?? "Kayıt başarısız oldu",
            snackPosition: SnackPosition.bottom);
        return false;
      }

      return true; // Kayıt başarılı (200 OK)
    } catch (e) {
      print("Bağlantı Hatası: $e");
      Get.snackbar("Hata", "Sunucuya bağlanılamadı", snackPosition: SnackPosition.bottom);
      return false;
    }
  }

  // --- GİRİŞ YAP (LOGIN) ---
  Future<bool> loginUser(String username, String password) async {
    try {
      // Backend artık 'Form Data' istiyor, JSON değil.
      // GetX'in FormData yapısını kullanıyoruz.
      final formData = FormData({
        "username": username,
        "password": password,
      });

      final response = await post(
        '/auth/login',
        formData, // <-- JSON yerine bunu gönderiyoruz
      );

      if (response.status.hasError) {
        // Hata detayını konsola yazdıralım
        print("Giriş Hatası: ${response.bodyString}");
        Get.snackbar("Giriş Başarısız", "Kullanıcı adı veya şifre hatalı",
            snackPosition: SnackPosition.bottom);
        return false;
      }

      // Gelen Token'ı al
      final token = response.body['access_token'];

      await _storage.write(key: 'jwt_token', value: token);
      print("Token Kaydedildi: $token");

      return true;
    } catch (e) {
      Get.snackbar("Hata", "Bağlantı sorunu oluştu", snackPosition: SnackPosition.bottom);
      print(e);
      return false;
    }
  }

  // --- TOKEN OKUMA (İleride lazım olacak) ---
  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  // --- ÇIKIŞ YAP (LOGOUT) ---
  Future<void> logout() async {
    // 1. Telefondaki token'ı sil
    await _storage.delete(key: 'jwt_token');

    // 2. Tüm sayfaları kapat ve Giriş Ekranını aç
    // offAll: Geri tuşuna basınca tekrar profile dönemesin diye her şeyi siler.
    Get.offAll(() => LoginView(), transition: Transition.fade);
  }
}