import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../viewmodels/login_viewmodel.dart';

import 'package:flutter/material.dart';

import '../models/persona.dart';

class DatosPacienteView extends StatefulWidget {
  final Paciente? paciente;
  final bool esRegistro; // true = registro nuevo, false = edición

  const DatosPacienteView({
    super.key,
    this.paciente,
    this.esRegistro = false,
  });

  @override
  State<DatosPacienteView> createState() => _DatosPacienteViewState();
}

class _DatosPacienteViewState extends State<DatosPacienteView> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _fechaNacimientoController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();

  String? _sexo;
  String? _antecedentes;
  String? _alcohol;

  @override
  void initState() {
    super.initState();

    _nombreController.text = widget.paciente?.nombre ?? '';
    _apellidoController.text = widget.paciente?.apellidos ?? '';
    _sexo = widget.paciente?.sexo;
    _correoController.text = widget.paciente?.correo ?? '';

    // Si es registro, generar código único
    if (widget.esRegistro) {
      _codigoController.text = _generarCodigoPaciente();
    }
  }

  String _generarCodigoPaciente() {
    final random = Random();
    final numero = 10000 + random.nextInt(89999);
    return "PAC$numero";
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _fechaNacimientoController.dispose();
    _codigoController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(1980),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _fechaNacimientoController.text =
        "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // 🔹 Llamada al backend para crear paciente
  Future<void> _crearPaciente() async {
    final token = Provider.of<LoginViewModel>(context, listen: false).token;
    final nombre = _nombreController.text.trim();
    final apellidos = _apellidoController.text.trim();
    final dni = _codigoController.text;
    final correo = _correoController.text.trim();
    final sexo = _sexo ?? "";
    final fechaNacimiento = _fechaNacimientoController.text;
    final antecedentes = _antecedentes ?? "";
    final alcohol = _alcohol ?? "";

    if (nombre.isEmpty || apellidos.isEmpty || correo.isEmpty || sexo.isEmpty || fechaNacimiento.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor completa todos los campos obligatorios")),
      );
      return;
    }

    final Map<String, dynamic> body = {
      "nombre": nombre,
      "apellidos": apellidos,
      "dni": dni,
      "sexo": sexo,
      "correo": correo,
      "fecha_nacimiento": fechaNacimiento,
      "antecedentes_familiares": antecedentes,
    };

    try {
      final url = Uri.parse("https://alzheimer-api-j5o0.onrender.com/pacientes/");
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      debugPrint("Status code: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Paciente registrado correctamente ✅")),
        );
        Navigator.pop(context);
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${data["detail"] ?? "Error desconocido"}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final paciente = widget.paciente;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                Text(
                  widget.esRegistro
                      ? "Registro de Nuevo Paciente"
                      : "Editar Datos de Paciente\n${paciente?.nombre ?? ''} ${paciente?.apellidos ?? ''}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),

                // 🔹 Nombre
                _buildTextField(
                  label: "Nombre",
                  controller: _nombreController,
                  hint: "Ingrese nombre del paciente",
                ),

                // 🔹 Apellidos
                _buildTextField(
                  label: "Apellidos",
                  controller: _apellidoController,
                  hint: "Ingrese apellidos del paciente",
                ),

                // 🔹 Sexo
                _buildDropdown(
                  "Sexo",
                  ["Masculino", "Femenino"],
                  _sexo,
                      (val) => setState(() => _sexo = val),
                ),

                // 🔹 Correo
                _buildTextField(
                  label: "Correo de contacto",
                  controller: _correoController,
                  hint: "Ingrese correo electrónico",
                  keyboard: TextInputType.emailAddress,
                ),

                // 🔹 Fecha de nacimiento
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Fecha de nacimiento",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _fechaNacimientoController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: "Seleccione una fecha",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _seleccionarFecha(context),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _buildDropdown(
                  "Antecedentes familiares",
                  ["Sí", "No"],
                  _antecedentes,
                      (val) => setState(() => _antecedentes = val),
                ),

                _buildDropdown(
                  "Consumo de alcohol",
                  ["Sí", "No"],
                  _alcohol,
                      (val) => setState(() => _alcohol = val),
                ),

                if (widget.esRegistro) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Código de paciente",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _codigoController,
                    readOnly: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                const SizedBox(height: 24),

                // 🔹 Botón Guardar
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: widget.esRegistro
                        ? _crearPaciente
                        : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Función de edición pendiente")),
                      );
                    },
                    child: Text(
                      widget.esRegistro ? "Registrar Paciente" : "Guardar Cambios",
                      style: const TextStyle(color: Colors.white),
                    ),
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
                  child: const Text("Salir"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Helpers ----------
  Widget _buildDropdown(
      String label, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          value: value,
          items: items
              .map((item) => DropdownMenuItem(
            value: item,
            child: Text(item),
          ))
              .toList(),
          onChanged: onChanged,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

