import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'band_details_screen.dart';

class BandsScreen extends StatefulWidget {
  const BandsScreen({super.key});

  @override
  _BandsScreenState createState() => _BandsScreenState();
}

class _BandsScreenState extends State<BandsScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Map<String, dynamic>>> futureBands;
  final TextEditingController _bandaController = TextEditingController();

  // Definindo a cor Mocha Mousse, igual à BandDetailsScreen
  static const Color mochaMousse = Color(0xFFA47864);

  @override
  void initState() {
    super.initState();
    _loadBands();
  }

  void _loadBands() {
    setState(() {
      futureBands = apiService.getUserBands();
    });
  }

  void _createBanda() async {
    String nomeBanda = _bandaController.text.trim();
    if (nomeBanda.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Dê um nome à banda."),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    bool success = await apiService.createBanda(nomeBanda);
    if (success) {
      Navigator.pop(context);
      _bandaController.clear();
      _loadBands();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Banda criada com sucesso!", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao criar a banda."),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showCreateBandaDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
            "Criar nova banda",
            style: TextStyle(
                fontSize: 20,
                color: mochaMousse,
                fontWeight: FontWeight.bold
            )
        ),
        content: TextField(
          controller: _bandaController,
          decoration: InputDecoration(
            labelText: "Nome da banda",
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
        actions: [
          TextButton(
            onPressed: () {
              _bandaController.clear();
              Navigator.pop(context);
            },
            child: Text("Cancelar", style: TextStyle(color: Colors.black54, fontSize: 16)),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          ElevatedButton(
            onPressed: _createBanda,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            "Minhas Bandas",
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
            // Layout responsivo baseado na largura da tela
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Card superior com instruções ou informações
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
                                child: Icon(Icons.info_outline, color: mochaMousse),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Gerenciamento de Bandas",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: mochaMousse
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Toque em uma banda para ver detalhes ou use o botão + para criar uma nova.",
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
                      // Lista de bandas
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
                                  Icon(Icons.group, color: mochaMousse),
                                  SizedBox(width: 8),
                                  Text(
                                      "Minhas Bandas",
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
                                  future: futureBands,
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
                                            Text("Erro ao carregar bandas.", style: TextStyle(color: Colors.red.shade400)),
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
                                            Text("Nenhuma banda encontrada.", style: TextStyle(color: Colors.black54, fontSize: 16)),
                                            SizedBox(height: 8),
                                            Text("Crie uma banda clicando no botão + abaixo.", style: TextStyle(color: Colors.black38, fontSize: 14)),
                                          ],
                                        ),
                                      );
                                    }

                                    return ListView.separated(
                                      itemCount: snapshot.data!.length,
                                      separatorBuilder: (context, index) => Divider(height: 1, color: mochaMousse.withOpacity(0.2)),
                                      itemBuilder: (context, index) {
                                        final banda = snapshot.data![index];
                                        return ListTile(
                                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                          leading: CircleAvatar(
                                            backgroundColor: mochaMousse.withOpacity(0.1),
                                            child: Icon(Icons.music_note, color: mochaMousse),
                                          ),
                                          title: Text(
                                            banda["nome"] ?? "Nome desconhecido",
                                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                                          ),
                                          subtitle: Text(
                                            "ID: ${banda["idBanda"]} | Responsável: ${banda["idResponsavel"]}",
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
                                              MaterialPageRoute(builder: (context) => BandDetailsScreen(banda: banda)),
                                            ).then((_) => _loadBands()); // Recarrega as bandas quando retornar
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
        onPressed: _showCreateBandaDialog,
        backgroundColor: mochaMousse,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}