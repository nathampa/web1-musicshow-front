import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = "http://localhost:8080";

  /// Realiza login enviando usuário e senha para o backend
  Future<bool> login(String login, String senha) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"login": login, "senha": senha}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];

      // Salva o token no SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      return true;
    } else {
      return false;
    }
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

  /// Busca as bandas que o usuário está incluso
  Future<List<Map<String, dynamic>>> getUserBands() async {
    // Recupera o token armazenado no SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    // Verifica se o token não é nulo antes de continuar
    if (token == null) {
      throw Exception("Usuário não autenticado.");
    }

    final url = Uri.parse("$baseUrl/banda/getBandasUsuario");

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception("Erro na API: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception("Falha ao carregar bandas: $e");
    }
  }
}
