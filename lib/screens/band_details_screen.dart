import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BandDetailsScreen extends StatelessWidget {
  final ApiService apiService = ApiService();
  final Map<String, dynamic> banda;

  BandDetailsScreen({super.key, required this.banda});

  Future<int?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  void _showManageMembersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController memberIdController = TextEditingController();

        return AlertDialog(
          title: const Text("Gerenciar Membros"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: memberIdController,
                decoration: const InputDecoration(hintText: "ID do novo membro"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  int? memberId = int.tryParse(memberIdController.text);
                  if (memberId != null) {
                    await apiService.addMember(banda["idBanda"], memberId);
                    Navigator.pop(context);
                  }
                },
                child: const Text("Adicionar Membro"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  int? memberId = int.tryParse(memberIdController.text);
                  if (memberId != null) {
                    await apiService.removeMember(banda["idBanda"], memberId);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Remover Membro"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Fechar"),
            ),
          ],
        );
      },
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
