import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_x/get.dart';

import '../models/project.dart';
import '../models/project_invitation_model.dart';
import '../models/projectmember.dart';
import '../models/task.dart';

class ProjectService extends GetConnect {
  final _storage = const FlutterSecureStorage();
  final String url = 'http://10.0.2.2:8000';

  @override
  void onInit() {
    httpClient.baseUrl = url;
    httpClient.timeout = const Duration(seconds: 10);
  }

  // Token Header
  Future<Map<String, String>> _getHeaders() async {
    String? token = await _storage.read(key: 'jwt_token');
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // 1. PROJELERİ GETİR
  Future<List<Project>> getProjects() async {
    try {
      final headers = await _getHeaders();
      final response = await get('/projects/', headers: headers);

      if (response.status.hasError) {
        return [];
      }

      List<dynamic> body = response.body;
      return body.map((item) => Project.fromJson(item)).toList();
    } catch (e) {
      print("Proje Servis Hatası: $e");
      return [];
    }
  }

  // 2. PROJE EKLE
  Future<bool> createProject(String name, String description) async {
    try {
      final headers = await _getHeaders();
      final body = {
        "name": name,
        "description": description
      };

      final response = await post('/projects/', body, headers: headers);
      return !response.status.hasError;
    } catch (e) {
      return false;
    }
  }

  // 3. PROJE SİL
  Future<bool> deleteProject(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await delete('/projects/$id', headers: headers);
      return !response.status.hasError;
    } catch (e) {
      return false;
    }
  }

  // PROJENİN GÖREVLERİNİ ÇEK
  Future<List<Task>> getProjectTasks(int projectId) async {
    try {
      final headers = await _getHeaders();
      final response = await get('/projects/$projectId/tasks', headers: headers);
      if (response.status.hasError) return [];

      List<dynamic> body = response.body;
      return body.map((item) => Task.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  // PROJEYE GÖREV EKLE
  Future<bool> addProjectTask(int projectId, Task task) async {
    try {
      final headers = await _getHeaders();

      // Task modelini JSON'a çevirip gönderiyoruz
      // Status ve ID'yi göndermemize gerek yok, backend halleder
      final body = {
        "title": task.title,
        "description": task.description,
        "priority": task.priority,
        "due_date": task.dueDate?.toIso8601String(), // Tarihi formatla
        "status": "Yapılacak"
      };

      final response = await post('/projects/$projectId/tasks', body, headers: headers);

      if(response.status.hasError) {
        print("Hata: ${response.body}");
        return false;
      }
      return true;
    } catch (e) {
      print("Servis Hatası: $e");
      return false;
    }
  }

  // ÜYE DAVET ET
  Future<bool> inviteMember(int projectId, String username) async {
    try {
      final headers = await _getHeaders();
      // Query parametresi olarak gönderiyoruz: ?username=...
      final response = await post(
          '/projects/$projectId/invite?username=$username',
          {}, // Body boş
          headers: headers
      );
      return !response.status.hasError;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateTaskState(int taskId, String action) async {
    // action: 'assign', 'unassign', 'complete'
    try {
      final headers = await _getHeaders();
      // Router'ı tasks.py içinde yazdığımız için /tasks/... adresine gidiyoruz
      final response = await put('/tasks/$taskId/$action', {}, headers: headers);
      return !response.status.hasError;
    } catch (e) {
      return false;
    }
  }


  Future<List<ProjectInvitation>> getInvitations() async {
    try {
      final headers = await _getHeaders();
      final response = await get('/projects/invitations/my', headers: headers);

      if (response.status.hasError) return [];

      List<dynamic> body = response.body;
      return body.map((item) => ProjectInvitation.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  // DAVETE CEVAP VER (accept / reject)
  Future<bool> respondInvitation(int inviteId, String action) async {
    try {
      final headers = await _getHeaders();
      final response = await put('/projects/invitations/$inviteId/$action', {}, headers: headers);
      return !response.status.hasError;
    } catch (e) {
      return false;
    }
  }

  Future<List<ProjectMember>> getProjectMembers(int projectId) async {
    try {
      final headers = await _getHeaders();
      final response = await get('/projects/$projectId/members', headers: headers);

      if (response.status.hasError) return [];

      List<dynamic> body = response.body;
      return body.map((item) => ProjectMember.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }
}