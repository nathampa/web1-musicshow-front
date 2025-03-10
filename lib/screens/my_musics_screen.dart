import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'dart:io';

class MyMusicsScreen extends StatefulWidget {
  const MyMusicsScreen({super.key});

  @override
  _MyMusicsScreenState createState() => _MyMusicsScreenState();
}

class _MyMusicsScreenState extends State<MyMusicsScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Map<String, dynamic>>> _musicsFuture;

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
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          "Adicionar Música",
          style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _tituloController,
              decoration: InputDecoration(
                labelText: "Título da Música",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.music_note, color: Colors.teal),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf'],
                );
                if (result != null && result.files.single.bytes != null) {
                  setState(() {
                    selectedFile = result.files.single.bytes;
                    fileName = result.files.single.name;
                  });
                }
              },
              icon: const Icon(Icons.upload_file),
              label: const Text("Selecionar PDF"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            if (fileName != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Arquivo: $fileName",
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_tituloController.text.isEmpty || selectedFile == null || fileName == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Preencha o título e selecione um arquivo PDF.")),
                );
                return;
              }

              bool success = await apiService.addMusic(_tituloController.text, selectedFile!, fileName!);
              Navigator.pop(context);

              if (success) {
                _loadMusics();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Música adicionada com sucesso!")),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Erro ao adicionar música.")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Adicionar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Minhas Músicas",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 6,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
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
              const Text(
                "Minhas Músicas",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              const SizedBox(height: 12),
              const Text(
                "Aqui estão todas as músicas associadas a você.",
                style: TextStyle(fontSize: 18, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _musicsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          "Erro ao carregar suas músicas.",
                          style: TextStyle(fontSize: 18, color: Colors.red),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          "Nenhuma música encontrada.",
                          style: TextStyle(fontSize: 18, color: Colors.black54),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final music = snapshot.data![index];
                        return ListTile(
                          leading: const Icon(Icons.music_note, color: Colors.teal),
                          title: Text(music["titulo"] ?? "Música desconhecida"),
                          subtitle: Text("Artista: ${music["artista"] ?? "Desconhecido"}"),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMusicDialog,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
