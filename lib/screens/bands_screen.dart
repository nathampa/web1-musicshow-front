import 'package:flutter/material.dart';
import '../services/api_service.dart';

class BandsScreen extends StatefulWidget {
  const BandsScreen({super.key});

  @override
  _BandsScreenState createState() => _BandsScreenState();
}

class _BandsScreenState extends State<BandsScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Map<String, dynamic>>> futureBands;

  @override
  void initState() {
    super.initState();
    futureBands = apiService.getUserBands();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Minhas Bandas",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: futureBands,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Erro: ${snapshot.error}",
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    "Nenhuma banda encontrada.",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                );
              }

              List<Map<String, dynamic>> bandas = snapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: bandas.length,
                itemBuilder: (context, index) {
                  final banda = bandas[index];
                  final String nomeBanda = banda["nome"] ?? "Nome Desconhecido";

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal[100],
                        child: const Icon(Icons.music_note, color: Colors.teal, size: 28),
                      ),
                      title: Text(
                        nomeBanda,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "ID: ${banda["idBanda"]} | Responsável: ${banda["idResponsavel"]}",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.teal),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Detalhes da Banda"),
                            content: Text("Nome: $nomeBanda\nID: ${banda["idBanda"]}\nResponsável: ${banda["idResponsavel"]}"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Fechar"),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
