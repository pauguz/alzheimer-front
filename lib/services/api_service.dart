import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/persona.dart';
import '../models/usuario.dart';

class ApiService {
  static const String baseUrl = 'https://alzheimer-api-j5o0.onrender.com';
  String? _token; // Se guarda el token JWT tras el login

  /// LOGIN: obtiene token desde /token
  Future<bool> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/token');
    final body = {
      'username': username,
      'password': password,
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _token = data['access_token'];
      return true;
    } else {
      print('Error en login: ${response.body}');
      return false;
    }
  }

  /// OBTENER LISTA DE PACIENTES (requiere token válido)
  Future<List<Paciente>> fetchPacientes() async {
    if (_token == null) {
      throw Exception('Debes iniciar sesión primero.');
    }

    final url = Uri.parse('$baseUrl/pacientes/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Paciente.fromJson(json)).toList();
    } else {
      print('Error al obtener pacientes: ${response.body}');
      throw Exception('Error al obtener pacientes');
    }
  }

  /// (Opcional) Registrar usuario
  Future<bool> registrarUsuario(
      String nombreUsuario, String nombreCompleto, String contrasena) async {
    final url = Uri.parse('$baseUrl/register/');
    final body = jsonEncode({
      'nombre_usuario': nombreUsuario,
      'nombre_completo': nombreCompleto,
      'contrasena': contrasena,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      print('Error en registro: ${response.body}');
      return false;
    }
  }

  /// Getter del token
  String? get token => _token;
}
