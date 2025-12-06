import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/login_viewmodel.dart';
import 'registro_view.dart';
import 'search_view.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Consumer<LoginViewModel>(
            builder: (context, vm, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Título principal
                  const Text(
                    "Inicio de\nSesión",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Campo de usuario
                  TextField(
                    onChanged: (value) => vm.username  = value,
                    decoration: const InputDecoration(
                      labelText: "Usuario",
                      hintText: "Ingrese su correo",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color(0xFFEDE7F6), // morado claro
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Campo de contraseña
                  TextField(
                    onChanged: (value) => vm.password = value,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Contraseña",
                      hintText: "Ingrese su contraseña",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color(0xFFEDE7F6),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Botón ingresar
                  vm.isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () async {
                        bool success = await vm.validateLogin();
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Login correcto ✅"),
                            ),
                          );
                        // 🔹 Esperar un poquito para que se muestre el snackbar
                          await Future.delayed(const Duration(milliseconds: 500));

                          // Navegar a otra vista (ejemplo: SearchView)
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SearchView(apiService: vm.apiService),
                          ));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Credenciales inválidas ❌"),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "Ingresar",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Texto de registro
                  const Text("¿No estás registrado?"),
                  const SizedBox(height: 8),

                  // Botón de registro
                  SizedBox(
                    height: 40,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.deepPurple),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegistroView()),
                        );
                      },
                      child: const Text(
                        "Registrarse",
                        style: TextStyle(color: Colors.deepPurple),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
