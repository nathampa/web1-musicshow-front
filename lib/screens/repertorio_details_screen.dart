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

  Future<int?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  void _showManageMusicsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController musicIdController = TextEditingController();

        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Gerenciar músicas do repertório", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: musicIdController,
                decoration: InputDecoration(
                    labelText: "ID da nova música",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.person_outline, color: Colors.teal)
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  int? musicId = int.tryParse(musicIdController.text);

                  if(musicIdController.text.isEmpty){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Preencha o ID.")),
                    );
                    return;
                  }

                  if (musicId != null) {
                    await apiService.addMusicToRepertorio(widget.repertorio["idRepertorio"], musicId);

                    Navigator.pop(context);
                    ///Recarrega a lista de músicas
                    setState(() {
                      _musicasFuture = apiService.getMusicasRepertorio(widget.repertorio["idRepertorio"]);
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Adicionar música", style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  int? musicId = int.tryParse(musicIdController.text);

                  if(musicIdController.text.isEmpty){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Preencha o ID.")),
                    );
                    return;
                  }

                  if (musicId != null) {
                    await apiService.removeMember(widget.repertorio["idRepertorio"], musicId);
                    Navigator.pop(context);
                    ///Recarrega a lista de músicas
                    setState(() {
                      _musicasFuture = apiService.getMusicasRepertorio(widget.repertorio["idRepertorio"]);
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Remover música", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _musicasFuture = apiService.getMusicasRepertorio(widget.repertorio["idRepertorio"]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int?> (
      future: _getUserId(),
      builder: (context, snapshot){
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final int userId = snapshot.data!;
        final int idResponsavel = widget.banda["idResponsavel"];
        final bool isResponsavel = idResponsavel == userId;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.repertorio["nome"] ?? "Detalhes do Repertório",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            backgroundColor: Colors.teal,
            centerTitle: true,
            elevation: 6,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            actions: isResponsavel
                ? [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == "gerenciarMusicas") {
                    _showManageMusicsDialog(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: "gerenciarMusicas",
                    child: Text("Gerenciar músicas do repertório"),
                  )
                ],
              )
            ]
                : null,

          ),
          backgroundColor: Colors.teal[50],
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.library_music, size: 80, color: Colors.teal),
                  const SizedBox(height: 20),
                  Text(
                    widget.repertorio["nome"] ?? "Nome desconhecido",
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "ID: ${widget.repertorio["idRepertorio"]}",
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Músicas do Repertório:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _musicasFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          //Captura a exceção e verifica se é o erro de 404
                          String errorMessage = snapshot.error.toString();
                          if (errorMessage.contains("O repertório não possui músicas")) {
                            return const Center(
                              child: Text(
                                "O repertório não possui músicas.",
                                style: TextStyle(fontSize: 18, color: Colors.black54),
                              ),
                            );
                          } else {
                            return const Center(
                              child: Text(
                                "Erro ao carregar músicas.",
                                style: TextStyle(fontSize: 18, color: Colors.red),
                              ),
                            );
                          }
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text(
                              "Nenhuma música encontrada.",
                              style: TextStyle(fontSize: 18, color: Colors.black54),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final musica = snapshot.data![index];
                            return ListTile(
                              leading: const Icon(Icons.music_note, color: Colors.teal),
                              title: Text(musica["titulo"] ?? "Música desconhecida"),
                              subtitle: Text("ID: ${musica["idMusica"] ?? "Desconhecido"}"),
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
        );
      }
    );
  }
}
