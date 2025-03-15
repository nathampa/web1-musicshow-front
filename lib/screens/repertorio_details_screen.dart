import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/screens/pdf_viewer_screen.dart';
import '../services/api_service.dart';

class RepertorioDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> repertorio;
  final Map<String, dynamic> banda;

  const RepertorioDetailsScreen({super.key, required this.repertorio, required this.banda});

  @override
  _RepertorioDetailsScreenState createState() => _RepertorioDetailsScreenState();
}

class _RepertorioDetailsScreenState extends State<RepertorioDetailsScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Map<String, dynamic>>> _musicasFuture;
  final TextEditingController _musicIdController = TextEditingController();

  // Definindo a cor Mocha Mousse, igual à HomeScreen
  static const Color mochaMousse = Color(0xFFA47864);
  static const Color backgroundColor = Color(0xFFF8F5F3);

  Future<int?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  void _showAddMusicDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
            "Adicionar música ao repertório",
            style: TextStyle(
                fontSize: 20,
                color: mochaMousse,
                fontWeight: FontWeight.bold
            )
        ),
        content: TextField(
          controller: _musicIdController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "ID da música",
            labelStyle: const TextStyle(color: Colors.black54),
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
              borderSide: const BorderSide(color: mochaMousse, width: 2),
            ),
            prefixIcon: const Icon(Icons.music_note, color: mochaMousse),
            filled: true,
            fillColor: mochaMousse.withOpacity(0.1),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _musicIdController.clear();
              Navigator.pop(context);
            },
            child: const Text("Cancelar", style: TextStyle(color: Colors.black54, fontSize: 16)),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_musicIdController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Preencha o ID da música."),
                    backgroundColor: Colors.red.shade400,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
                return;
              }

              int? musicId = int.tryParse(_musicIdController.text);
              if (musicId != null) {
                bool success = await apiService.addMusicToRepertorio(widget.repertorio["idRepertorio"], musicId);
                if (success) {
                  Navigator.pop(context);
                  _reloadMusicas();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Música adicionada com sucesso!", style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.green.shade400,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Erro ao adicionar música."),
                      backgroundColor: Colors.red.shade400,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
                _musicIdController.clear();
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: mochaMousse,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text("Adicionar", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showRemoveMusicDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
            "Remover música do repertório",
            style: TextStyle(
                fontSize: 20,
                color: mochaMousse,
                fontWeight: FontWeight.bold
            )
        ),
        content: TextField(
          controller: _musicIdController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "ID da música",
            labelStyle: const TextStyle(color: Colors.black54),
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
              borderSide: const BorderSide(color: mochaMousse, width: 2),
            ),
            prefixIcon: const Icon(Icons.music_off, color: mochaMousse),
            filled: true,
            fillColor: mochaMousse.withOpacity(0.1),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _musicIdController.clear();
              Navigator.pop(context);
            },
            child: const Text("Cancelar", style: TextStyle(color: Colors.black54, fontSize: 16)),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_musicIdController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Preencha o ID da música."),
                    backgroundColor: Colors.red.shade400,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
                return;
              }

              int? musicId = int.tryParse(_musicIdController.text);
              if (musicId != null) {
                bool success = await apiService.deleteMusicOfRepertorio(widget.repertorio["idRepertorio"], musicId);
                if (success) {
                  Navigator.pop(context);
                  _reloadMusicas();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Música removida com sucesso!", style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.green.shade400,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Erro ao remover música."),
                      backgroundColor: Colors.red.shade400,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
                _musicIdController.clear();
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red.shade400,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text("Remover", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showManageMusicsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
            "Gerenciar músicas",
            style: TextStyle(
                fontSize: 20,
                color: mochaMousse,
                fontWeight: FontWeight.bold
            )
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showAddMusicDialog();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: mochaMousse,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 20),
                  SizedBox(width: 8),
                  Text("Adicionar música", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showRemoveMusicDialog();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red.shade400,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.remove, size: 20),
                  SizedBox(width: 8),
                  Text("Remover música", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fechar", style: TextStyle(color: Colors.black54, fontSize: 16)),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  void _showDisableMusicDialog(int musicId, String titulo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
            "Desativar música",
            style: TextStyle(
                fontSize: 20,
                color: mochaMousse,
                fontWeight: FontWeight.bold
            )
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 48),
            const SizedBox(height: 16),
            Text(
              "Deseja desativar a música \"$titulo\" do repertório?",
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "A música permanecerá no banco de dados, mas não será exibida neste repertório.",
              style: TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.black54, fontSize: 16)),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              bool success = await apiService.disableMusicOfRepertorio(
                  widget.repertorio["idRepertorio"],
                  musicId
              );
              Navigator.pop(context);

              if (success) {
                _reloadMusicas();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Música desativada com sucesso!", style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.green.shade400,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Erro ao desativar música."),
                    backgroundColor: Colors.red.shade400,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.orange,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text("Desativar", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showReactivateMusicDialog(int musicId, String titulo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
            "Reativar música",
            style: TextStyle(
                fontSize: 20,
                color: mochaMousse,
                fontWeight: FontWeight.bold
            )
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 48),
            const SizedBox(height: 16),
            Text(
              "Deseja reativar a música \"$titulo\" no repertório?",
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "A música voltará a aparecer normalmente neste repertório.",
              style: TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.black54, fontSize: 16)),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              bool success = await apiService.enableMusicOfRepertorio(
                  widget.repertorio["idRepertorio"],
                  musicId
              );
              Navigator.pop(context);

              if (success) {
                _reloadMusicas();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Música reativada com sucesso!", style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.green.shade400,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Erro ao reativar música."),
                    backgroundColor: Colors.red.shade400,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.green,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text("Reativar", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _reloadMusicas() {
    setState(() {
      _musicasFuture = apiService.getMusicasRepertorio(widget.repertorio["idRepertorio"]);
    });
  }

  // Função para abrir o PDF viewer
  void _openPdfViewer(BuildContext context, int musicaId, String titulo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(
          musicaId: musicaId,
          titulo: titulo,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _musicasFuture = apiService.getMusicasRepertorio(widget.repertorio["idRepertorio"]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int?>(
      future: _getUserId(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: backgroundColor,
            body: const Center(child: CircularProgressIndicator(color: mochaMousse)),
          );
        }

        final int userId = snapshot.data!;
        final int idResponsavel = widget.banda["idResponsavel"];
        final bool isResponsavel = idResponsavel == userId;

        return Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: CustomScrollView(
                      slivers: [
                        // App Bar personalizado
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Botão Voltar
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
                                // Título
                                Text(
                                  widget.repertorio["nome"] ?? "Detalhes do Repertório",
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: mochaMousse,
                                  ),
                                ),
                                // Ícone de menu (pode ser usado para ações específicas)
                                isResponsavel ? InkWell(
                                  onTap: _showManageMusicsDialog,
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
                                    child: const Icon(Icons.more_vert, color: mochaMousse, size: 24),
                                  ),
                                ) : const SizedBox(width: 40),
                              ],
                            ),
                          ),
                        ),

                        // Header com informações principais
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Container(
                              height: 160,
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
                                      Icons.library_music,
                                      size: 150,
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          widget.repertorio["nome"] ?? "Repertório",
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "ID: ${widget.repertorio["idRepertorio"]} | Banda: ${widget.banda["nome"]}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        isResponsavel
                                            ? InkWell(
                                          onTap: _showManageMusicsDialog,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                            child: const Text(
                                              "Gerenciar Músicas",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: mochaMousse,
                                              ),
                                            ),
                                          ),
                                        )
                                            : const SizedBox(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Título da seção de músicas
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            child: Row(
                              children: [
                                const Text(
                                  "Músicas do Repertório",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                                const SizedBox(width: 8),
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

                        //Instrução para responsável
                        if (isResponsavel)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: mochaMousse.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline, color: mochaMousse, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "Arraste e solte as músicas para reorganizar a ordem do repertório.",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        // Lista de músicas
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 2,
                              shadowColor: Colors.black.withOpacity(0.1),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: SizedBox(
                                  height: 400,
                                  child: FutureBuilder<List<Map<String, dynamic>>>(
                                    future: _musicasFuture,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(child: CircularProgressIndicator(color: mochaMousse));
                                      } else if (snapshot.hasError) {
                                        String errorMessage = snapshot.error.toString();
                                        if (errorMessage.contains("O repertório não possui músicas")) {
                                          return Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.music_off, color: Colors.black38, size: 48),
                                                const SizedBox(height: 16),
                                                const Text("O repertório não possui músicas.", style: TextStyle(color: Colors.black54, fontSize: 16)),
                                                const SizedBox(height: 8),
                                                isResponsavel ? const Text("Use o botão abaixo para adicionar músicas.", style: TextStyle(color: Colors.black38, fontSize: 14)) : const SizedBox(),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
                                                const SizedBox(height: 16),
                                                Text("Erro ao carregar músicas.", style: TextStyle(color: Colors.red.shade400)),
                                                const SizedBox(height: 8),
                                                Text("${snapshot.error}", style: const TextStyle(color: Colors.black54, fontSize: 12)),
                                              ],
                                            ),
                                          );
                                        }
                                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                        return Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.music_off, color: Colors.black38, size: 48),
                                              const SizedBox(height: 16),
                                              const Text("Nenhuma música encontrada.", style: TextStyle(color: Colors.black54, fontSize: 16)),
                                              const SizedBox(height: 8),
                                              isResponsavel ? const Text("Use o botão abaixo para adicionar músicas.", style: TextStyle(color: Colors.black38, fontSize: 14)) : const SizedBox(),
                                            ],
                                          ),
                                        );
                                      }

                                      return ReorderableListView.builder(
                                        itemCount: snapshot.data!.length,
                                        buildDefaultDragHandles: false, // Desativa as alças de arrastar padrão
                                        onReorder: (oldIndex, newIndex) async {
                                          if (oldIndex < newIndex) {
                                            newIndex -= 1;
                                          }

                                          final List<Map<String, dynamic>> items = snapshot.data!;
                                          final item = items.removeAt(oldIndex);
                                          items.insert(newIndex, item);

                                          setState(() {

                                          });

                                          //Extrai os IDs das músicas na nova ordem
                                          final List<int> musicasIds = items
                                              .map((item) => item["musica"]["idMusica"] as int)
                                              .toList();

                                          //Chama a API para atualizar a ordem
                                          final success = await apiService.updateMusicasOrder(
                                              widget.repertorio["idRepertorio"], musicasIds);

                                          if (success) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: const Text("Ordem atualizada com sucesso!",
                                                    style: TextStyle(color: Colors.white)),
                                                backgroundColor: Colors.green.shade400,
                                                behavior: SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: const Text("Erro ao atualizar a ordem."),
                                                backgroundColor: Colors.red.shade400,
                                                behavior: SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              ),
                                            );
                                            // Recarrega a lista original se houver falha
                                            _reloadMusicas();
                                          }
                                        },
                                        itemBuilder: (context, index) {
                                          final item = snapshot.data![index];
                                          final musica = item["musica"] ?? {};
                                          final bool isDisabled = !(item["status"] ?? false);
                                          final int musicaId = musica["idMusica"] ?? 0;
                                          final String titulo = musica["titulo"] ?? "Música desconhecida";

                                          return Card(
                                            key: ValueKey(musicaId),
                                            elevation: 0,
                                            margin: const EdgeInsets.symmetric(vertical: 4),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            color: isDisabled ? Colors.grey.shade100 : Colors.white,
                                            child: ListTile(
                                              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                              leading: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: isDisabled ? Colors.grey.withOpacity(0.1) : mochaMousse.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Icon(
                                                  isDisabled ? Icons.music_off : Icons.music_note,
                                                  color: isDisabled ? Colors.grey : mochaMousse,
                                                  size: 20,
                                                ),
                                              ),
                                              title: Text(
                                                titulo,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                  color: isDisabled ? Colors.grey : Colors.black,
                                                  decoration: isDisabled ? TextDecoration.lineThrough : TextDecoration.none,
                                                ),
                                              ),
                                              subtitle: Text(
                                                isDisabled ? "ID: $musicaId (Desativada)" : "ID: $musicaId",
                                                style: TextStyle(fontSize: 12, color: isDisabled ? Colors.grey : Colors.black54),
                                              ),
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // Botão para visualizar
                                                  Container(
                                                    margin: const EdgeInsets.only(right: 8),
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: isDisabled ? Colors.grey.withOpacity(0.1) : mochaMousse.withOpacity(0.1),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(Icons.visibility,
                                                        color: isDisabled ? Colors.grey : mochaMousse,
                                                        size: 16
                                                    ),
                                                  ),
                                                  // Botão para desativar/reativar
                                                  if (isResponsavel)
                                                    Container(
                                                      margin: const EdgeInsets.only(right: 8),
                                                      padding: const EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        color: isDisabled
                                                            ? Colors.green.withOpacity(0.1)
                                                            : Colors.orange.withOpacity(0.1),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: GestureDetector(
                                                        onTap: () => isDisabled
                                                            ? _showReactivateMusicDialog(musicaId, titulo)
                                                            : _showDisableMusicDialog(musicaId, titulo),
                                                        child: Icon(
                                                            isDisabled ? Icons.refresh : Icons.hide_source,
                                                            color: isDisabled ? Colors.green : Colors.orange,
                                                            size: 16
                                                        ),
                                                      ),
                                                    ),
                                                  // Ícone de arrastar personalizado
                                                  if (isResponsavel)
                                                    ReorderableDragStartListener(
                                                      index: index,
                                                      child: Container(
                                                        padding: const EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey.withOpacity(0.1),
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: Icon(Icons.drag_handle,
                                                            color: Colors.grey.withOpacity(0.7),
                                                            size: 16
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              onTap: () {
                                                // Navegar para a tela de visualização do PDF
                                                _openPdfViewer(context, musicaId, titulo);
                                              },
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Sobre o Repertório
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
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
                                        child: const Icon(Icons.info_outline, color: mochaMousse),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        "Sobre o Repertório",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF333333),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    "Este repertório contém a lista de músicas que podem ser usadas em apresentações da banda. Você pode adicionar ou remover músicas conforme necessário.",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF666666),
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  isResponsavel
                                      ? const Text(
                                    "Como líder da banda, você pode gerenciar as músicas deste repertório.",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF666666),
                                      height: 1.5,
                                    ),
                                  )
                                      : const Text(
                                    "Apenas o líder da banda pode modificar este repertório.",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF666666),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Espaço no final para o FAB não cobrir o conteúdo
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 80),
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
}