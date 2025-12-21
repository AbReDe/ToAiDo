import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_x/get.dart';
import '../models/user_profile_model.dart';

class UserService extends GetConnect {
  final _storage = const FlutterSecureStorage();


  final String _baseUrl = 'http://10.0.2.2:8000';

  @override
  void onInit() {
    httpClient.baseUrl = _baseUrl;
    httpClient.timeout = const Duration(seconds: 20);
    print("✅ UserService Başlatıldı. Hedef URL: ${httpClient.baseUrl}");
  }

  Future<Map<String, String>> _getHeaders() async {
    String? token = await _storage.read(key: 'jwt_token');
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // 1. PROFİLİ GETİR
  Future<UserProfile?> getMyProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await get('/users/me', headers: headers);

      // --- EĞER TOKEN GEÇERSİZSE (401) ---
      if (response.statusCode == 401) {
        print("⛔ Token süresi dolmuş veya geçersiz. Çıkış yapılıyor.");
        await _storage.delete(key: 'jwt_token');
        Get.offAllNamed('/login'); // Veya LoginView()
        return null;
      }
      // ------------------------------------

      if (response.status.hasError) {
        return null;
      }
      return UserProfile.fromJson(response.body);
    } catch (e) {
      return null;
    }
  }

  // 2. PROFİL GÜNCELLE (Konsol Ajanlı Versiyon)
  Future<bool> updateProfile({String? fullName, String? email, String? apiKey}) async {
    print("---------------------------------------------");
    print("🚀 UserService: updateProfile tetiklendi!");

    try {
      final headers = await _getHeaders();
      final Map<String, dynamic> body = {};

      if (fullName != null) body["full_name"] = fullName;
      if (email != null) body["email"] = email;

      // API Key kontrolü
      if (apiKey != null && apiKey.isNotEmpty) {
        body["gemini_api_key"] = apiKey;
        print("🔑 API Key pakete eklendi: $apiKey");
      }

      print("📦 Gönderilen Body: $body");
      print("🌐 İstek Adresi: ${httpClient.baseUrl}/users/me");

      // PUT İsteği
      final response = await put('/users/me', body, headers: headers);

      print("📡 Sunucu Cevap Kodu: ${response.statusCode}");
      print("📡 Sunucu Cevabı: ${response.bodyString}");

      if (response.status.hasError) {
        print("❌ HATA: Sunucu olumsuz döndü.");
        return false;
      }

      print("✅ BAŞARILI: Sunucu kabul etti.");
      return true;
    } catch (e) {
      print("❌ KRİTİK BAĞLANTI HATASI (Catch): $e");
      return false;
    } finally {
      print("---------------------------------------------");
    }
  }
}