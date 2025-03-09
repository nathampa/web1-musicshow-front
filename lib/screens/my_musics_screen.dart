import 'package:flutter/material.dart';
import 'package:untitled/services/api_service.dart';

class MyMusicsScreen extends StatefulWidget {
  @override
  _MyMusicsScreenState createState() => _MyMusicsScreenState();
}

class _MyMusicsScreenState extends State<MyMusicsScreen> {
  final ApiService apiService = ApiService();
  List<Map<String, dynamic>> musicas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMusicas();
  }

  Future<void> fetchMusicas() async {
    try {
      List<Map<String, dynamic>> response = await apiService.getMinhasMusicas();
      setState(() {
        musicas = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Minhas Músicas', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),),backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ), ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : musicas.isEmpty
          ? Center(child: Text('Nenhuma música encontrada.'))
          : ListView.builder(
        itemCount: musicas.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(musicas[index]['nomeMusica']),
            subtitle: Text('Artista: ${musicas[index]['artista'] ?? 'Desconhecido'}'),
          );
        },
      ),
    );
  }
}
