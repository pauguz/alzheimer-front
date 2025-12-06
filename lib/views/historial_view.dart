import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../models/persona.dart';
import '../models/analisis.dart';
import '../viewmodels/login_viewmodel.dart';
import 'resultados_view.dart';

class HistorialView extends StatefulWidget {
  final Paciente paciente;

  const HistorialView({super.key, required this.paciente});

  @override
  State<HistorialView> createState() => _HistorialViewState();
}

// ----------------------
// Modelo UI para separar
// ----------------------
abstract class AnalisisItem {}

class AnalisisCardItem extends AnalisisItem {
  final Analysis analisis;
  AnalisisCardItem(this.analisis);
}

class AnalisisMonthSeparator extends AnalisisItem {
  final String mesAno;
  AnalisisMonthSeparator(this.mesAno);
}

// ---------------------------
class _HistorialViewState extends State<HistorialView> {
  List<Analysis> analisis = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarAnalisis();
  }

  Future<void> cargarAnalisis() async {
    try {
      final token = Provider.of<LoginViewModel>(context, listen: false).token;
      if (token == null) return;

      final url = Uri.parse(
        "https://alzheimer-api-j5o0.onrender.com/pacientes/${widget.paciente.id}/analisis/",
      );

      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        final List<dynamic> data = jsonDecode(decoded);

        setState(() {
          analisis = data.map((json) => Analysis.fromJson(json)).toList();
          cargando = false;
        });
      } else {
        setState(() => cargando = false);
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => cargando = false);
    }
  }

  // ------------------------
  // Agrupación por mes
  // ------------------------
  List<AnalisisItem> _generarListaConSeparadores(List<Analysis> lista) {
    final items = <AnalisisItem>[];
    lista.sort((a, b) => b.fecha.compareTo(a.fecha));

    String? mesActual;

    for (var a in lista) {
      final fecha = DateTime.parse(a.fecha);
      final mesAno = "${fecha.month.toString().padLeft(2, '0')}/${fecha.year}";

      if (mesActual != mesAno) {
        mesActual = mesAno;
        items.add(AnalisisMonthSeparator(mesAno));
      }

      items.add(AnalisisCardItem(a));
    }

    return items;
  }

  //--------------------------
  @override
  Widget build(BuildContext context) {
    final hayAnalisis = analisis.isNotEmpty;
    List<AnalisisItem> listaUI = [];

    if (hayAnalisis) {
      listaUI = _generarListaConSeparadores(analisis);
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 24),

              Text(
                "Historial y Resultados\n${widget.paciente.nombre} ${widget.paciente.apellidos}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              cargando
                  ? const Expanded(child: Center(child: CircularProgressIndicator()))
                  : !hayAnalisis
                  ? Expanded(child: _buildCardEjemplo())
                  : Expanded(
                child: CustomScrollView(
                  slivers: _buildSlivers(listaUI),
                ),
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text("Volver"),
              )
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------
  // Construcción de slivers
  // --------------------------
  List<Widget> _buildSlivers(List<AnalisisItem> items) {
    final slivers = <Widget>[];
    List<Widget> buffer = [];

    for (var item in items) {
      if (item is AnalisisMonthSeparator) {
        if (buffer.isNotEmpty) {
          slivers.add(_buildGrid(buffer));
          buffer = [];
        }
        slivers.add(_buildSeparator(item.mesAno));
      } else if (item is AnalisisCardItem) {
        buffer.add(_buildCard(item));
      }
    }

    if (buffer.isNotEmpty) {
      slivers.add(_buildGrid(buffer));
    }

    return slivers;
  }

  // --------------------------
  Widget _buildSeparator(String mesAno) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        padding: const EdgeInsets.all(12),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          mesAno,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  // --------------------------
  Widget _buildGrid(List<Widget> cards) {
    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 12),
      sliver: SliverGrid(
        delegate: SliverChildListDelegate(cards),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.9,
        ),
      ),
    );
  }

  // --------------------------
  Widget _buildCard(AnalisisCardItem item) {
    final fullMRI = item.analisis.rutaImagenMRI.isNotEmpty
        ? "https://alzheimer-api-j5o0.onrender.com/${item.analisis.rutaImagenMRI}"
        : null;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ResultadosView(
                paciente: widget.paciente,
                imagenOriginalUrl: fullMRI,
                analisis: item.analisis,
              ),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.analytics, size: 48, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              "Análisis #${item.analisis.id}",
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              item.analisis.fecha.split("T")[0],
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------
  Widget _buildCardEjemplo() {
    return const Card(
      elevation: 4,
      child: Center(
        child: Text(
          "Ejemplo de análisis\n(no hay resultados)",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

