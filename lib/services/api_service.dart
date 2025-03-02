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
      final int userId = data['userId']; // Supondo que o backend retorna o ID do usuário

      // Salva o token e o ID do usuário no SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setInt('userId', userId);

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

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

  /// Cria uma nova banda
  Future<bool> createBanda(String nomeBanda) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) return false;

    final response = await http.post(
      Uri.parse("$baseUrl/banda/cadastrarBanda"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: json.encode({"nome": nomeBanda}),
    );

    return response.statusCode == 201 || response.statusCode == 200;
  }

  /// Adiciona um membro à banda pelo ID
  Future<bool> addMember(int bandaId, int usuarioId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) return false;

    final response = await http.post(
      Uri.parse("$baseUrl/banda/adicionarUsuario"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"idBanda": bandaId, "idUsuario": usuarioId}),
    );

    return response.statusCode == 200;
  }

  /// Remove um membro da banda pelo ID
  Future<bool> removeMember(int bandaId, int usuarioId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse("$baseUrl/banda/removerUsuario"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"idBanda": bandaId, "idUsuario": usuarioId}),
    );

    return response.statusCode == 200;
  }
}
