import 'package:flutter/material.dart';
import '../models/persona.dart';
import '../services/api_service.dart';

class SearchViewModel extends ChangeNotifier {
  bool isLoading = false;
  List<Paciente> pacientes = [];
  List<Paciente> filtered = [];

  Future<void> loadPacientes(ApiService api) async {
    try {
      isLoading = true;
      notifyListeners();

      pacientes = await api.fetchPacientes();
      filtered = pacientes;
    } catch (e) {
      print('Error al cargar pacientes: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void filter(String query) {
    filtered = pacientes
        .where((p) =>
    p.nombre.toLowerCase().contains(query.toLowerCase()) ||
        p.apellidos.toLowerCase().contains(query.toLowerCase()))
        .toList();
    notifyListeners();
  }
}
