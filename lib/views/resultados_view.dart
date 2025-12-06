import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/persona.dart';
import '../models/analisis.dart';

class ResultadosView extends StatelessWidget {
  final Paciente paciente;
  final String? imagenOriginalUrl;
  final Analysis analisis;

  const ResultadosView({
    super.key,
    required this.paciente,
    required this.imagenOriginalUrl,
    required this.analisis,
  });

  @override
  Widget build(BuildContext context) {
    print(imagenOriginalUrl);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                Text(
                  "Resultado del análisis MRI\nAnálisis #${analisis.id}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // IMAGEN MRI
                _buildImageCard(
                  title: "MRI",
                  assetPlaceholder: "assets/images/MRI_of_Human_Brain.jpg",
                  imageUrl: imagenOriginalUrl,
                ),

                const SizedBox(height: 24),

                // RESULTADO TÉCNICO
                _buildTextCard(
                  title: "Resultado técnico",
                  content: analisis.resultadoTecnico,
                ),

                const SizedBox(height: 16),

                // RESULTADO EXPLICADO
                _buildTextCard(
                  title: "Resultado explicado",
                  content: analisis.resultadoExplicado,
                ),

                const SizedBox(height: 24),

                // VOLVER
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    side: const BorderSide(color: Colors.deepPurple),
                  ),
                  child: const Text(
                    "Volver",
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageCard({
    required String title,
    required String assetPlaceholder,
    String? imageUrl,
  }) {
    return Column(
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl != null
                ? Image.network(
              imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Image.asset(assetPlaceholder, fit: BoxFit.cover),
            )
                : Image.asset(assetPlaceholder,
                height: 180, width: double.infinity, fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }

  Widget _buildTextCard({
    required String title,
    required String content,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              content,
              textAlign: TextAlign.justify,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}


