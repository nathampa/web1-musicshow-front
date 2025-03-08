import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RepertorioDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> repertorio;

  const RepertorioDetailsScreen({super.key, required this.repertorio});

  @override
  _RepertorioDetailsScreenState createState() => _RepertorioDetailsScreenState();
}

class _RepertorioDetailsScreenState extends State<RepertorioDetailsScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Map<String, dynamic>>> _musicasFuture;

  @override
  void initState() {
    super.initState();
    _musicasFuture = apiService.getMusicasRepertorio(widget.repertorio["idRepertorio"]);
  }

  @override
  Widget build(BuildContext context) {
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
                          subtitle: Text("Artista: ${musica["artista"] ?? "Desconhecido"}"),
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
}
