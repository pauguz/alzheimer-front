class Analysis {
  final int id;
  final int pacienteId;
  final String fecha;
  final String rutaImagenMRI;
  final String resultadoTecnico;
  final String resultadoExplicado;

  Analysis({
    required this.id,
    required this.pacienteId,
    required this.fecha,
    required this.rutaImagenMRI,
    required this.resultadoTecnico,
    required this.resultadoExplicado,
  });

  factory Analysis.fromJson(Map<String, dynamic> json) {
    return Analysis(
      id: json["id"],
      pacienteId: json["paciente_id"],
      fecha: json["fecha"],
      rutaImagenMRI: json["ruta_imagen_mri"],
      resultadoTecnico: json["resultado_tecnico"],
      resultadoExplicado: json["resultado_explicado"],
    );
  }
}
