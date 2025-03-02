import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BandDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> banda;

  const BandDetailsScreen({super.key, required this.banda});

  Future<int?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  void _showManageMembersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Gerenciar Membros"),
        content: const Text("Aqui o responsável poderá adicionar ou remover membros."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fechar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int?>(
      future: _getUserId(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final int userId = snapshot.data!;
        final int idResponsavel = banda["idResponsavel"];
        final bool isResponsavel = idResponsavel == userId;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              banda["nome"] ?? "Detalhes da Banda",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: Colors.teal,
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
                  Text(
                    banda["nome"] ?? "Nome Desconhecido",
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "ID: ${banda["idBanda"]}\nResponsável: ${banda["idResponsavel"]}",
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: isResponsavel
              ? FloatingActionButton(
            onPressed: () => _showManageMembersDialog(context),
            backgroundColor: Colors.teal,
            child: const Icon(Icons.edit, color: Colors.white, size: 30),
          )
              : null,
        );
      },
    );
  }
}
