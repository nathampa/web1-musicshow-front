import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class RepertorioDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> repertorio;
  final Map<String, dynamic> banda;

  const RepertorioDetailsScreen({super.key, required this.repertorio, required this.banda});

  @override
  _RepertorioDetailsScreenState createState() => _RepertorioDetailsScreenState();
}

class _RepertorioDetailsScreenState extends State<RepertorioDetailsScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Map<String, dynamic>>> _musicasFuture;
  final TextEditingController _musicIdController = TextEditingController();

  // Definindo a cor Mocha Mousse, igual à BandDetailsScreen
  static const Color mochaMousse = Color(0xFFA47864);

  Future<int?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  void _showAddMusicDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
            "Adicionar música ao repertório",
            style: TextStyle(
                fontSize: 20,
                color: mochaMousse,
                fontWeight: FontWeight.bold
            )
        ),
        content: TextField(
          controller: _musicIdController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "ID da música",
            labelStyle: TextStyle(color: Colors.black54),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: mochaMousse.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: mochaMousse.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: mochaMousse, width: 2),
            ),
            prefixIcon: const Icon(Icons.music_note, color: mochaMousse),
            filled: true,
            fillColor: mochaMousse.withOpacity(0.1),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _musicIdController.clear();
              Navigator.pop(context);
            },
            child: Text("Cancelar", style: TextStyle(color: Colors.black54, fontSize: 16)),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_musicIdController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Preencha o ID da música."),
                    backgroundColor: Colors.red.shade400,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
                return;
              }

              int? musicId = int.tryParse(_musicIdController.text);
              if (musicId != null) {
                bool success = await apiService.addMusicToRepertorio(widget.repertorio["idRepertorio"], musicId);
                if (success) {
                  Navigator.pop(context);
                  _reloadMusicas();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Música adicionada com sucesso!", style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.green.shade400,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Erro ao adicionar música."),
                      backgroundColor: Colors.red.shade400,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
                _musicIdController.clear();
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: mochaMousse,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text("Adicionar", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showRemoveMusicDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
            "Remover música do repertório",
            style: TextStyle(
                fontSize: 20,
                color: mochaMousse,
                fontWeight: FontWeight.bold
            )
        ),
        content: TextField(
          controller: _musicIdController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "ID da música",
            labelStyle: TextStyle(color: Colors.black54),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: mochaMousse.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: mochaMousse.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: mochaMousse, width: 2),
            ),
            prefixIcon: const Icon(Icons.music_off, color: mochaMousse),
            filled: true,
            fillColor: mochaMousse.withOpacity(0.1),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _musicIdController.clear();
              Navigator.pop(context);
            },
            child: Text("Cancelar", style: TextStyle(color: Colors.black54, fontSize: 16)),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_musicIdController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Preencha o ID da música."),
                    backgroundColor: Colors.red.shade400,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
                return;
              }

              int? musicId = int.tryParse(_musicIdController.text);
              if (musicId != null) {
                bool success = await apiService.removeMember(widget.repertorio["idRepertorio"], musicId);
                if (success) {
                  Navigator.pop(context);
                  _reloadMusicas();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Música removida com sucesso!", style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.green.shade400,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Erro ao remover música."),
                      backgroundColor: Colors.red.shade400,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
                _musicIdController.clear();
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red.shade400,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text("Remover", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showManageMusicsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
            "Gerenciar músicas",
            style: TextStyle(
                fontSize: 20,
                color: mochaMousse,
                fontWeight: FontWeight.bold
            )
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showAddMusicDialog();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: mochaMousse,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 20),
                  SizedBox(width: 8),
                  Text("Adicionar música", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showRemoveMusicDialog();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red.shade400,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.remove, size: 20),
                  SizedBox(width: 8),
                  Text("Remover música", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Fechar", style: TextStyle(color: Colors.black54, fontSize: 16)),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  void _reloadMusicas() {
    setState(() {
      _musicasFuture = apiService.getMusicasRepertorio(widget.repertorio["idRepertorio"]);
    });
  }

  @override
  void initState() {
    super.initState();
    _musicasFuture = apiService.getMusicasRepertorio(widget.repertorio["idRepertorio"]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int?>(
      future: _getUserId(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: mochaMousse.withOpacity(0.1),
            body: Center(child: CircularProgressIndicator(color: mochaMousse)),
          );
        }

        final int userId = snapshot.data!;
        final int idResponsavel = widget.banda["idResponsavel"];
        final bool isResponsavel = idResponsavel == userId;

        return Scaffold(
          appBar: AppBar(
            title: Text(
                widget.repertorio["nome"] ?? "Detalhes do Repertório",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white
                )
            ),
            backgroundColor: mochaMousse,
            centerTitle: true,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
          ),
          backgroundColor: mochaMousse.withOpacity(0.1),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Card superior com informações do repertório
                          Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: mochaMousse.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.library_music, color: mochaMousse),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Detalhes do Repertório",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: mochaMousse
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          "Repertório ${widget.repertorio["nome"]} | ID: ${widget.repertorio["idRepertorio"]}",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black54
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          // Lista de músicas
                          Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.music_note, color: mochaMousse),
                                      SizedBox(width: 8),
                                      Text(
                                          "Músicas do Repertório",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: mochaMousse
                                          )
                                      ),
                                    ],
                                  ),
                                  Divider(color: mochaMousse.withOpacity(0.2), thickness: 1.5),
                                  SizedBox(height: 8),
                                  SizedBox(
                                    height: 400,
                                    child: FutureBuilder<List<Map<String, dynamic>>>(
                                      future: _musicasFuture,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return Center(child: CircularProgressIndicator(color: mochaMousse));
                                        } else if (snapshot.hasError) {
                                          String errorMessage = snapshot.error.toString();
                                          if (errorMessage.contains("O repertório não possui músicas")) {
                                            return Center(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.music_off, color: Colors.black38, size: 48),
                                                  SizedBox(height: 16),
                                                  Text("O repertório não possui músicas.", style: TextStyle(color: Colors.black54, fontSize: 16)),
                                                  SizedBox(height: 8),
                                                  isResponsavel ? Text("Use o botão + abaixo para adicionar músicas.", style: TextStyle(color: Colors.black38, fontSize: 14)) : SizedBox(),
                                                ],
                                              ),
                                            );
                                          } else {
                                            return Center(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
                                                  SizedBox(height: 16),
                                                  Text("Erro ao carregar músicas.", style: TextStyle(color: Colors.red.shade400)),
                                                  SizedBox(height: 8),
                                                  Text("${snapshot.error}", style: TextStyle(color: Colors.black54, fontSize: 12)),
                                                ],
                                              ),
                                            );
                                          }
                                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                          return Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.music_off, color: Colors.black38, size: 48),
                                                SizedBox(height: 16),
                                                Text("Nenhuma música encontrada.", style: TextStyle(color: Colors.black54, fontSize: 16)),
                                                SizedBox(height: 8),
                                                isResponsavel ? Text("Use o botão + abaixo para adicionar músicas.", style: TextStyle(color: Colors.black38, fontSize: 14)) : SizedBox(),
                                              ],
                                            ),
                                          );
                                        }

                                        return ListView.separated(
                                          itemCount: snapshot.data!.length,
                                          separatorBuilder: (context, index) => Divider(height: 1, color: mochaMousse.withOpacity(0.2)),
                                          itemBuilder: (context, index) {
                                            final musica = snapshot.data![index];
                                            return ListTile(
                                              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                              leading: CircleAvatar(
                                                backgroundColor: mochaMousse.withOpacity(0.1),
                                                child: Icon(Icons.music_note, color: mochaMousse),
                                              ),
                                              title: Text(
                                                musica["titulo"] ?? "Música desconhecida",
                                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                                              ),
                                              subtitle: Text(
                                                "ID: ${musica["idMusica"]}",
                                                style: TextStyle(fontSize: 12, color: Colors.black54),
                                              ),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              hoverColor: mochaMousse.withOpacity(0.1),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          floatingActionButton: isResponsavel ? FloatingActionButton(
            onPressed: _showManageMusicsDialog,
            backgroundColor: mochaMousse,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.add, color: Colors.white),
          ) : null,
        );
      },
    );
  }
}