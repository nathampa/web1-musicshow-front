import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'repertorio_details_screen.dart';

class BandDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> banda;
  BandDetailsScreen({super.key, required this.banda});

  @override
  _BandDetailsScreenState createState() => _BandDetailsScreenState();
}

class _BandDetailsScreenState extends State<BandDetailsScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Map<String, dynamic>>> _membrosFuture;
  late Future<List<Map<String, dynamic>>> _repertoriosFuture;

  // Definindo a cor Mocha Mousse
  static const Color mochaMousse = Color(0xFFA47864);

  @override
  void initState() {
    super.initState();
    _membrosFuture = apiService.getBandMembers(widget.banda["idBanda"]);
    _repertoriosFuture = apiService.getBandRepertorios(widget.banda["idBanda"]);
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
              "Gerenciar membros",
              style: TextStyle(
                  fontSize: 20,
                  color: mochaMousse,
                  fontWeight: FontWeight.bold
              )
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: memberIdController,
                decoration: InputDecoration(
                  labelText: "ID do novo membro",
                  labelStyle: TextStyle(color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: mochaMousse.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: mochaMousse.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: mochaMousse, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.person_outline, color: mochaMousse),
                  filled: true,
                  fillColor: mochaMousse.withOpacity(0.1),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        int? memberId = int.tryParse(memberIdController.text);

                        if(memberIdController.text.isEmpty){
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Preencha o ID."),
                              backgroundColor: Colors.red.shade400,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
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
                        foregroundColor: Colors.white,
                        backgroundColor: mochaMousse,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: Icon(Icons.add),
                      label: Text("Adicionar", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        int? memberId = int.tryParse(memberIdController.text);

                        if(memberIdController.text.isEmpty){
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Preencha o ID."),
                              backgroundColor: Colors.red.shade400,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
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
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red.shade400,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: Icon(Icons.remove),
                      label: Text("Remover", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar", style: TextStyle(color: Colors.black54, fontSize: 16)),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
            "Criar novo repertório",
            style: TextStyle(
                fontSize: 20,
                color: mochaMousse,
                fontWeight: FontWeight.bold
            )
        ),
        content: TextField(
          controller: _createRepertorioController,
          decoration: InputDecoration(
            labelText: "Nome do repertório",
            labelStyle: TextStyle(color: Colors.black54),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: mochaMousse.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: mochaMousse.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: mochaMousse, width: 2),
            ),
            prefixIcon: const Icon(Icons.article_outlined, color: mochaMousse),
            filled: true,
            fillColor: mochaMousse.withOpacity(0.1),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar", style: TextStyle(color: Colors.black54, fontSize: 16)),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if(_createRepertorioController.text.isEmpty){
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Preencha o nome do repertório"),
                    backgroundColor: Colors.red.shade400,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
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
                    backgroundColor: message.contains("sucesso") ? Colors.green.shade400 : Colors.red.shade400,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: mochaMousse,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text("Criar", style: TextStyle(fontSize: 16)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
            "Remover repertório",
            style: TextStyle(
                fontSize: 20,
                color: mochaMousse,
                fontWeight: FontWeight.bold
            )
        ),
        content: TextField(
          controller: _deleteRepertorioController,
          decoration: InputDecoration(
            labelText: "ID do repertório",
            labelStyle: TextStyle(color: Colors.black54),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: mochaMousse.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: mochaMousse.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: mochaMousse, width: 2),
            ),
            prefixIcon: const Icon(Icons.article_outlined, color: mochaMousse),
            filled: true,
            fillColor: mochaMousse.withOpacity(0.1),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar", style: TextStyle(color: Colors.black54, fontSize: 16)),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if(_deleteRepertorioController.text.isEmpty){
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Preencha o ID do repertório"),
                    backgroundColor: Colors.red.shade400,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
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
                    backgroundColor: message.contains("sucesso") ? Colors.green.shade400 : Colors.red.shade400,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red.shade400,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text("Remover", style: TextStyle(fontSize: 16)),
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
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: mochaMousse,
              ),
            ),
          );
        }

        final int userId = snapshot.data!;
        final int idResponsavel = widget.banda["idResponsavel"];
        final bool isResponsavel = idResponsavel == userId;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.banda["nome"] ?? "Detalhes da banda",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white
              ),
            ),
            backgroundColor: mochaMousse,
            centerTitle: true,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            actions: isResponsavel
                ? [
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.white),
                offset: Offset(0, 45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.white,
                elevation: 3,
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
                  PopupMenuItem(
                    value: "gerenciar",
                    child: Row(
                      children: [
                        Icon(Icons.group, color: mochaMousse, size: 18),
                        SizedBox(width: 12),
                        Text("Gerenciar membros"),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: "createRepertorio",
                    child: Row(
                      children: [
                        Icon(Icons.add_circle, color: mochaMousse, size: 18),
                        SizedBox(width: 12),
                        Text("Adicionar repertório"),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: "deleteRepertorio",
                    child: Row(
                      children: [
                        Icon(Icons.remove_circle, color: Colors.red.shade400, size: 18),
                        SizedBox(width: 12),
                        Text("Remover repertório"),
                      ],
                    ),
                  ),
                ],
              )
            ]
                : null,
          ),
          backgroundColor: mochaMousse.withOpacity(0.1),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Layout responsivo baseado na largura da tela
                final bool isWideScreen = constraints.maxWidth > 600;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Card de detalhes da banda
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: mochaMousse.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.music_note, size: 60, color: mochaMousse),
                              ),
                              SizedBox(height: 16),
                              Text(
                                widget.banda["nome"] ?? "Nome desconhecido",
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: mochaMousse
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: mochaMousse.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "ID: ${widget.banda["idBanda"]}",
                                  style: TextStyle(fontSize: 14, color: mochaMousse),
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "Responsável: ${widget.banda["idResponsavel"]}",
                                style: TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Layout responsivo para listas
                      isWideScreen
                          ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Lista de Membros
                          Expanded(
                            child: _buildMembrosCard(),
                          ),
                          SizedBox(width: 16),
                          // Lista de Repertórios
                          Expanded(
                            child: _buildRepertoriosCard(),
                          ),
                        ],
                      )
                          : Column(
                        children: [
                          _buildMembrosCard(),
                          SizedBox(height: 16),
                          _buildRepertoriosCard(),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildMembrosCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.group, color: mochaMousse),
                SizedBox(width: 8),
                Text(
                    "Membros da Banda",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: mochaMousse
                    )
                ),
              ],
            ),
            Divider(color: mochaMousse.withOpacity(0.2), thickness: 1.5),
            SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _membrosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: mochaMousse));
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
                          SizedBox(height: 16),
                          Text("Erro ao carregar membros.", style: TextStyle(color: Colors.red.shade400)),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_off, color: Colors.black38, size: 48),
                          SizedBox(height: 16),
                          Text("Nenhum membro encontrado.", style: TextStyle(color: Colors.black54)),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: snapshot.data!.length,
                    separatorBuilder: (context, index) => Divider(height: 1, color: mochaMousse.withOpacity(0.2)),
                    itemBuilder: (context, index) {
                      final membro = snapshot.data![index];
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        leading: CircleAvatar(
                          backgroundColor: mochaMousse.withOpacity(0.1),
                          child: Icon(Icons.person, color: mochaMousse),
                        ),
                        title: Text(
                          membro["nome"] ?? "Usuário desconhecido",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          "ID: ${membro["idUsuario"]}",
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        hoverColor: mochaMousse.withOpacity(0.1),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepertoriosCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.library_music, color: mochaMousse),
                SizedBox(width: 8),
                Text(
                    "Repertórios da Banda",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: mochaMousse
                    )
                ),
              ],
            ),
            Divider(color: mochaMousse.withOpacity(0.2), thickness: 1.5),
            SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _repertoriosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: mochaMousse));
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
                          SizedBox(height: 16),
                          Text("Erro ao carregar repertórios.", style: TextStyle(color: Colors.red.shade400)),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.queue_music, color: Colors.black38, size: 48),
                          SizedBox(height: 16),
                          Text("Nenhum repertório encontrado.", style: TextStyle(color: Colors.black54)),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: snapshot.data!.length,
                    separatorBuilder: (context, index) => Divider(height: 1, color: mochaMousse.withOpacity(0.2)),
                    itemBuilder: (context, index) {
                      final repertorio = snapshot.data![index];
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        leading: CircleAvatar(
                          backgroundColor: mochaMousse.withOpacity(0.1),
                          child: Icon(Icons.music_note, color: mochaMousse),
                        ),
                        title: Text(
                          repertorio["nome"] ?? "Repertório desconhecido",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          "ID: ${repertorio["idRepertorio"]}",
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        trailing: Container(
                          decoration: BoxDecoration(
                            color: mochaMousse.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(Icons.arrow_forward, size: 16, color: mochaMousse),
                          ),
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        hoverColor: mochaMousse.withOpacity(0.1),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RepertorioDetailsScreen(repertorio: repertorio, banda: widget.banda),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}