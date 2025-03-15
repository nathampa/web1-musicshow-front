import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'home_screen.dart';
import 'pdf_viewer_screen.dart';

class MyMusicsScreen extends StatefulWidget {
  const MyMusicsScreen({super.key});

  @override
  _MyMusicsScreenState createState() => _MyMusicsScreenState();
}

class _MyMusicsScreenState extends State<MyMusicsScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Map<String, dynamic>>> _musicsFuture;

  // Definindo a cor Mocha Mousse, igualando à HomeScreen
  static const Color mochaMousse = Color(0xFFA47864);
  static const Color backgroundColor = Color(0xFFF8F5F3);

  @override
  void initState() {
    super.initState();
    _loadMusics();
  }

  void _loadMusics() {
    setState(() {
      _musicsFuture = apiService.getMinhasMusicas();
    });
  }

  void _showAddMusicDialog() {
    TextEditingController _tituloController = TextEditingController();
    Uint8List? selectedFile;
    String? fileName;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "Adicionar Música",
            style: TextStyle(
                fontSize: 20,
                color: mochaMousse,
                fontWeight: FontWeight.bold
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _tituloController,
                decoration: InputDecoration(
                  labelText: "Título da Música",
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
                  prefixIcon: const Icon(Icons.music_note, color: mochaMousse),
                  filled: true,
                  fillColor: mochaMousse.withOpacity(0.1),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf'],
                  );
                  if (result != null && result.files.single.bytes != null) {
                    // Usando setDialogState para atualizar o estado do diálogo
                    setDialogState(() {
                      selectedFile = result.files.single.bytes;
                      fileName = result.files.single.name;
                    });
                  }
                },
                icon: const Icon(Icons.upload_file, color: Colors.white),
                label: const Text("Selecionar PDF", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: mochaMousse,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              if (fileName != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: mochaMousse.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.insert_drive_file, color: mochaMousse, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Arquivo: $fileName",
                            style: const TextStyle(color: Colors.black87),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                if (_tituloController.text.isEmpty || selectedFile == null || fileName == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Preencha o título e selecione um arquivo PDF."),
                      backgroundColor: Colors.red.shade400,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                  return;
                }

                bool success = await apiService.addMusic(_tituloController.text, selectedFile!, fileName!);
                Navigator.pop(context);

                if (success) {
                  _loadMusics();
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
      ),
    );
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
  Widget build(BuildContext context) {
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
                            const Text(
                              "Minhas Músicas",
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

                    // Header Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            const Text(
                              "Gerenciando suas músicas",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Organize todas as suas partituras e composições",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),

                    // Featured Card
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                    const Text(
                                      "Minha Biblioteca Musical",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      "Acesse e organize suas partituras e composições",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    InkWell(
                                      onTap: _showAddMusicDialog,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        child: const Text(
                                          "Adicionar Música",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: mochaMousse,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Section Title
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        child: Row(
                          children: [
                            const Text(
                              "Minhas Músicas",
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

                    // Lista de Músicas
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
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
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: SizedBox(
                              height: 400,
                              child: FutureBuilder<List<Map<String, dynamic>>>(
                                future: _musicsFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator(color: mochaMousse));
                                  } else if (snapshot.hasError) {
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
                                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                    return Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.music_off, color: Colors.black38, size: 48),
                                          const SizedBox(height: 16),
                                          const Text("Nenhuma música encontrada.", style: TextStyle(color: Colors.black54, fontSize: 16)),
                                          const SizedBox(height: 8),
                                          const Text("Use o botão 'Adicionar Música' acima para adicionar músicas.", style: TextStyle(color: Colors.black38, fontSize: 14)),
                                        ],
                                      ),
                                    );
                                  }

                                  return ListView.builder(
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, index) {
                                      final musica = snapshot.data![index];
                                      final int musicaId = musica["idMusica"] ?? 0;
                                      final String titulo = musica["titulo"] ?? "Música desconhecida";

                                      return Card(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        elevation: 0,
                                        color: mochaMousse.withOpacity(0.05),
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                          leading: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: mochaMousse.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Icon(Icons.music_note, color: mochaMousse),
                                          ),
                                          title: Text(
                                            titulo,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color: Color(0xFF333333),
                                            ),
                                          ),
                                          subtitle: Text(
                                            "ID: $musicaId",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black.withOpacity(0.6),
                                            ),
                                          ),
                                          trailing: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: mochaMousse.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.visibility, color: mochaMousse, size: 16),
                                          ),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

                    // Info section
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
                                    "Dicas para usar",
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
                                "Adicione suas partituras em PDF para acessá-las facilmente durante seus ensaios e apresentações.",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF666666),
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "Você pode organizar suas músicas por bandas ou em listas personalizadas.",
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
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}