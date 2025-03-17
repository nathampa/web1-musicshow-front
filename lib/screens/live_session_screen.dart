import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../services/api_service.dart';
import 'pdf_viewer.dart';

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
  Map<String, dynamic>? _nextSong;
  Map<String, dynamic>? _previousSong;
  List<Map<String, dynamic>> _musicas = [];
  int? _repertorioId;
  bool _showSongList = false;
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
          const SnackBar(content: Text("Token de autenticação não encontrado")),
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
                _updateAdjacentSongs();
              });
            }
          } else if (type == "update-song" && data['bandaId'] == widget.banda["idBanda"]) {
            print("Atualizando música: ${data['songData']}");
            setState(() {
              _currentSong = data['songData'];
              _updateAdjacentSongs();
            });
          } else if (data['bandaId'] == widget.banda["idBanda"] && data.containsKey('idMusica')) {
            print("Dados de música recebida: $data");
            setState(() {
              _currentSong = data['musica'];
              _updateAdjacentSongs();
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
              const SnackBar(content: Text("Conexão WebSocket encerrada")),
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

  void _updateAdjacentSongs() {
    if (_musicas.isEmpty || _currentSong == null) return;

    final currentIndex = _musicas.indexWhere((song) => song["idMusica"] == _currentSong!["idMusica"]);

    if (currentIndex == -1) return;

    // Atualiza próxima música
    if (currentIndex < _musicas.length - 1) {
      _nextSong = _musicas[currentIndex + 1];
    } else {
      _nextSong = null; // Não há próxima música (é a última)
    }

    // Atualiza música anterior
    if (currentIndex > 0) {
      _previousSong = _musicas[currentIndex - 1];
    } else {
      _previousSong = null; // Não há música anterior (é a primeira)
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
      _updateAdjacentSongs();
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
        _updateAdjacentSongs();
      });
    }
  }

  void _goToNextSong() {
    if (_nextSong != null && widget.isLeader) {
      _changeSong(_nextSong!);
    }
  }

  void _goToPreviousSong() {
    if (_previousSong != null && widget.isLeader) {
      _changeSong(_previousSong!);
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
        actions: [
          if (widget.isLeader)
            IconButton(
              icon: Icon(
                _showSongList ? Icons.close : Icons.queue_music,
                color: mochaMousse,
              ),
              onPressed: () {
                setState(() {
                  _showSongList = !_showSongList;
                });
              },
              tooltip: _showSongList ? "Fechar lista" : "Ver repertório",
            ),
        ],
      ),
      body: Column(
        children: [
          // Informações sobre a música atual, anterior e próxima
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                // Botão para música anterior (apenas para líder)
                if (widget.isLeader && _previousSong != null)
                  IconButton(
                    onPressed: _goToPreviousSong,
                    icon: const Icon(Icons.skip_previous, color: mochaMousse),
                    tooltip: "Música anterior",
                  ),

                // Informação sobre música atual
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Tocando agora:",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        _currentSong?["titulo"] ?? "Nenhuma música selecionada",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: mochaMousse,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Divisor vertical
                const SizedBox(width: 8),

                // Informação sobre próxima música
                if (_nextSong != null)
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Próxima:",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          _nextSong?["titulo"] ?? "",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                // Botão para próxima música (apenas para líder)
                if (widget.isLeader && _nextSong != null)
                  IconButton(
                    onPressed: _goToNextSong,
                    icon: const Icon(Icons.skip_next, color: mochaMousse),
                    tooltip: "Próxima música",
                  ),
              ],
            ),
          ),

          // Conteúdo principal - PDF ou lista de músicas
          Expanded(
            child: Row(
              children: [
                // Lista de músicas (condicional - só aparece quando solicitado)
                if (_showSongList && widget.isLeader)
                  Container(
                    width: 280,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(2, 0),
                        ),
                      ],
                    ),
                    child: _musicas.isEmpty
                        ? Center(
                      child: _repertorioId == null
                          ? const Text(
                        "Aguardando início da sessão...",
                        style: TextStyle(color: mochaMousse),
                      )
                          : const CircularProgressIndicator(color: mochaMousse),
                    )
                        : ListView.builder(
                      itemCount: _musicas.length,
                      itemBuilder: (context, index) {
                        final song = _musicas[index];
                        final bool isCurrentSong = _currentSong != null &&
                            song["idMusica"] == _currentSong!["idMusica"];

                        return Container(
                          color: isCurrentSong ? mochaMousse.withOpacity(0.1) : null,
                          child: ListTile(
                            title: Text(
                              song["titulo"] ?? "Sem título",
                              style: TextStyle(
                                fontWeight: isCurrentSong ? FontWeight.bold : FontWeight.normal,
                                color: isCurrentSong ? mochaMousse : null,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            leading: isCurrentSong
                                ? const Icon(Icons.play_arrow, color: mochaMousse)
                                : const Icon(Icons.music_note, color: Colors.grey),
                            trailing: ElevatedButton(
                              onPressed: () => _changeSong(song),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mochaMousse,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                minimumSize: const Size(60, 36),
                              ),
                              child: const Text("Tocar", style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                //Visualizador de PDF (ocupa tdo o espaço ou se ajusta conforme a lista)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: PdfViewer(
                      musicaId: _currentSong?["idMusica"],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Barra inferior com controles de navegação para o líder
      bottomNavigationBar: widget.isLeader
          ? Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Botão para mostrar/ocultar lista
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _showSongList = !_showSongList;
                });
              },
              icon: Icon(
                _showSongList ? Icons.playlist_remove : Icons.playlist_add,
                color: mochaMousse,
              ),
              label: Text(
                _showSongList ? "Ocultar Lista" : "Mostrar Lista",
                style: const TextStyle(color: mochaMousse),
              ),
            ),
            const SizedBox(width: 20),

            // Controles de navegação (anterior, próxima)
            Row(
              children: [
                // Botão para música anterior
                ElevatedButton.icon(
                  onPressed: _previousSong != null ? _goToPreviousSong : null,
                  icon: const Icon(Icons.skip_previous),
                  label: const Text("Anterior"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _previousSong != null ? mochaMousse : Colors.grey[400],
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                // Botão para próxima música
                ElevatedButton.icon(
                  onPressed: _nextSong != null ? _goToNextSong : null,
                  icon: const Icon(Icons.skip_next),
                  label: const Text("Próxima"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _nextSong != null ? mochaMousse : Colors.grey[400],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      )
          : null,
    );
  }
}