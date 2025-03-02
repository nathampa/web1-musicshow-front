import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'band_details_screen.dart';


class BandsScreen extends StatefulWidget {
  const BandsScreen({super.key});

  @override
  _BandsScreenState createState() => _BandsScreenState();
}

class _BandsScreenState extends State<BandsScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Map<String, dynamic>>> futureBands;
  final TextEditingController _bandaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBands();
  }

  void _loadBands() {
    setState(() {
      futureBands = apiService.getUserBands();
    });
  }

  void _createBanda() async {
    String nomeBanda = _bandaController.text.trim();
    if (nomeBanda.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dê um nome à banda.")),
      );
      return;
    }
    bool success = await apiService.createBanda(nomeBanda);
    if (success) {
      Navigator.pop(context);
      _bandaController.clear();
      _loadBands(); // Atualizar a lista de bandas
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Banda criada com sucesso!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao criar a banda.")),
      );
    }
  }

  void _showCreateBandaDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.teal[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Criar Nova Banda", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _bandaController,
          decoration: InputDecoration(
            labelText: "Nome da banda",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: const Icon(Icons.music_note, color: Colors.teal),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _bandaController.clear();
              Navigator.pop(context);
            },
            child: const Text("Cancelar", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: _createBanda,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Criar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
      backgroundColor: Colors.teal[50],
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BandDetailsScreen(banda: banda),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateBandaDialog,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
