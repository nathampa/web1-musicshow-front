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

  void _showCreateRepertorioDialog(BuildContext context) {
    final TextEditingController _createRepertorioController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Criar Novo Repertório"),
        content: TextField(
          controller: _createRepertorioController,
          decoration: const InputDecoration(hintText: "Nome do repertório"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              String nomeRepertorio = _createRepertorioController.text.trim();
              if (nomeRepertorio.isNotEmpty) {
                String message = await apiService.createRepertorio(banda["idBanda"], nomeRepertorio);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: message.contains("sucesso") ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text("Criar"),
          ),
        ],
      ),
    );
  }

  void _showDeleteRepertorioDialog(BuildContext context) {
    final TextEditingController _deleteRepertorioController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remover Repertório"),
        content: TextField(
          controller: _deleteRepertorioController,
          decoration: const InputDecoration(hintText: "ID do repertório"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              int? idRepertorio = int.tryParse(_deleteRepertorioController.text);
              if (idRepertorio != null) {
                String message = await apiService.deleteRepertorio(idRepertorio);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: message.contains("sucesso") ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text("Criar"),
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
            backgroundColor: Colors.teal,
            centerTitle: true,
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            actions: isResponsavel
                ? [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == "gerenciar") {
                    _showManageMembersDialog(context);
                  } else if (value == "createRepertorio") {
                    _showCreateRepertorioDialog(context);
                  }else if (value == "deleteRepertorio") {
                    _showDeleteRepertorioDialog(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: "gerenciar",
                    child: Text("Gerenciar Membros"),
                  ),
                  const PopupMenuItem(
                    value: "createRepertorio",
                    child: Text("Adicionar Repertório"),
                  ),
                  const PopupMenuItem(
                    value: "deleteRepertorio",
                    child: Text("Apagar Repertório"),
                  ),
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
        );
      },
    );
  }
}
