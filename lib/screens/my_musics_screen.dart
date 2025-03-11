import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

class MyMusicsScreen extends StatefulWidget {
  const MyMusicsScreen({super.key});

  @override
  _MyMusicsScreenState createState() => _MyMusicsScreenState();
}

class _MyMusicsScreenState extends State<MyMusicsScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Map<String, dynamic>>> _musicsFuture;

  // Definindo a cor Mocha Mousse, igual à RepertorioDetailsScreen
  static const Color mochaMousse = Color(0xFFA47864);

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
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              if (fileName != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: mochaMousse.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.insert_drive_file, color: mochaMousse, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Arquivo: $fileName",
                            style: TextStyle(color: Colors.black87),
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
              child: Text("Cancelar", style: TextStyle(color: Colors.black54, fontSize: 16)),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_tituloController.text.isEmpty || selectedFile == null || fileName == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Preencha o título e selecione um arquivo PDF."),
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
                      content: Text("Música adicionada com sucesso!", style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.green.shade400,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Erro ao adicionar música."),
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
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text("Adicionar", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Minhas Músicas",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white
            )
        ),
        backgroundColor: mochaMousse,
        centerTitle: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      backgroundColor: mochaMousse.withOpacity(0.1),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Card superior com informações sobre minhas músicas
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: mochaMousse.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.library_music, color: mochaMousse),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Minha Biblioteca de Músicas",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: mochaMousse
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Gerencie suas partituras e composições",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      // Lista de músicas
                      Card(
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
                                  Icon(Icons.music_note, color: mochaMousse),
                                  SizedBox(width: 8),
                                  Text(
                                      "Minhas Músicas",
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
                                height: 400,
                                child: FutureBuilder<List<Map<String, dynamic>>>(
                                  future: _musicsFuture,
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
                                            Text("Erro ao carregar músicas.", style: TextStyle(color: Colors.red.shade400)),
                                            SizedBox(height: 8),
                                            Text("${snapshot.error}", style: TextStyle(color: Colors.black54, fontSize: 12)),
                                          ],
                                        ),
                                      );
                                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                      return Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.music_off, color: Colors.black38, size: 48),
                                            SizedBox(height: 16),
                                            Text("Nenhuma música encontrada.", style: TextStyle(color: Colors.black54, fontSize: 16)),
                                            SizedBox(height: 8),
                                            Text("Use o botão + abaixo para adicionar músicas.", style: TextStyle(color: Colors.black38, fontSize: 14)),
                                          ],
                                        ),
                                      );
                                    }

                                    return ListView.separated(
                                      itemCount: snapshot.data!.length,
                                      separatorBuilder: (context, index) => Divider(height: 1, color: mochaMousse.withOpacity(0.2)),
                                      itemBuilder: (context, index) {
                                        final musica = snapshot.data![index];
                                        return ListTile(
                                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                          leading: CircleAvatar(
                                            backgroundColor: mochaMousse.withOpacity(0.1),
                                            child: Icon(Icons.music_note, color: mochaMousse),
                                          ),
                                          title: Text(
                                            musica["titulo"] ?? "Música desconhecida",
                                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                                          ),
                                          subtitle: Text(
                                            "ID: ${musica["idMusica"]}",
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
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMusicDialog,
        backgroundColor: mochaMousse,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}