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
          backgroundColor: Colors.white,
          title: const Text("Gerenciar membros", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: memberIdController,
                decoration: InputDecoration(
                    labelText: "ID do novo membro",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.person_outline, color: Colors.teal)
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  int? memberId = int.tryParse(memberIdController.text);

                  if(memberIdController.text.isEmpty){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Preencha o ID.")),
                    );
                    return;
                  }

                  if (memberId != null) {
                    await apiService.addMember(banda["idBanda"], memberId);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Adicionar membro", style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  int? memberId = int.tryParse(memberIdController.text);

                  if(memberIdController.text.isEmpty){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Preencha o ID.")),
                    );
                    return;
                  }

                  if (memberId != null) {
                    await apiService.removeMember(banda["idBanda"], memberId);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Remover membro", style: TextStyle(color: Colors.white)),
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

  void _showCreateRepertorioDialog(BuildContext context) {
    final TextEditingController _createRepertorioController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Criar novo repertório", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _createRepertorioController,
          decoration: InputDecoration(
            labelText: "Nome do repertório",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: const Icon(Icons.article_outlined, color: Colors.teal),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () async {
              if(_createRepertorioController.text.isEmpty){
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Preencha o nome do repertório")),
                );
                return;
              }else{
                String nomeRepertorio = _createRepertorioController.text.trim();
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

  void _showDeleteRepertorioDialog(BuildContext context) {
    final TextEditingController _deleteRepertorioController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Remover repertório"),
        content: TextField(
          controller: _deleteRepertorioController,
          decoration: InputDecoration(
            labelText: "ID do repertório",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: const Icon(Icons.article_outlined, color: Colors.teal),),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () async {
              if(_deleteRepertorioController.text.isEmpty){
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Preencha o ID do repertório")),
                );
                return;
              }

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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Remover", style: TextStyle(color: Colors.white)),
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
              banda["nome"] ?? "Detalhes da banda",
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
                    child: Text("Gerenciar membros"),
                  ),
                  const PopupMenuItem(
                    value: "createRepertorio",
                    child: Text("Adicionar repertório"),
                  ),
                  const PopupMenuItem(
                    value: "deleteRepertorio",
                    child: Text("Remover repertório"),
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
                    banda["nome"] ?? "Nome desconhecido",
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
