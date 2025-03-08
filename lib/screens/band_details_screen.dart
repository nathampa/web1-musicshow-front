import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BandDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> banda;
  BandDetailsScreen({super.key, required this.banda});

  @override
  _BandDetailsScreenState createState() => _BandDetailsScreenState();
}

class _BandDetailsScreenState extends State<BandDetailsScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Map<String, dynamic>>> _membrosFuture;
  late Future<List<Map<String, dynamic>>> _repertoriosFuture; // ✅ Adicionado

  @override
  void initState() {
    super.initState();
    _membrosFuture = apiService.getBandMembers(widget.banda["idBanda"]);
    _repertoriosFuture = apiService.getBandRepertorios(widget.banda["idBanda"]); // ✅ Carregar repertórios
  }

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
                    await apiService.addMember(widget.banda["idBanda"], memberId);
                    Navigator.pop(context);
                    ///Recarrega a lista de membros
                    setState(() {
                      _membrosFuture = apiService.getBandMembers(widget.banda["idBanda"]);
                    });
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
                    await apiService.removeMember(widget.banda["idBanda"], memberId);
                    Navigator.pop(context);
                    ///Recarrega a lista de membros
                    setState(() {
                      _membrosFuture = apiService.getBandMembers(widget.banda["idBanda"]);
                    });
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
                String message = await apiService.createRepertorio(widget.banda["idBanda"], nomeRepertorio);
                Navigator.pop(context);
                setState(() {
                  _repertoriosFuture = apiService.getBandRepertorios(widget.banda["idBanda"]);
                });
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
                setState(() {
                  _repertoriosFuture = apiService.getBandRepertorios(widget.banda["idBanda"]);
                });
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
        final int idResponsavel = widget.banda["idResponsavel"];
        final bool isResponsavel = idResponsavel == userId;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.banda["nome"] ?? "Detalhes da banda",
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
                  } else if (value == "deleteRepertorio") {
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
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // ✅ Nome da Banda, ID da Banda e ID do Responsável (Mantido)
                const Icon(Icons.music_note, size: 80, color: Colors.teal),
                const SizedBox(height: 20),
                Text(
                  widget.banda["nome"] ?? "Nome desconhecido",
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
                const SizedBox(height: 12),
                Text(
                  "ID: ${widget.banda["idBanda"]}\nResponsável: ${widget.banda["idResponsavel"]}",
                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // 🔹 CENTRALIZAÇÃO
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Centraliza horizontalmente
                    crossAxisAlignment: CrossAxisAlignment.center, // Centraliza verticalmente
                    children: [
                      // 🔹 Lista de Membros
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("Membros da Banda:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 400, // Altura fixa para evitar overflow
                              child: FutureBuilder<List<Map<String, dynamic>>>(
                                future: _membrosFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return const Center(child: Text("Erro ao carregar membros."));
                                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                    return const Center(child: Text("Nenhum membro encontrado."));
                                  }

                                  return ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, index) {
                                      final membro = snapshot.data![index];
                                      return ListTile(
                                        leading: const Icon(Icons.person, color: Colors.teal),
                                        title: Text(membro["nome"] ?? "Usuário desconhecido"),
                                        subtitle: Text("ID: ${membro["idUsuario"]}"),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 20), // Espaço entre as listas

                      // 🔹 Lista de Repertórios
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("Repertórios da Banda:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 400, // Altura fixa para evitar overflow
                              child: FutureBuilder<List<Map<String, dynamic>>>(
                                future: _repertoriosFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return const Center(child: Text("Erro ao carregar repertórios."));
                                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                    return const Center(child: Text("Nenhum repertório encontrado."));
                                  }

                                  return ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, index) {
                                      final repertorio = snapshot.data![index];
                                      return ListTile(
                                        leading: const Icon(Icons.library_music, color: Colors.teal),
                                        title: Text(repertorio["nome"] ?? "Repertório desconhecido"),
                                        subtitle: Text("ID: ${repertorio["idRepertorio"]}"),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
