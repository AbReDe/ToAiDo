import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_x/get.dart';
import '../models/task.dart';


class TaskService extends GetConnect {
  final _storage = const FlutterSecureStorage();


  final String url = 'http://10.0.2.2:8000';

  @override
  void onInit() {
    httpClient.baseUrl = url;
    httpClient.timeout = const Duration(seconds: 10);
  }


  Future<bool> toggleTaskDate(int taskId, String date) async {
    try {
      final headers = await _getHeaders();
      // Query param olarak gönderiyoruz: ?date=2025-12-21
      final response = await put('/tasks/$taskId/toggle_date?date=$date', {}, headers: headers);
      return !response.status.hasError;
    } catch (e) {
      return false;
    }
  }


  // --- TOKEN ALAN YARDIMCI FONKSİYON ---
  Future<Map<String, String>> _getHeaders() async {
    String? token = await _storage.read(key: 'jwt_token');
    return {
      'Authorization': 'Bearer $token', // Backend'deki "Kilidi" açan anahtar
      'Content-Type': 'application/json',
    };
  }

  // 1. GÖREVLERİ GETİR
  Future<List<Task>> getTasks() async {
    try {
      final headers = await _getHeaders();
      final response = await get('/tasks/', headers: headers);

      if (response.status.hasError) {
        print("Hata: ${response.statusText}");
        return [];
      }

      // Gelen listeyi Task modellerine çevir
      List<dynamic> body = response.body;
      return body.map((item) => Task.fromJson(item)).toList();
    } catch (e) {
      print("Bağlantı Hatası: $e");
      return [];
    }
  }

  // 2. GÖREV EKLE
  Future<bool> createTask(Task task) async {
    try {
      final headers = await _getHeaders();

      // Gönderilen veriyi konsola basalım (Hata ayıklama için)
      print("Giden Veri: ${task.toJson()}");

      final response = await post('/tasks/', task.toJson(), headers: headers);

      // --- HATA AYIKLAMA KISMI ---
      if (response.status.hasError) {
        print("🔴 HATA OLUŞTU!");
        print("Status Code: ${response.statusCode}"); // Örn: 500 veya 422
        print("Server Mesajı: ${response.bodyString}"); // Sunucunun cevabı
        return false;
      }

      print("🟢 Başarılı: ${response.body}");
      return true;
    } catch (e) {
      print("Bağlantı Hatası: $e");
      return false;
    }
  }

  // 3. GÖREV SİL
  Future<bool> deleteTask(int taskId) async {
    try {
      final headers = await _getHeaders();
      final response = await delete('/tasks/$taskId', headers: headers);
      return !response.status.hasError;
    } catch (e) {
      return false;
    }
  }

  // 4. DURUM GÜNCELLE (Tamamlandı/Yapılacak)
  Future<bool> updateTaskStatus(int taskId, String newStatus) async {
    try {
      final headers = await _getHeaders();
      final response = await put(
          '/tasks/$taskId',
          {'status': newStatus}, // Sadece status gönderiyoruz
          headers: headers
      );
      return !response.status.hasError;
    } catch (e) {
      return false;
    }
  }
}