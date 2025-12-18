import 'dart:convert';
import 'package:http/http.dart' as http;

class User {
  final int? id;
  final String name;
  final int age;

  User({this.id, required this.name, required this.age});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'], name: json['name'], age: json['age']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'age': age};
  }
}

class HttpService {
  static const String baseUrl = 'http://localhost:5000/api';

  static Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));

    if (response.statusCode == 200) {
      List parsed = json.decode(response.body);
      return parsed.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat data');
    }
  }

  static Future<void> deleteUser(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/users/$id'));

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus data');
    }
  }

  static Future<void> createUser(String name, int age) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'age': age}),
    );

    if (response.statusCode != 201) {
      throw Exception('Gagal menambahkan data');
    }
  }
}
