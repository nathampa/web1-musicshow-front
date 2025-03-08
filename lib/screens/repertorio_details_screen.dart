import 'package:flutter/material.dart';

class RepertorioDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> repertorio;

  const RepertorioDetailsScreen({super.key, required this.repertorio});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          repertorio["nome"] ?? "Detalhes do Repertório",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
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
              const Icon(Icons.library_music, size: 80, color: Colors.teal),
              const SizedBox(height: 20),
              Text(
                repertorio["nome"] ?? "Nome desconhecido",
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              const SizedBox(height: 12),
              Text(
                "ID: ${repertorio["idRepertorio"]}",
                style: const TextStyle(fontSize: 18, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                "Detalhes do Repertório:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Quantidade de músicas: ${repertorio["qtdMusicas"] ?? 0}",
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
