import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/usuario.dart';

class LoginViewModel extends ChangeNotifier {
  String username = ''; // Antes 'email', ahora la API usa 'username'
  String password = '';
  bool isLoading = false;
  bool isLoggedIn = false;
  Usuario? currentUser;

  final ApiService _apiService;

  LoginViewModel(this._apiService);
  /// Acceso al token por si lo necesita otro ViewModel
  String? get token => _apiService.token;
  ApiService get apiService => _apiService;


  /// Intenta iniciar sesión usando el endpoint /token
  Future<bool> validateLogin() async {
    isLoading = true;
    notifyListeners();

    final success = await _apiService.login(username, password);

    if (success) {
      // Opcionalmente podrías obtener info de usuario si tu API la devuelve
      currentUser = Usuario(
        nombreUsuario: username,
        nombreCompleto: username,
        contrasena: password,
      );
      isLoggedIn = true;
    } else {
      isLoggedIn = false;
      currentUser = null;
    }

    isLoading = false;
    notifyListeners();
    return isLoggedIn;
  }
}


