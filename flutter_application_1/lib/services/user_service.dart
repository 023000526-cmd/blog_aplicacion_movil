
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_config.dart';

class UserService {
  static final String baseUrl = ApiConfig.baseUrl;

  // Obtener el token guardado al iniciar sesion.
  Future<Map<String, String>> _headersAutenticados() async {
    final preferencias = await SharedPreferences.getInstance();
    final token = preferencias.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('No hay una sesion activa. Inicia sesion nuevamente.');
    }

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Consultar usuarios (solo administrador).
  Future<List<UserModel>> obtenerUsuarios() async {
    final respuesta = await http
        .get(
          Uri.parse('$baseUrl/usuarios'),
          headers: await _headersAutenticados(),
        )
        .timeout(const Duration(seconds: 10));

    if (respuesta.statusCode != 200) {
      throw Exception(
        'Error al consultar usuarios: ${respuesta.statusCode}',
      );
    }

    final List<dynamic> datos = jsonDecode(respuesta.body);

    return datos
        .map(
          (json) => UserModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  // Registrar usuario (no requiere token).
  Future<UserModel> agregarUsuario(UserModel usuario) async {
    final respuesta = await http
        .post(
          Uri.parse('$baseUrl/usuarios'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(usuario.toJsonCrear()),
        )
        .timeout(const Duration(seconds: 10));

    if (respuesta.statusCode == 201) {
      return UserModel.fromJson(
        jsonDecode(respuesta.body) as Map<String, dynamic>,
      );
    }

    throw Exception(_mensajeError(respuesta));
  }

  // Iniciar sesion.
  Future<UserModel> iniciarSesion({
    required String correo,
    required String password,
  }) async {
    final respuesta = await http
        .post(
          Uri.parse('$baseUrl/login'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'mail': correo,
            'password': password,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (respuesta.statusCode == 200) {
      return UserModel.fromJson(
        jsonDecode(respuesta.body) as Map<String, dynamic>,
      );
    }

    throw Exception(_mensajeError(respuesta));
  }

  // Actualizar usuario (solo administrador).
  Future<UserModel> actualizarUsuario(UserModel usuario) async {
    final respuesta = await http
        .put(
          Uri.parse('$baseUrl/usuarios/${usuario.id}'),
          headers: await _headersAutenticados(),
          body: jsonEncode({
            'nom_usr': usuario.nombre,
            'mail': usuario.correo,
            'dir_usr': usuario.direccion,
            'tip_usu': usuario.tipoUsuario,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (respuesta.statusCode == 200) {
      return UserModel.fromJson(
        jsonDecode(respuesta.body) as Map<String, dynamic>,
      );
    }

    throw Exception(_mensajeError(respuesta));
  }

  // Eliminar usuario (solo administrador).
  Future<void> eliminarUsuario(int id) async {
    final respuesta = await http
        .delete(
          Uri.parse('$baseUrl/usuarios/$id'),
          headers: await _headersAutenticados(),
        )
        .timeout(const Duration(seconds: 10));

    if (respuesta.statusCode != 200 &&
        respuesta.statusCode != 204) {
      throw Exception(_mensajeError(respuesta));
    }
  }

  String _mensajeError(http.Response respuesta) {
    try {
      final datos = jsonDecode(respuesta.body);

      if (datos is Map && datos['detail'] != null) {
        return datos['detail'].toString();
      }
    } catch (_) {
      // La respuesta no contiene JSON.
    }

    return 'Error HTTP ${respuesta.statusCode}: ${respuesta.body}';
  }
}
