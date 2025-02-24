import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://localhost:8080";

  /// Realiza login enviando usuário e senha para o backend
  Future<bool> login(String login, String senha) async {
    final url = Uri.parse("$baseUrl/auth/login");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "login": login,
        "senha": senha,
      }),
    );

    return response.statusCode == 200;
  }

  /// Realiza cadastro enviando nome, usuário e senha para o backend
  Future<bool> register(String nome, String login, String senha) async {
    final url = Uri.parse("$baseUrl/auth/registrar");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nome": nome,
        "login": login,
        "senha": senha,
      }),
    );

    return response.statusCode == 200;
  }
}
