import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

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

    return response.statusCode == 200;
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

  /// Cria um novo repertório para uma banda
  Future<String> createRepertorio(int bandaId, String nomeRepertorio) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) return "Usuário não autenticado.";

    final response = await http.post(
      Uri.parse("$baseUrl/repertorios/cadastrarRepertorio"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"idBanda": bandaId, "nome": nomeRepertorio}),
    );

    if (response.statusCode == 200) {
      return "Repertório criado com sucesso!";
    } else {
      return "Erro ao apagar repertório";
    }
  }

  /// Deleta um repertório de uma banda
  Future<String> deleteRepertorio(int idRepertorio) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) return "Usuário não autenticado.";

    final response = await http.delete(
      Uri.parse("$baseUrl/repertorios/excluir/$idRepertorio"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return "Repertório excluido com sucesso!";
    } else {
      return "Erro ao apagar repertório";
    }
  }

  ///Busca os membros da banda
  Future<List<Map<String, dynamic>>> getBandMembers(int bandaId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("Usuário não autenticado.");
    }

    final response = await http.get(
      Uri.parse("http://localhost:8080/banda/$bandaId/listarMusicos"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception("Erro ao buscar membros da banda.");
    }
  }

  /// Busca os repertórios da banda
  Future<List<Map<String, dynamic>>> getBandRepertorios(int bandaId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("Usuário não autenticado.");
    }

    final response = await http.get(
      Uri.parse("http://localhost:8080/repertorios/listarRepertorios/$bandaId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception("Erro ao buscar repertórios da banda.");
    }
  }

  /// Busca as músicas de um repertório
  Future<List<Map<String, dynamic>>> getMusicasRepertorio(int repertorioId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("Usuário não autenticado.");
    }

    final response = await http.get(
      Uri.parse("http://localhost:8080/repertorios/listarMusicasRepertorio/$repertorioId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }else if (response.statusCode == 404){
      throw Exception("O repertório não possui músicas.");
    } else {
      throw Exception("Erro ao buscar músicas do repertório.");
    }
  }

  /// Busca as músicas do usuário logado
  Future<List<Map<String, dynamic>>> getMinhasMusicas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("Usuário não autenticado.");
    }

    final response = await http.get(
      Uri.parse('http://localhost:8080/musicas/minhasMusicas'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw ("Erro ao buscar músicas do usuário.");
    }
  }

  /// Adiciona uma nova música com título e PDF
  Future<bool> addMusic(String titulo, Uint8List pdfBytes, String fileName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("Usuário não autenticado.");
    }

    var uri = Uri.parse("$baseUrl/musicas/cadastrarMusica");
    var request = http.MultipartRequest("POST", uri)
      ..headers["Authorization"] = "Bearer $token"
      ..fields["titulo"] = titulo
      ..files.add(
        http.MultipartFile.fromBytes(
          'arquivoPdf',
          pdfBytes,
          filename: fileName,
          contentType: MediaType('application', 'pdf'),
        ),
      );

    var response = await request.send();
    return response.statusCode == 200;
  }

  ///Adiciona uma musica ao repertório
  Future<bool> addMusicToRepertorio(int repertorioId, int musicaId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("Usuário não autenticado.");
    }

    final response = await http.post(
      Uri.parse("$baseUrl/repertorios/adicionarMusica"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "idRepertorio": repertorioId,
        "idMusica": musicaId,
      }),
    );

    return response.statusCode == 200;
  }

  ///Desativa uma musica do repertório
  Future<bool> disableMusicOfRepertorio(int repertorioId, int musicaId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("Usuário não autenticado.");
    }

    final response = await http.delete(
      Uri.parse("$baseUrl/repertorios/desativarMusica"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "idRepertorio": repertorioId,
        "idMusica": musicaId,
      }),
    );

    return response.statusCode == 200;
  }

  /// Reativa uma música que foi desativada do repertório
  Future<bool> enableMusicOfRepertorio(int repertorioId, int musicaId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("Usuário não autenticado.");
    }

    final response = await http.post(
      Uri.parse("$baseUrl/repertorios/ativarMusica"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "idRepertorio": repertorioId,
        "idMusica": musicaId,
      }),
    );

    return response.statusCode == 200;
  }

  /// Reativa uma música que foi desativada do repertório
  Future<bool> updateMusicasOrder(int repertorioId, List<int> musicasIds) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("Usuário não autenticado.");
    }

    final response = await http.put(
      Uri.parse("$baseUrl/repertorios/$repertorioId/ordem"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "idsMusicas": musicasIds
      }),
    );

    return response.statusCode == 200;
  }

  ///Exclui uma musica do repertório
  Future<bool> deleteMusicOfRepertorio(int repertorioId, int musicaId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("Usuário não autenticado.");
    }

    final response = await http.delete(
      Uri.parse("$baseUrl/repertorios/excluirMusica"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "idRepertorio": repertorioId,
        "idMusica": musicaId,
      }),
    );

    print(response.body);
    return response.statusCode == 200;
  }

  /// Faz o download do arquivo PDF da música
  Future<Uint8List> downloadMusicaPdf(int musicaId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("Usuário não autenticado.");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/musicas/baixarMusica/$musicaId"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else if (response.statusCode == 404) {
      throw Exception("Arquivo não encontrado.");
    } else {
      throw Exception("Erro ao fazer download do arquivo. Código: ${response.statusCode}");
    }
  }

  /// Obter detalhes de uma música específica
  Future<Map<String, dynamic>> getMusicaDetails(int musicaId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("Usuário não autenticado.");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/musicas/$musicaId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception("Música não encontrada.");
    } else {
      throw Exception("Erro ao buscar detalhes da música.");
    }
  }
}