// lib/services/friend_service.dart


import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_x/get.dart';
import '../models/friend_model.dart';
import '../models/projectmember.dart';

class FriendService extends GetConnect {
  final _storage = const FlutterSecureStorage();
  final String _baseUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';

  @override
  void onInit() {
    httpClient.baseUrl = _baseUrl;
  }




  // KULLANICI ARA
  Future<List<ProjectMember>> searchUsers(String query) async {
    if (query.length < 2) return [];

    try {
      final headers = await _getHeaders();
      final response = await get('/users/search?query=$query', headers: headers);

      if (response.status.hasError) return [];

      List<dynamic> body = response.body;
      // Backend UserBasicInfo dönüyor, ProjectMember ile yapısı uyumlu olduğu için onu kullanıyoruz
      return body.map((item) => ProjectMember.fromJson(item)).toList();
    } catch (e) {
      print("Arama hatası: $e");
      return [];
    }
  }


  Future<Map<String, String>> _getHeaders() async {
    String? token = await _storage.read(key: 'jwt_token');
    return {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};
  }

  // Arkadaş İsteği Gönder
  Future<String> sendRequest(String username) async {
    final headers = await _getHeaders();
    final response = await post('/friends/request/$username', {}, headers: headers);
    return response.body['message'] ?? response.statusText;
  }

  // Bekleyen İstekleri Getir
  Future<List<Friend>> getPendingRequests() async {
    final headers = await _getHeaders();
    final response = await get('/friends/requests', headers: headers);
    if (response.status.hasError) return [];
    return (response.body as List).map((e) => Friend.fromJson(e)).toList();
  }

  // Arkadaşları Getir
  Future<List<Friend>> getFriends() async {
    final headers = await _getHeaders();
    final response = await get('/friends/', headers: headers);
    if (response.status.hasError) return [];
    return (response.body as List).map((e) => Friend.fromJson(e)).toList();
  }

  // Kabul Et / Reddet
  Future<bool> respondRequest(int id, String action) async {
    final headers = await _getHeaders();
    final response = await put('/friends/$id/$action', {}, headers: headers);
    return !response.status.hasError;
  }
}