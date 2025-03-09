import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MyMusicsScreen extends StatefulWidget {
  const MyMusicsScreen({super.key});

  @override
  _MyMusicsScreenState createState() => _MyMusicsScreenState();
}

class _MyMusicsScreenState extends State<MyMusicsScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Map<String, dynamic>>> _musicsFuture;

  @override
  void initState() {
    super.initState();
    _musicsFuture = apiService.getMinhasMusicas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Minhas Músicas",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
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
              const Icon(Icons.music_note, size: 80, color: Colors.teal),
              const SizedBox(height: 20),
              const Text(
                "Minhas Músicas",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              const SizedBox(height: 12),
              const Text(
                "Aqui estão todas as músicas associadas a você.",
                style: TextStyle(fontSize: 18, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _musicsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      String errorMessage = snapshot.error.toString();
                      if (errorMessage.contains("Você ainda não tem músicas cadastradas")) {
                        return const Center(
                          child: Text(
                            "Você ainda não tem músicas cadastradas.",
                            style: TextStyle(fontSize: 18, color: Colors.black54),
                          ),
                        );
                      } else {
                        return const Center(
                          child: Text(
                            "Erro ao carregar suas músicas.",
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
                        final music = snapshot.data![index];
                        return ListTile(
                          leading: const Icon(Icons.music_note, color: Colors.teal),
                          title: Text(music["titulo"] ?? "Música desconhecida"),
                          subtitle: Text("Artista: ${music["artista"] ?? "Desconhecido"}"),
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
