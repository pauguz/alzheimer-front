class Usuario {
  final String nombreUsuario;
  final String nombreCompleto;
  final String contrasena;

  Usuario({
    required this.nombreUsuario,
    required this.nombreCompleto,
    required this.contrasena,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      nombreUsuario: json['nombre_usuario'] ?? '',
      nombreCompleto: json['nombre_completo'] ?? '',
      contrasena: json['contrasena'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre_usuario': nombreUsuario,
      'nombre_completo': nombreCompleto,
      'contrasena': contrasena,
    };
  }
}
