import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../viewmodels/search_viewmodel.dart';
import '../models/persona.dart';
import 'menu_view.dart';
import 'datos_view.dart';
import 'login_view.dart'; // para volver al login

class SearchView extends StatefulWidget {
  final ApiService apiService;
  const SearchView({required this.apiService, super.key});

  @override
  State<SearchView> createState() => _SeleccionarPacienteViewState();
}

class _SeleccionarPacienteViewState extends State<SearchView> {
  @override
  void initState() {
    super.initState();
    // Cargar pacientes al iniciar (después del primer frame)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SearchViewModel>(context, listen: false)
          .loadPacientes(widget.apiService);
    });
  }

  // Función para cerrar sesión
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // elimina datos de sesión guardados

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
          (route) => false, // elimina todas las rutas anteriores
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seleccionar paciente"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<SearchViewModel>(
            builder: (context, vm, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  TextField(
                    onChanged: vm.filter,
                    decoration: InputDecoration(
                      hintText: "Buscar paciente...",
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: vm.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : vm.filtered.isEmpty
                        ? const Center(child: Text("No hay pacientes"))
                        : ListView.builder(
                      itemCount: vm.filtered.length,
                      itemBuilder: (context, index) {
                        Paciente p = vm.filtered[index];
                        return Card(
                          elevation: 1,
                          margin:
                          const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.person,
                                color: Colors.green),
                            title: Text(
                              "${p.nombre} ${p.apellidos}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      MenuView(paciente: p),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DatosPacienteView(
                              paciente: null, esRegistro: true),
                        ),
                      );
                    },
                    child: const Text("Registrar"),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
