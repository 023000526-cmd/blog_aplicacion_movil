
class ComentarioModel {
  final int? id;
  final String comentario;
  final String? fecha;
  final int? estatus;
  final int? usuarioId;
  final String? nombreUsuario;
  final int blogId;

  ComentarioModel({
    this.id,
    required this.comentario,
    this.fecha,
    this.estatus,
    this.usuarioId,
    this.nombreUsuario,
    required this.blogId,
  });

  // Convertir los datos de la API en un comentario
  factory ComentarioModel.fromJson(Map<String, dynamic> json) {
    return ComentarioModel(
      id: json['id_com'] as int?,
      comentario: json['comentario'] as String,
      fecha: json['fecha']?.toString(),
      estatus: json['estatus'] as int?,
      usuarioId: json['usr_id'] as int?,
      nombreUsuario: json['nombre_usuario']?.toString(),
      blogId: json['blog_id'] as int,
    );
  }

  // Preparar los datos para registrar un comentario
  Map<String, dynamic> toJsonCrear() {
    return {
      'comentario': comentario,
      'blog_id': blogId,
    };
  }
}
