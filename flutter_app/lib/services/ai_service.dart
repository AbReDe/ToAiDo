
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_x/get.dart';

class AIService extends GetConnect {
  final _storage = const FlutterSecureStorage();
  final String url = 'http://10.0.2.2:8000';

  @override
  void onInit() {
    httpClient.baseUrl = url;
    httpClient.timeout = const Duration(seconds: 30); // AI cevapları uzun sürebilir
  }

  Future<String?> sendMessage(String message) async {
    try {
      String? token = await _storage.read(key: 'jwt_token');
      String? apiKey = await _storage.read(key: 'gemini_api_key');

      final response = await post(
          '/ai/chat',
          {"message": message},
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'x-gemini-api-key': apiKey ?? ""
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