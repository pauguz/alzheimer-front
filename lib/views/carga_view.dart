import 'dart:convert';
import 'dart:io';
import '../viewmodels/login_viewmodel.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../models/persona.dart';
import '../models/analisis.dart';
import 'resultados_view.dart';

class CargaView extends StatefulWidget {
  final Paciente paciente;
  const CargaView({super.key, required this.paciente});

  @override
  State<CargaView> createState() => _CargaViewState();
}

class _CargaViewState extends State<CargaView> {
  File? _selectedFile;
  bool _isLoading = false;

  /// Abre el selector de archivos para que el usuario elija una imagen.
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedFile = File(pickedFile.path);
      });
    }
  }

  String? limpiarRuta(String? ruta) {
    if (ruta == null) return null;

    return ruta
        .replaceAll(RegExp(r'[\u0000-\u001F]'), '') // elimina caracteres de control
        .replaceAll(" ", "")
        .replaceAll("\n", "")
        .replaceAll("\r", "")
        .trim();
  }


  /// Envía la imagen al backend, espera el análisis y navega a ResultadosView
  Future<void> _analizarImagen(int? pacienteId) async {
    print("🚨 ESTE ES EL ARCHIVO QUE SE ESTA EJECUTANDO");

    if (_selectedFile == null) return;

    setState(() => _isLoading = true);

    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    final token = loginVM.token ?? "";

    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debe iniciar sesión nuevamente.")),
      );
      setState(() => _isLoading = false);
      return;
    }

    final url = Uri.parse(
      "https://alzheimer-api-j5o0.onrender.com/pacientes/$pacienteId/analisis/",
    );

    // Capturamos el Navigator antes del await
    final navigator = Navigator.of(context);

    try {
      print("⏳ INICIANDO ANALISIS...");
      final req = http.MultipartRequest("POST", url);
      req.headers["Authorization"] = "Bearer $token";
      req.files.add(await http.MultipartFile.fromPath("file", _selectedFile!.path));
      print("📤 ENVIANDO REQUEST...");

      final resp = await req.send();
      print("📥 RESPUESTA RECIBIDA");

      final body = await resp.stream.bytesToString();
      print("📄 BODY RAW: $body");
      print("🔍 STATUS: ${resp.statusCode}");
      print("📌 CODIGO REAL RESPUESTA: ${resp.statusCode}");
      print("📌 TIPO DE STATUS: ${resp.statusCode.runtimeType}");
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final decoded = jsonDecode(body) as Map<String, dynamic>;
        print("🧩 ANALISIS OBTENIDO: $decoded");

        late Analysis analysis;
        try {

          analysis = Analysis.fromJson(decoded);
          print("🟩 ANALYSIS CREADO CORRECTAMENTE");
        } catch (e) {
          print("❌ ERROR DENTRO DE Analysis.fromJson: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error al procesar análisis: $e")),
          );
          setState(() => _isLoading = false);
          return;
        }


        // --- SANITIZACIÓN DE LA RUTA ---
        final rutaLimpia = limpiarRuta(decoded["ruta_imagen_mri"]);
        final fullMRI = rutaLimpia != null
            ? "https://alzheimer-api-j5o0.onrender.com/$rutaLimpia"
            : null;

        if (fullMRI == null || fullMRI.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("La imagen recibida no es válida")),
          );
          setState(() => _isLoading = false);
          return;
        }

        // --- NAVEGACIÓN ---
        if (!mounted) return;
        print("RUTA ORIGINAL: '${decoded["ruta_imagen_mri"]}'");
        print("RUTA LIMPIA: '$rutaLimpia'");
        print("URL COMPLETA: '$fullMRI'");
        navigator.push(
          MaterialPageRoute(
            builder: (_) => ResultadosView(
              paciente: widget.paciente,
              imagenOriginalUrl: fullMRI,
              analisis: analysis,
            ),
          ),
        );
      } else {
        print("⛔ NO ENTRA AL IF. REASON: resp.statusCode = ${resp.statusCode}");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $body")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final paciente = widget.paciente;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Cargar imagen\n${paciente.nombre} ${paciente.apellidos}",
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              const SizedBox(height: 24),

              // Caja de carga de archivo
              Expanded(
                child: Center(
                  child: InkWell(
                    onTap: _pickImage,
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 250,
                        child: _selectedFile == null
                            ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.insert_drive_file_outlined,
                                size: 64, color: Colors.black54),
                            SizedBox(height: 12),
                            Text("Toca para seleccionar un archivo"),
                          ],
                        )
                            : ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Image.file(
                            _selectedFile!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Botón Analizar
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_selectedFile != null && !_isLoading)
                        ? Theme.of(context).primaryColor
                        : Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: (_selectedFile != null && !_isLoading)
                      ? () => _analizarImagen(widget.paciente.id)
                      : null,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Analizar",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Botón salir
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    "Salir",
                    style: TextStyle(color: Colors.black87, fontSize: 16),
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
