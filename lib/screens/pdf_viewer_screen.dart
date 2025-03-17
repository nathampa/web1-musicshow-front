import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/api_service.dart';
import 'dart:ui_web' as ui;

class PdfViewerScreen extends StatefulWidget {
  final int musicaId;
  final String titulo;

  const PdfViewerScreen({
    super.key,
    required this.musicaId,
    required this.titulo,
  });

  @override
  _PdfViewerScreenState createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> with AutomaticKeepAliveClientMixin {
  final ApiService apiService = ApiService();
  bool _isLoading = true;
  String? _errorMessage;
  String? _pdfUrl;
  String? _uniqueId;
  final String _baseViewType = 'pdf-iframe-';

  // Definindo a cor Mocha Mousse, igualando à HomeScreen
  static const Color mochaMousse = Color(0xFFA47864);
  static const Color backgroundColor = Color(0xFFF8F5F3);

  // Contador estático global para garantir IDs únicos mesmo com reconstrução
  static int _viewerCounter = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Criar um ID verdadeiramente único para o visualizador
    _uniqueId = '${_baseViewType}${widget.musicaId}-${DateTime.now().millisecondsSinceEpoch}-${_viewerCounter++}';
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      if (kIsWeb) {
        // Implementação para web
        final bytes = await apiService.downloadMusicaPdf(widget.musicaId);

        if (bytes.isEmpty) {
          throw Exception("PDF vazio recebido da API");
        }

        // Limpar URL anterior se existir
        _limparRecursosAnteriores();

        // Cria um Blob a partir dos bytes com MIME type explícito
        final blob = html.Blob([bytes], 'application/pdf');

        // Cria uma URL para o Blob
        _pdfUrl = html.Url.createObjectUrlFromBlob(blob);

        // Registrar a view factory
        _registerViewFactory();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _limparRecursosAnteriores() {
    // Revogar URL anterior se existir
    if (_pdfUrl != null) {
      try {
        html.Url.revokeObjectUrl(_pdfUrl!);
        _pdfUrl = null;
      } catch (e) {
        print("Erro ao revogar URL anterior: $e");
      }
    }
  }

  void _registerViewFactory() {
    if (_pdfUrl == null || _uniqueId == null) return;

    // Registrar a view factory apenas se não estiver registrada
    try {
      // ignore: undefined_prefixed_name
      ui.platformViewRegistry.registerViewFactory(
        _uniqueId!,
            (int viewId) {

          // Criar div container para garantir estabilidade
          final container = html.DivElement()
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.overflow = 'hidden'
            ..style.backgroundColor = 'white';

          // Criar iframe com o PDF
          final iframe = html.IFrameElement()
            ..style.border = 'none'
            ..style.margin = '0'
            ..style.padding = '0'
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.overflow = 'hidden'
            ..style.backgroundColor = 'white'
            ..setAttribute('allowfullscreen', 'true')
            ..src = _pdfUrl!;

          container.children.add(iframe);
          return container;
        },
      );

    } catch (e) {
      // Se já estiver registrado, tentar gerar novo ID único
      if (e.toString().contains('already registered')) {
        _uniqueId = '${_baseViewType}${widget.musicaId}-${DateTime.now().millisecondsSinceEpoch}-${_viewerCounter++}';
        Future.microtask(() => _registerViewFactory());
      }
    }
  }

  @override
  void dispose() {
    _limparRecursosAnteriores();
    super.dispose();
  }

  Widget _buildPdfViewer() {
    if (!kIsWeb || _pdfUrl == null || _uniqueId == null) {
      return const Center(child: Text("Visualização de PDF não disponível"));
    }

    return LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            color: Colors.white,
            child: HtmlElementView(viewType: _uniqueId!),
          );
        }
    );
  }

  //Métodopara tentar uma abordagem alternativa de visualização do PDF
  void _abrirPdfEmNovaAba() {
    if (_pdfUrl != null) {
      // Abre o PDF em uma nova aba
      html.window.open(_pdfUrl!, '_blank');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necessário para AutomaticKeepAliveClientMixin

    return WillPopScope(
      onWillPop: () async {
        _limparRecursosAnteriores();
        return true;
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: mochaMousse),
            onPressed: () {
              _limparRecursosAnteriores();
              Navigator.pop(context);
            },
          ),
          title: Text(
            widget.titulo,
            style: const TextStyle(
              color: mochaMousse,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            // Botão para abrir em nova aba
            IconButton(
              icon: const Icon(Icons.open_in_new, color: mochaMousse),
              onPressed: _abrirPdfEmNovaAba,
              tooltip: "Abrir em nova aba",
            ),
            // Botão para recarregar PDF
            IconButton(
              icon: const Icon(Icons.refresh, color: mochaMousse),
              onPressed: _loadPdf,
              tooltip: "Recarregar PDF",
            ),
          ],
          centerTitle: true,
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: mochaMousse),
                SizedBox(height: 16),
                Text(
                  "Carregando partitura...",
                  style: TextStyle(color: mochaMousse, fontSize: 16),
                ),
              ],
            ),
          )
              : _errorMessage != null
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade400, size: 64),
                const SizedBox(height: 16),
                Text(
                  "Erro ao carregar o PDF",
                  style: TextStyle(color: Colors.red.shade400, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loadPdf,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text("Tentar novamente", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mochaMousse,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          )
              : _pdfUrl != null
              ? Container(
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
            margin: const EdgeInsets.all(16),
            // Usar ClipRRect com Expanded para garantir que o PDF preencha o espaço disponível
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _buildPdfViewer(),
            ),
          )
              : const Center(
            child: Text("Não foi possível carregar o PDF"),
          ),
        ),
      ),
    );
  }
}