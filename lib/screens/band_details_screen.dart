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
  static const Color backgroundColor = Color(0xFFF8F5F3);

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
          backgroundColor: Color(0xFFF8F5F3), // Usando o mesmo backgroundColor da HomeScreen
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool isWideScreen = constraints.maxWidth > 600;

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: CustomScrollView(
                      slivers: [
                        // Custom App Bar
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () => Navigator.pop(context),
                                  borderRadius: BorderRadius.circular(50),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(50),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.arrow_back, color: mochaMousse, size: 24),
                                  ),
                                ),
                                Text(
                                  widget.banda["nome"] ?? "Detalhes da banda",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: mochaMousse,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(50),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.music_note, color: mochaMousse, size: 24),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Cabeçalho da banda
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container(
                              padding: EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [mochaMousse, mochaMousse.withOpacity(0.8)],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: mochaMousse.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    right: -20,
                                    bottom: -20,
                                    child: Icon(
                                      Icons.music_note,
                                      size: 150,
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.music_note, size: 40, color: Colors.white),
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        widget.banda["nome"] ?? "Nome desconhecido",
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              "ID: ${widget.banda["idBanda"]}",
                                              style: TextStyle(fontSize: 14, color: Colors.white),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.person, color: Colors.white, size: 14),
                                                SizedBox(width: 4),
                                                Text(
                                                  "Resp: ${widget.banda["idResponsavel"]}",
                                                  style: TextStyle(fontSize: 14, color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Adicionar os botões de controle apenas para o responsável
                                      if (isResponsavel) ...[
                                        SizedBox(height: 24),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            _buildActionButton(
                                              icon: Icons.group,
                                              label: "Gerenciar\nMembros",
                                              onTap: () => _showManageMembersDialog(context),
                                            ),
                                            SizedBox(width: 16),
                                            _buildActionButton(
                                              icon: Icons.add_circle,
                                              label: "Adicionar\nRepertório",
                                              onTap: () => _showCreateRepertorioDialog(context),
                                            ),
                                            SizedBox(width: 16),
                                            _buildActionButton(
                                              icon: Icons.remove_circle,
                                              label: "Remover\nRepertório",
                                              color: Colors.red.shade400,
                                              onTap: () => _showDeleteRepertorioDialog(context),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Título da seção Membros
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: mochaMousse.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.group, color: mochaMousse, size: 20),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  "Membros da Banda",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey.withOpacity(0.3),
                                    thickness: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Lista de Membros
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              height: 250,
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

                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: ListView.separated(
                                      padding: EdgeInsets.all(2),
                                      itemCount: snapshot.data!.length,
                                      separatorBuilder: (context, index) => Divider(height: 1, color: mochaMousse.withOpacity(0.1)),
                                      itemBuilder: (context, index) {
                                        final membro = snapshot.data![index];
                                        return ListTile(
                                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                          leading: Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: mochaMousse.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(Icons.person, color: mochaMousse, size: 24),
                                          ),
                                          title: Text(
                                            membro["nome"] ?? "Usuário desconhecido",
                                            style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                                          ),
                                          subtitle: Text(
                                            "ID: ${membro["idUsuario"]}",
                                            style: TextStyle(fontSize: 12, color: Colors.black54),
                                          ),
                                          trailing: isResponsavel && membro["idUsuario"] != userId ?
                                          Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade400.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(Icons.remove_circle_outline, color: Colors.red.shade400, size: 16),
                                          ) : null,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          hoverColor: mochaMousse.withOpacity(0.05),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        // Título da seção Repertórios
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: mochaMousse.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.library_music, color: mochaMousse, size: 20),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  "Repertórios da Banda",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey.withOpacity(0.3),
                                    thickness: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Repertórios da Banda
                        SliverPadding(
                          padding: EdgeInsets.only(bottom: 24, left: 16, right: 16),
                          sliver: SliverToBoxAdapter(
                            child: FutureBuilder<List<Map<String, dynamic>>>(
                              future: _repertoriosFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Container(
                                    height: 250,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(child: CircularProgressIndicator(color: mochaMousse)),
                                  );
                                } else if (snapshot.hasError) {
                                  return Container(
                                    height: 250,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
                                          SizedBox(height: 16),
                                          Text("Erro ao carregar repertórios.", style: TextStyle(color: Colors.red.shade400)),
                                        ],
                                      ),
                                    ),
                                  );
                                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return Container(
                                    height: 250,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.queue_music, color: Colors.black38, size: 48),
                                          SizedBox(height: 16),
                                          Text("Nenhum repertório encontrado.", style: TextStyle(color: Colors.black54)),
                                          if (isResponsavel) ...[
                                            SizedBox(height: 16),
                                            ElevatedButton.icon(
                                              onPressed: () => _showCreateRepertorioDialog(context),
                                              icon: Icon(Icons.add, size: 18),
                                              label: Text("Criar Repertório"),
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                backgroundColor: mochaMousse,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                // Grid layout para telas largas, lista para telas estreitas
                                if (isWideScreen) {
                                  return GridView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 1.5,
                                    ),
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, index) {
                                      final repertorio = snapshot.data![index];
                                      return _buildRepertorioCard(context, repertorio);
                                    },
                                  );
                                } else {
                                  return ListView.separated(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: snapshot.data!.length,
                                    separatorBuilder: (context, index) => SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final repertorio = snapshot.data![index];
                                      return _buildRepertorioCard(context, repertorio);
                                    },
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                  icon,
                  color: color ?? Colors.white,
                  size: 20
              ),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepertorioCard(BuildContext context, Map<String, dynamic> repertorio) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RepertorioDetailsScreen(repertorio: repertorio, banda: widget.banda),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: mochaMousse.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.music_note, color: mochaMousse, size: 20),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          repertorio["nome"] ?? "Repertório desconhecido",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          "ID: ${repertorio["idRepertorio"]}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: mochaMousse.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Ver detalhes",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: mochaMousse,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 12, color: mochaMousse),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}