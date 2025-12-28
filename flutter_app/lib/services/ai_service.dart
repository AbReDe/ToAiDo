
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_x/get.dart';

class AIService extends GetConnect {
  final _storage = const FlutterSecureStorage();
  final String _baseUrl = 'http://10.0.2.2:8000';

  @override
  void onInit() {
    httpClient.baseUrl = _baseUrl;
    httpClient.timeout = const Duration(seconds: 30); // AI cevapları uzun sürebilir
  }

  Future<List<String>> generateTaskSuggestions(String topic) async {
    try {
      String? token = await _storage.read(key: 'jwt_token');
      // Kullanıcının kaydettiği API Key'i oku (Controller'da yapmıştık ama burada da okuyabiliriz veya parametre alabiliriz)
      // Basitlik adına buradan okuyalım, backend zaten User tablosundan da bakıyor.

      final response = await post(
          '/ai/generate',
          {"topic": topic},
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          }
      );

      if (response.status.hasError) {
        return [];
      }

      // Gelen JSON: { "suggestions": ["Görev 1", "Görev 2"] }
      List<dynamic> list = response.body['suggestions'];
      return list.map((e) => e.toString()).toList();

    } catch (e) {
      print("AI Servis Hatası: $e");
      return [];
    }
  }

  Future<String?> sendMessage(String message) async {
    try {
      String? token = await _storage.read(key: 'jwt_token');

      // Artık 'x-gemini-api-key' göndermek ZORUNLU DEĞİL.
      // Backend token'dan kullanıcıyı bulup veritabanındaki key'i kullanacak.

      final response = await post(
          '/ai/chat',
          {"message": message},
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          }
      );

      if (response.status.hasError) {
        return "Bağlantı hatası: ${response.statusText}";
      }

      return response.body['response'];
    } catch (e) {
      return "Bir hata oluştu.";
    }
  }
}