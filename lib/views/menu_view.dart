import 'package:flutter/material.dart';
import 'carga_view.dart';
import 'historial_view.dart';
import 'datos_view.dart';
import '../models/persona.dart';

class MenuView extends StatelessWidget {
  final Paciente paciente;
  const MenuView({super.key, required this.paciente});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              Text(
                "Menú Principal - ${paciente.nombre} ${paciente.apellidos}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),

              // Botón Nuevo análisis
              _MenuButton(
                title: "Nuevo análisis",
                icon: Icons.add_a_photo,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CargaView(paciente: paciente),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Botón Historial
              _MenuButton(
                title: "Historial",
                icon: Icons.history,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HistorialView(paciente: paciente),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Botón Datos
              _MenuButton(
                title: "Datos",
                icon: Icons.bar_chart,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DatosPacienteView(paciente: paciente),
                    ),
                  );
                },
              ),

              const Spacer(), // 🔹 Empuja el botón al final

              // 🔹 Botón Volver
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Volver",
                    style: TextStyle(color: Colors.deepPurple),
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

class _MenuButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const _MenuButton({
    required this.title,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        trailing: Icon(icon, size: 36),
      ),
    );
  }
}
