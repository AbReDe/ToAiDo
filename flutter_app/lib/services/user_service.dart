// lib/services/user_service.dart


import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_x/get.dart';
import '../models/user_profile_model.dart';

class UserService extends GetConnect {
  final _storage = const FlutterSecureStorage();

  // Emülatör IP'si (10.0.2.2), Gerçek cihazsa PC IP'si
  final String url = 'http://10.0.2.2:8000';

  @override
  void onInit() {
    httpClient.baseUrl = url;
    httpClient.timeout = const Duration(seconds: 10);
  }

  // Token Header Hazırlayıcı
  Future<Map<String, String>> _getHeaders() async {
    String? token = await _storage.read(key: 'jwt_token');
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // 1. PROFİL BİLGİLERİNİ GETİR (GET /users/me)
  Future<UserProfile?> getMyProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await get('/users/me', headers: headers);

      if (response.status.hasError) {
        print("Profil Çekme Hatası: ${response.statusText}");
        return null;
      }

      return UserProfile.fromJson(response.body);
    } catch (e) {
      print("Hata: $e");
      return null;
    }
  }

  // 2. PROFİL GÜNCELLE (PUT /users/me)
  Future<bool> updateProfile(String fullName, String email) async {
    try {
      final headers = await _getHeaders();
      final body = {
        "full_name": fullName,
        "email": email
      };

      final response = await put('/users/me', body, headers: headers);

      if (response.status.hasError) {
        Get.snackbar("Hata", response.body['detail'] ?? "Güncelleme başarısız");
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}