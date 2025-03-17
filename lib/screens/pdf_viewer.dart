import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/api_service.dart';
import 'dart:ui' as ui;

class PdfViewer extends StatefulWidget {
  final int? musicaId;

  const PdfViewer({super.key, this.musicaId});

  @override
  _PdfViewerState createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  final ApiService apiService = ApiService();
  bool _isLoading = true;
  String? _errorMessage;
  String? _pdfUrl;
  String? _uniqueId;
  static const Color mochaMousse = Color(0xFFA47864);

  @override
  void initState() {
    super.initState();
    _uniqueId = 'pdf-viewer-${widget.musicaId ?? "empty"}-${DateTime.now().millisecondsSinceEpoch}';
    if (widget.musicaId != null) {
      _loadPdf();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void didUpdateWidget(PdfViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.musicaId != widget.musicaId) {
      _limparRecursosAnteriores();
      _uniqueId = 'pdf-viewer-${widget.musicaId ?? "empty"}-${DateTime.now().millisecondsSinceEpoch}';
      if (widget.musicaId != null) {
        _loadPdf();
      } else {
        setState(() {
          _isLoading = false;
          _pdfUrl = null;
          _errorMessage = null;
        });
      }
    }
  }

  Future<void> _loadPdf() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      if (kIsWeb) {
        final bytes = await apiService.downloadMusicaPdf(widget.musicaId!);
        if (bytes.isEmpty) {
          throw Exception("PDF vazio recebido da API");
        }

        _limparRecursosAnteriores();
        final blob = html.Blob([bytes], 'application/pdf');
        _pdfUrl = html.Url.createObjectUrlFromBlob(blob);
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

    try {
      // ignore: undefined_prefixed_name
      ui.platformViewRegistry.registerViewFactory(
        _uniqueId!,
            (int viewId) {
          final container = html.DivElement()
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.overflow = 'hidden'
            ..style.backgroundColor = 'white';

          final iframe = html.IFrameElement()
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.overflow = 'hidden'
            ..src = _pdfUrl!;

          container.children.add(iframe);
          return container;
        },
      );
    } catch (e) {
      print("Erro ao registrar view factory: $e");
    }
  }

  @override
  void dispose() {
    _limparRecursosAnteriores();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return const Center(child: Text("Visualização de PDF disponível apenas na web"));
    }

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: mochaMousse),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Text("Erro: $_errorMessage", style: const TextStyle(color: Colors.red)),
      );
    }

    if (_pdfUrl == null) {
      return const Center(child: Text("Nenhum PDF selecionado"));
    }

    return HtmlElementView(viewType: _uniqueId!);
  }
}