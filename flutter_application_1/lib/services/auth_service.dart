
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

class AuthService {
  // Validar datos del inicio de sesion
  String? validarLogin({
    required String usuario,
    required String password,
  }) {
    if (usuario.trim().isEmpty || password.isEmpty) {
      return 'Ingresa tu correo y contraseña';
    }
    return null;
  }

  // Validar datos del registro
  String? validarRegistro({
    required String nombre,
    required String correo,
    required String password,
    required String confirmarpassword,
  }) {
    if (nombre.isEmpty ||
        correo.isEmpty ||
        password.isEmpty ||
        confirmarpassword.isEmpty) {
      return 'Completa todos los campos';
    }

    if (!correo.contains('@')) {
      return 'Ingresa un correo valido';
    }

    if (password.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }

    if (password != confirmarpassword) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  // Iniciar sesion y guardar el token
  Future<Map<String, dynamic>> autenticar({
    required String correo,
    required String password,
  }) async {
    final respuesta = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/login'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'mail': correo.trim().toLowerCase(),
            'password': password,
          }),
        )
        .timeout(const Duration(seconds: 10));

    final dynamic resultado = jsonDecode(respuesta.body);

    if (respuesta.statusCode == 200 &&
        resultado is Map<String, dynamic>) {

      final token = resultado['access_token'];

      if (token == null || token.toString().isEmpty) {
        throw Exception('La API no devolvio el token de acceso');
      }

      // Guardar el token en el dispositivo
      final preferencias = await SharedPreferences.getInstance();
      await preferencias.setString('access_token', token.toString());

      // Guardar datos basicos del usuario
      await preferencias.setInt('id_usr', resultado['id_usr']);
      await preferencias.setString('nom_usr', resultado['nom_usr']);
      await preferencias.setString('mail', resultado['mail']);
      await preferencias.setInt('tip_usu', resultado['tip_usu']);

      return resultado;
    }

    if (respuesta.statusCode == 401) {
      throw Exception('Correo o contraseña incorrectos');
    }

    if (resultado is Map && resultado['detail'] != null) {
      throw Exception(resultado['detail'].toString());
    }

    throw Exception(
      'Error al iniciar sesion: HTTP ${respuesta.statusCode}',
    );
  }

  // Recuperar el token guardado
  Future<String?> obtenerToken() async {
    final preferencias = await SharedPreferences.getInstance();
    return preferencias.getString('access_token');
  }

  // Cerrar sesion y borrar los datos guardados
  Future<void> cerrarSesion() async {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.remove('access_token');
    await preferencias.remove('id_usr');
    await preferencias.remove('nom_usr');
    await preferencias.remove('mail');
    await preferencias.remove('tip_usu');
  }
}
