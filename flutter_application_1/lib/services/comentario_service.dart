import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/comentario_model.dart';
import 'api_config.dart';

class ComentarioService {
  static final String baseUrl = ApiConfig.baseUrl;

  // Consultar todos los comentarios
  Future<List<ComentarioModel>> obtenerComentarios() async {
    final respuesta = await http
        .get(
          Uri.parse('$baseUrl/comentarios'),
          headers: {
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (respuesta.statusCode != 200) {
      throw Exception('Error al consultar comentarios');
    }

    final List<dynamic> datos = jsonDecode(respuesta.body);

    return datos
        .map(
          (json) => ComentarioModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  // Registrar un comentario con el usuario autenticado
  Future<void> agregarComentario(
    ComentarioModel comentario,
  ) async {
    // Recuperar el token guardado al iniciar sesion
    final preferencias = await SharedPreferences.getInstance();
    final token = preferencias.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Debes iniciar sesion para comentar');
    }

    final respuesta = await http
        .post(
          Uri.parse('$baseUrl/comentarios'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(comentario.toJsonCrear()),
        )
        .timeout(const Duration(seconds: 10));

    if (respuesta.statusCode == 201) {
      return;
    }

    if (respuesta.statusCode == 401) {
      throw Exception(
        'Tu sesion expiro. Inicia sesion nuevamente',
      );
    }

    final dynamic resultado = respuesta.body.isNotEmpty
        ? jsonDecode(respuesta.body)
        : null;

    if (resultado is Map && resultado['detail'] != null) {
      throw Exception(resultado['detail'].toString());
    }

    throw Exception(
      'No se pudo registrar el comentario: HTTP ${respuesta.statusCode}',
    );
  }
}