import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_x/get.dart';

import '../screens/auth_screens/view/login_view.dart';

class AuthService extends GetConnect {
  // Token'ı güvenli saklamak için kasa
  final _storage = const FlutterSecureStorage();
  final String _baseUrl = 'http://10.0.2.2:8000';
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

      // --- HATA KONTROLÜNÜ GÜVENLİ YAPALIM ---
      if (response.status.hasError) {
        print("Kayıt Başarısız. Kod: ${response.statusCode}");
        print("Body: ${response.body}");

        // Eğer body null ise varsayılan mesaj göster, null değilse detayına bak
        String errorMessage = "Kayıt başarısız oldu";
        if (response.body != null && response.body is Map && response.body['detail'] != null) {
          errorMessage = response.body['detail'];
        }

        Get.snackbar("Hata", errorMessage,
            snackPosition: SnackPosition.bottom, backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }

      return true;
    } catch (e) {
      print("Bağlantı Hatası: $e");
      Get.snackbar("Hata", "Sunucuya bağlanılamadı. IP adresini kontrol et.",
          snackPosition: SnackPosition.bottom);
      return false;
    }
  }


  // --- GİRİŞ YAP (LOGIN) ---
  Future<bool> loginUser(String username, String password) async {
    print("------------------------------------------------");
    print("🚀 GİRİŞ İSTEĞİ BAŞLATILIYOR...");
    print("🌐 Hedef Adres: ${httpClient.baseUrl}/auth/login");

    try {
      final formData = FormData({
        "username": username,
        "password": password,
      });

      final response = await post('/auth/login', formData);

      print("📡 Status Code: ${response.statusCode}");
      print("📡 Status Text: ${response.statusText}");
      print("📡 Body: ${response.body}");

      if (response.status.hasError) {
        String errorMsg = "Bağlantı hatası";
        if (response.statusCode == null) {
          errorMsg = "Sunucuya ulaşılamıyor (İnternet veya IP hatası)";
        } else if (response.statusCode == 401) {
          errorMsg = "Kullanıcı adı veya şifre yanlış";
        } else {
          errorMsg = "Hata: ${response.statusText}";
        }

        Get.snackbar("Giriş Başarısız", errorMsg,
            snackPosition: SnackPosition.bottom, backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }

      final token = response.body['access_token'];
      await _storage.write(key: 'jwt_token', value: token);
      print("✅ Token Kaydedildi");

      return true;
    } catch (e) {
      print("❌ KRİTİK HATA (Catch): $e");
      Get.snackbar("Hata", "Bağlantı sorunu: $e", snackPosition: SnackPosition.bottom);
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