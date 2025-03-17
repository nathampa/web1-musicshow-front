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
  late ScaffoldMessengerState _scaffoldMessenger;
  bool _errorHandled = false; // Flag para evitar mensagens duplicadas
  bool _isNavigatingBack = false;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  @override
  void initState() {
    super.initState();
    _repertorioId = widget.repertorio?["idRepertorio"];
    _connectWebSocket();
    if (_repertorioId != null) {
      _loadMusicas();
    }
  }

  void _connectWebSocket() async {
    final token = await _getToken();
    if (token == null) {
      if (mounted) {
        _scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text("Token de autenticação não encontrado")),
        );
      }
      return;
    }

    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://127.0.0.1:8080/live-session?token=$token'),
      );

      _channel.stream.listen(
            (message) {
          final data = jsonDecode(message);
          String type = data['type'];
          if (type == "connection") {
            print("Conexão confirmada: ${data['message']}");
          } else if (type == "start-session" || type == "session-started") {
            _repertorioId = data['repertorioId'];
            _loadMusicas();
          } else if (type == "session-info") {
            _repertorioId = data['repertorioId'];
            _loadMusicas();
            if (data.containsKey('songData')) {
              setState(() {
                _currentSong = data['songData']['musica'] ?? data['songData'];
                _updateAdjacentSongs();
              });
            }
          } else if (type == "update-song" && data['bandaId'] == widget.banda["idBanda"]) {
            setState(() {
              _currentSong = data['songData'];
              _updateAdjacentSongs();
            });
          } else if (type == "session-ended" && data['bandaId'] == widget.banda["idBanda"]) {
            if (mounted && !_isNavigatingBack) {
              _isNavigatingBack = true;
              // Só exibe a mensagem se não for o líder
              if (!widget.isLeader) {
                _scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text("Sessão encerrada pelo líder")),
                );
              }
              Navigator.pop(context);
            }
          } else if (type == "error" && data['message'] == "Nenhuma sessão ativa para esta banda") {
            if (mounted) {
              _errorHandled = true; // Marca que o erro foi tratado
              _scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text("Nenhuma sessão ativa para esta banda")),
              );
              Navigator.pop(context);
            }
          }
        },
        onError: (error) {
          print("Erro no WebSocket: $error");
          if (mounted && !_errorHandled) {
            _scaffoldMessenger.showSnackBar(
              SnackBar(content: Text("Erro na conexão: $error")),
            );
          }
        },
        onDone: () {
          print("WebSocket fechado - Código: ${_channel.closeCode}, Motivo: ${_channel.closeReason}");
          if (mounted && !_errorHandled) {
            _scaffoldMessenger.showSnackBar(
              const SnackBar(content: Text("Conexão WebSocket encerrada")),
            );
          }
        },
      );

      if (widget.isLeader) {
        _channel.sink.add(jsonEncode({
          "type": "start-session",
          "bandaId": widget.banda["idBanda"],
          "repertorioId": widget.repertorio!["idRepertorio"],
          "message": "Sessão ao vivo iniciada",
        }));
      } else {
        _channel.sink.add(jsonEncode({
          "type": "join-session",
          "bandaId": widget.banda["idBanda"],
          "message": "Músico entrando na sessão",
        }));
      }
    } catch (e) {
      print("Exceção ao conectar ao WebSocket: $e");
      if (mounted) {
        _scaffoldMessenger.showSnackBar(
          SnackBar(content: Text("Falha ao conectar ao WebSocket: $e")),
        );
      }
    }
  }

  Future<void> _closeSession() async {
    try {
      //Adiciona uma flag para controlar se o canal já está fechando
      bool isClosing = false;

      if (widget.isLeader && !isClosing) {
        isClosing = true;
        _channel.sink.add(jsonEncode({
          "type": "end-session",
          "bandaId": widget.banda["idBanda"],
          "message": "Sessão ao vivo encerrada",
        }));
        //Aguarde um momento para garantir que a mensagem seja enviada
        await Future.delayed(const Duration(milliseconds: 200));
      }

      //Agora feche a conexão
      if (!isClosing) {
        _channel.sink.close(status.normalClosure);
      }
    } catch (e) {
      print("Erro ao fechar sessão: $e");
    }
  }

  Future<bool> _onWillPop() async {
    if (!_isNavigatingBack) {
      _isNavigatingBack = true;
      await _closeSession();
      return true;
    }
    return false;
  }

  void _updateAdjacentSongs() {
    if (_musicas.isEmpty || _currentSong == null) return;
    final currentIndex = _musicas.indexWhere((song) => song["idMusica"] == _currentSong!["idMusica"]);
    if (currentIndex == -1) return;
    setState(() {
      _nextSong = currentIndex < _musicas.length - 1 ? _musicas[currentIndex + 1] : null;
      _previousSong = currentIndex > 0 ? _musicas[currentIndex - 1] : null;
    });
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  void _loadMusicas() async {
    if (_repertorioId == null) return;
    try {
      final List<dynamic> musicasRaw = await apiService.getMusicasAtivasRepertorio(_repertorioId!);
      setState(() {
        _musicas = musicasRaw.map((item) => item as Map<String, dynamic>).toList();
        _updateAdjacentSongs();
      });
    } catch (e) {
      if (mounted) {
        _scaffoldMessenger.showSnackBar(
          SnackBar(content: Text("Erro ao carregar músicas: $e")),
        );
      }
    }
  }

  void _changeSong(Map<String, dynamic> song) {
    if (widget.isLeader) {
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
    if (_nextSong != null && widget.isLeader) _changeSong(_nextSong!);
  }

  void _goToPreviousSong() {
    if (_previousSong != null && widget.isLeader) _changeSong(_previousSong!);
  }

  @override
  void dispose() {
    _closeSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: mochaMousse),
            onPressed: () async {
              if (!_isNavigatingBack) {
                _isNavigatingBack = true;
                await _closeSession();
                if (mounted) Navigator.pop(context);
              }
            },
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
                onPressed: () => setState(() => _showSongList = !_showSongList),
              ),
          ],
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  if (widget.isLeader && _previousSong != null)
                    IconButton(
                      onPressed: _goToPreviousSong,
                      icon: const Icon(Icons.skip_previous, color: mochaMousse),
                    ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Tocando agora:", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(
                          _currentSong?["titulo"] ?? "Nenhuma música selecionada",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: mochaMousse),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_nextSong != null)
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Próxima:", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(
                            _nextSong?["titulo"] ?? "",
                            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  if (widget.isLeader && _nextSong != null)
                    IconButton(
                      onPressed: _goToNextSong,
                      icon: const Icon(Icons.skip_next, color: mochaMousse),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  if (_showSongList && widget.isLeader)
                    Container(
                      width: 280,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(2, 0))],
                      ),
                      child: _musicas.isEmpty
                          ? Center(
                        child: _repertorioId == null
                            ? const Text("Aguardando início da sessão...", style: TextStyle(color: mochaMousse))
                            : const CircularProgressIndicator(color: mochaMousse),
                      )
                          : ListView.builder(
                        itemCount: _musicas.length,
                        itemBuilder: (context, index) {
                          final song = _musicas[index];
                          final isCurrentSong = _currentSong != null && song["idMusica"] == _currentSong!["idMusica"];
                          return Container(
                            color: isCurrentSong ? mochaMousse.withOpacity(0.1) : null,
                            child: ListTile(
                              title: Text(
                                song["titulo"] ?? "Sem título",
                                style: TextStyle(
                                  fontWeight: isCurrentSong ? FontWeight.bold : FontWeight.normal,
                                  color: isCurrentSong ? mochaMousse : null,
                                ),
                              ),
                              leading: isCurrentSong
                                  ? const Icon(Icons.play_arrow, color: mochaMousse)
                                  : const Icon(Icons.music_note, color: Colors.grey),
                              trailing: ElevatedButton(
                                onPressed: () => _changeSong(song),
                                style: ElevatedButton.styleFrom(backgroundColor: mochaMousse),
                                child: const Text("Tocar", style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
                      ),
                      child: PdfViewer(musicaId: _currentSong?["idMusica"]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: widget.isLeader
            ? Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, -2))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () => setState(() => _showSongList = !_showSongList),
                icon: Icon(_showSongList ? Icons.playlist_remove : Icons.playlist_add, color: mochaMousse),
                label: Text(_showSongList ? "Ocultar Lista" : "Mostrar Lista", style: const TextStyle(color: mochaMousse)),
              ),
              const SizedBox(width: 20),
              Row(
                children: [
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
      ),
    );
  }
}