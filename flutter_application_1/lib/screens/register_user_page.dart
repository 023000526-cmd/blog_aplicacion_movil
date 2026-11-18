import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_card.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nombreController = TextEditingController();

  final TextEditingController correoController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmarController = TextEditingController();

  final AuthService authService = AuthService();

  final UserService userService = UserService();

  Map<String, dynamic> usuarioActual = {};
  bool argumentoLeido = false;
  bool cargando = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (argumentoLeido) return;

    final argumento = ModalRoute.of(context)?.settings.arguments;
    if (argumento is Map<String, dynamic>) {
      usuarioActual = Map<String, dynamic>.from(argumento);
    }
    argumentoLeido = true;
  }

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    passwordController.dispose();
    confirmarController.dispose();

    super.dispose();
  }

  Future<void> registrarUsuario() async {
    if (cargando) return;

    final mensaje = authService.validarRegistro(
      nombre: nombreController.text.trim(),
      correo: correoController.text.trim(),
      password: passwordController.text,
      confirmarpassword: confirmarController.text,
    );

    if (mensaje != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensaje)));
      return;
    }

    setState(() => cargando = true);

    try {
      await userService.agregarUsuario(
        UserModel(
          id: 0,
          nombre: nombreController.text.trim(),
          correo: correoController.text.trim(),
          password: passwordController.text,
          tipoUsuario: 2,
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Usuario ${nombreController.text.trim()} registrado'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo registrar: $e')));
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final esAdmin = (usuarioActual['tip_usu'] as num?)?.toInt() == 1;

    return Scaffold(
      appBar: esAdmin ? AppBar(title: const Text('Registrar usuario')) : null,
      drawer: esAdmin
          ? AdminDrawer(usuario: usuarioActual, rutaActual: '/register')
          : null,

      body: AuthBackground(
        child: Center(
          child: AuthCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                const Icon(
                  Icons.person_add,
                  size: 65,
                  color: Color(0xFF2196F3),
                ),

                const SizedBox(height: 15),

                const Text(
                  'CREAR CUENTA',

                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF08245C),
                  ),
                ),

                const SizedBox(height: 25),

                CustomTextField(
                  controller: nombreController,

                  label: 'Nombre completo',

                  prefixIcon: Icons.person,
                ),

                const SizedBox(height: 15),

                CustomTextField(
                  controller: correoController,

                  label: 'Correo electrónico',

                  prefixIcon: Icons.email,

                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 15),

                CustomTextField(
                  controller: passwordController,

                  label: 'Contraseña',

                  prefixIcon: Icons.lock,

                  obscureText: true,
                ),

                const SizedBox(height: 15),

                CustomTextField(
                  controller: confirmarController,

                  label: 'Confirmar contraseña',

                  prefixIcon: Icons.lock_outline,

                  obscureText: true,
                ),

                const SizedBox(height: 25),

                PrimaryButton(text: 'REGISTRARME', onPressed: registrarUsuario),

                const SizedBox(height: 15),

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  child: const Text('Ya tengo una cuenta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
