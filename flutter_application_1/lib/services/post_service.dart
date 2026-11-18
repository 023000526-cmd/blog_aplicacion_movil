
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/post_model.dart';
import 'api_config.dart';

class PostService {
  static final String baseUrl = ApiConfig.baseUrl;

  // Consultar todas las publicaciones
  Future<List<PostModel>> obtenerPosts() async {
    final respuesta = await http.get(
      Uri.parse('$baseUrl/blog'),
    );

    if (respuesta.statusCode != 200) {
      throw Exception('Error al consultar publicaciones');
    }

    final List<dynamic> datos = jsonDecode(respuesta.body);

    return datos
        .map(
          (json) => PostModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  // Crear una publicacion con el usuario autenticado
  Future<PostModel> agregarPost({
    required String titulo,
    required String descripcion,
    String? imagen,
    String? tags,
  }) async {
    // Recuperar el token guardado al iniciar sesion
    final preferencias = await SharedPreferences.getInstance();
    final token = preferencias.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Debes iniciar sesion para publicar');
    }

    final respuesta = await http
        .post(
          Uri.parse('$baseUrl/blog'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'titulo': titulo.trim(),
            'descripcion': descripcion.trim(),
            'img': (imagen ?? '').trim().isEmpty
                ? null
                : imagen!.trim(),
            'tags': (tags ?? '').trim().isEmpty
                ? null
                : tags!.trim(),
          }),
        )
        .timeout(const Duration(seconds: 10));

    final dynamic resultado = respuesta.body.isNotEmpty
        ? jsonDecode(respuesta.body)
        : null;

    if ((respuesta.statusCode == 200 ||
            respuesta.statusCode == 201) &&
        resultado is Map<String, dynamic>) {
      return PostModel.fromJson(resultado);
    }

    if (respuesta.statusCode == 401) {
      throw Exception('Tu sesion expiro. Inicia sesion nuevamente');
    }

    if (resultado is Map && resultado['detail'] != null) {
      throw Exception(resultado['detail'].toString());
    }

    throw Exception(
      'No se pudo guardar la publicacion (HTTP ${respuesta.statusCode})',
    );
  }
}
