import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../services/api_service.dart';

class LiveSessionScreen extends StatefulWidget {
  final Map<String, dynamic> banda;
  final Map<String, dynamic>? repertorio;
  final bool isLeader;

  const LiveSessionScreen({
    super.key,
    required this.banda,
    this.repertorio,
    required this.isLeader,
  });

  @override
  _LiveSessionScreenState createState() => _LiveSessionScreenState();
}

class _LiveSessionScreenState extends State<LiveSessionScreen> {
  late WebSocketChannel _channel;
  final ApiService apiService = ApiService();
  Map<String, dynamic>? _currentSong;
  List<Map<String, dynamic>> _musicas = [];
  int? _repertorioId;
  static const Color mochaMousse = Color(0xFFA47864);
  static const Color backgroundColor = Color(0xFFF8F5F3);

  @override
  void initState() {
    super.initState();
    print("initState chamado - isLeader: ${widget.isLeader}, repertorio: ${widget.repertorio}");
    _repertorioId = widget.repertorio?["idRepertorio"];
    print("repertorioId inicial: $_repertorioId");
    _connectWebSocket();
    if (_repertorioId != null) {
      print("Chamando _loadMusicas no initState");
      _loadMusicas();
    } else {
      print("repertorioId é null, aguardando WebSocket");
    }
  }

  void _connectWebSocket() async {
    print("Iniciando _connectWebSocket - isLeader: ${widget.isLeader}");
    final token = await _getToken();
    print("Token obtido: $token");
    if (token == null) {
      print("Token é null, exibindo SnackBar");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Token de autenticação não encontrado")),
        );
      }
      return;
    }

    try {
      print("Tentando conectar ao WebSocket com token: $token");
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://127.0.0.1:8080/live-session?token=$token'),
      );
      print("Conexão WebSocket iniciada - Aguardando mensagens");

      _channel.stream.listen(
            (message) {
          print("Mensagem recebida do WebSocket: $message");
          final data = jsonDecode(message);
          String type = data['type'];
          if (type == "connection") {
            print("Conexão confirmada: ${data['message']}");
          } else if (type == "session-started") {
            print("Sessão iniciada: ${data['message']}");
            _repertorioId = data['repertorioId'];
            print("repertorioId atualizado para: $_repertorioId");
            _loadMusicas();
          } else if (type == "session-info") {
            print("Session-info recebido: $data");
            _repertorioId = data['repertorioId'];
            print("repertorioId atualizado para: $_repertorioId");
            _loadMusicas();
            if (data.containsKey('songData')) {
              print("Dados de songData: ${data['songData']}");
              setState(() {
                _currentSong = data['songData']['musica'];
              });
            }
          } else if (type == "update-song" && data['bandaId'] == widget.banda["idBanda"]) {
            print("Atualizando música: ${data['songData']}");
            setState(() {
              _currentSong = data['songData']; // Atualiza com songData diretamente
            });
          } else if (data['bandaId'] == widget.banda["idBanda"] && data.containsKey('idMusica')) {
            print("Dados de música recebida: $data");
            setState(() {
              _currentSong = data['musica'];
            });
          } else {
            print("Mensagem desconhecida recebida: $data");
          }
        },
        onError: (error) {
          print("Erro no WebSocket: $error");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Erro na conexão: $error")),
            );
          }
        },
        onDone: () {
          print("WebSocket fechado - Código: ${_channel.closeCode}, Motivo: ${_channel.closeReason}");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Conexão WebSocket encerrada")),
            );
          }
        },
      );

      if (widget.isLeader) {
        print("Líder iniciando sessão");
        _channel.sink.add(jsonEncode({
          "type": "start-session",
          "bandaId": widget.banda["idBanda"],
          "repertorioId": widget.repertorio!["idRepertorio"],
          "message": "Sessão ao vivo iniciada",
        }));
      } else {
        print("Músico conectado, enviando pedido de participação");
        _channel.sink.add(jsonEncode({
          "type": "join-session",
          "bandaId": widget.banda["idBanda"],
          "message": "Músico entrando na sessão",
        }));
      }
    } catch (e) {
      print("Exceção ao conectar ao WebSocket: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Falha ao conectar ao WebSocket: $e")),
        );
      }
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  void _loadMusicas() async {
    print("Iniciando _loadMusicas");
    if (_repertorioId == null) {
      print("Repertório ID não disponível ainda");
      return;
    }
    try {
      print("Carregando músicas para o repertório ID: $_repertorioId");
      final List<dynamic> musicasRaw = await apiService.getMusicasRepertorio(_repertorioId!);
      print("Dados brutos de musicasRaw: $musicasRaw");
      _musicas = musicasRaw.map((item) => item["musica"] as Map<String, dynamic>).toList();
      print("Músicas carregadas: ${_musicas.length}");
      print("Conteúdo de _musicas: $_musicas");
      setState(() {});
    } catch (e) {
      print("Erro ao carregar músicas: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao carregar músicas: $e")),
        );
      }
    }
  }

  void _changeSong(Map<String, dynamic> song) {
    if (widget.isLeader) {
      print("Mudando música para: ${song["titulo"]}");
      _channel.sink.add(jsonEncode({
        "type": "update-song",
        "bandaId": widget.banda["idBanda"],
        "songData": song,
      }));
      setState(() {
        _currentSong = song;
      });
    }
  }

  @override
  void dispose() {
    _channel.sink.close(status.goingAway);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: mochaMousse),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Sessão ao Vivo - ${widget.banda["nome"]}",
          style: const TextStyle(color: mochaMousse, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: _currentSong != null
                ? Card(
              child: ListTile(
                leading: Icon(Icons.music_note, color: mochaMousse),
                title: Text(_currentSong!["titulo"] ?? "Sem título"),
                subtitle: Text("ID: ${_currentSong!["idMusica"]}"),
              ),
            )
                : const Text("Nenhuma música selecionada", style: TextStyle(color: mochaMousse)),
          ),
          Expanded(
            child: _musicas.isEmpty
                ? Center(
              child: _repertorioId == null
                  ? const Text("Aguardando início da sessão...",
                  style: TextStyle(color: mochaMousse))
                  : const CircularProgressIndicator(color: mochaMousse),
            )
                : ListView.builder(
              itemCount: _musicas.length,
              itemBuilder: (context, index) {
                final song = _musicas[index];
                return ListTile(
                  title: Text(song["titulo"] ?? "Sem título"),
                  trailing: widget.isLeader
                      ? ElevatedButton(
                    onPressed: () => _changeSong(song),
                    style: ElevatedButton.styleFrom(backgroundColor: mochaMousse),
                    child: const Text("Tocar", style: TextStyle(color: Colors.white)),
                  )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}