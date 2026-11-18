import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Registro',
      home: RegistroPage(),
    ),
  );
}

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage>
    with SingleTickerProviderStateMixin {
  final nombreController = TextEditingController();
  final usuarioController = TextEditingController();
  final correoController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmarPasswordController = TextEditingController();

  bool ocultarPassword = true;
  bool ocultarConfirmacion = true;
  bool cargando = false;

  late AnimationController _controlador;
  late Animation<Color?> _color1;
  late Animation<Color?> _color2;
  late Animation<double> _aparicion;

  static const cafeOscuro = Color(0xFF3B2A1E);
  static const cafeMedio = Color(0xFF6B4A2F);
  static const cafeSuave = Color(0xFF9C7B5C);
  static const beige = Color(0xFFF3E9DC);
  static const beigeArena = Color(0xFFE5D3BC);
  static const crema = Color(0xFFFBF6EE);

  @override
  void initState() {
    super.initState();
    _controlador = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _color1 = ColorTween(begin: beige, end: beigeArena).animate(_controlador);
    _color2 = ColorTween(begin: crema, end: beige).animate(_controlador);
    _aparicion = CurvedAnimation(
      parent: _controlador,
      curve: const Interval(0, 0.3, curve: Curves.easeOut),
    );

    _controlador.forward();
  }

  @override
  void dispose() {
    _controlador.dispose();
    nombreController.dispose();
    usuarioController.dispose();
    correoController.dispose();
    passwordController.dispose();
    confirmarPasswordController.dispose();
    super.dispose();
  }

  Future<void> registrar() async {
    final campos = [
      nombreController.text.trim(),
      usuarioController.text.trim(),
      correoController.text.trim(),
      passwordController.text,
      confirmarPasswordController.text,
    ];

    if (campos.any((campo) => campo.isEmpty)) {
      _mensaje('Completa todos los campos');
      return;

    }

    if (!campos[2].contains('@')) {
      _mensaje('Ingresa un correo válido');
      return;
    }

    if (campos[3].length < 6) {
      _mensaje('La contraseña debe tener al menos 6 caracteres');
      return;
    }

    if (campos[3] != campos[4]) {
      _mensaje('Las contraseñas no coinciden');
      return;
    }

    setState(() => cargando = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => cargando = false);
    _mensaje('Registro completado', color: cafeMedio);
  }

  void _mensaje(String texto, {Color? color}) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(texto), backgroundColor: color));
  }

  Widget _animado({required Widget child, required int orden}) {
    return AnimatedBuilder(
      animation: _aparicion,
      builder: (context, widget) {
        final retraso = orden * 0.1;
        final progreso = ((_aparicion.value - retraso) / (1 - retraso)).clamp(
          0.0,
          1.0,
        );
        return Opacity(
          opacity: progreso,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - progreso)),
            child: widget,
          ),
        );
      },
      child: child,
    );
  }

  InputDecoration _decoracion(String etiqueta, IconData icono) {
    return InputDecoration(
      labelText: etiqueta,
      labelStyle: const TextStyle(color: cafeSuave),
      prefixIcon: Icon(icono, color: cafeMedio),
      filled: true,
      fillColor: beige.withValues(alpha: 0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: cafeMedio, width: 2),
      ),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String etiqueta,
    required IconData icono,
    bool ocultar = false,
    VoidCallback? cambiarVisibilidad,
  }) {
    return TextField(
      controller: controller,
      obscureText: ocultar,
      style: const TextStyle(color: cafeOscuro),
      decoration: _decoracion(etiqueta, icono).copyWith(
        suffixIcon: cambiarVisibilidad == null
            ? null
            : IconButton(
                icon: Icon(
                  ocultar
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: cafeSuave,
                ),
                onPressed: cambiarVisibilidad,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controlador,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _color1.value!,
                  _color2.value!,
                  beigeArena.withValues(alpha: 0.7),
                  cafeSuave.withValues(alpha: 0.25),
                ],
              ),
            ),
            child: child,
          );
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 12,
              shadowColor: cafeOscuro.withValues(alpha: 0.35),
              color: crema,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: SizedBox(
                  width: 350,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _animado(
                        orden: 0,
                        child: TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.elasticOut,
                          builder: (context, valor, child) {
                            return Transform.scale(scale: valor, child: child);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: beige,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: cafeMedio.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person_add_alt_1_rounded,
                              size: 55,
                              color: cafeMedio,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _animado(
                        orden: 1,
                        child: const Text(
                          'REGISTRARSE',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: cafeOscuro,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      _animado(
                        orden: 2,
                        child: _campo(
                          controller: nombreController,
                          etiqueta: 'Nombre completo',
                          icono: Icons.person,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _animado(
                        orden: 3,
                        child: _campo(
                          controller: usuarioController,
                          etiqueta: 'Usuario',
                          icono: Icons.account_circle_outlined,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _animado(
                        orden: 4,
                        child: _campo(
                          controller: correoController,
                          etiqueta: 'Correo electrónico',
                          icono: Icons.email_outlined,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _animado(
                        orden: 5,
                        child: _campo(
                          controller: passwordController,
                          etiqueta: 'Contraseña',
                          icono: Icons.lock_outline,
                          ocultar: ocultarPassword,
                          cambiarVisibilidad: () => setState(
                            () => ocultarPassword = !ocultarPassword,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _animado(
                        orden: 6,
                        child: _campo(
                          controller: confirmarPasswordController,
                          etiqueta: 'Confirmar contraseña',
                          icono: Icons.lock_reset_outlined,
                          ocultar: ocultarConfirmacion,
                          cambiarVisibilidad: () => setState(
                            () => ocultarConfirmacion = !ocultarConfirmacion,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _animado(
                        orden: 7,
                        child: _BotonRegistro(
                          cargando: cargando,
                          onPressed: registrar,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _animado(
                        orden: 8,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: cafeOscuro,
                          ),
                          child: const Text('Volver a iniciar sesión'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BotonRegistro extends StatefulWidget {
  final bool cargando;
  final VoidCallback onPressed;

  const _BotonRegistro({required this.cargando, required this.onPressed});

  @override
  State<_BotonRegistro> createState() => _BotonRegistroState();
}

class _BotonRegistroState extends State<_BotonRegistro> {
  bool presionado = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.cargando
          ? null
          : (_) => setState(() => presionado = true),
      onTapUp: widget.cargando
          ? null
          : (_) {
              setState(() => presionado = false);
              widget.onPressed();
            },
      onTapCancel: () => setState(() => presionado = false),
      child: AnimatedScale(
        scale: presionado ? 0.94 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: _RegistroPageState.cafeMedio,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: _RegistroPageState.cafeOscuro.withValues(alpha: 0.4),
                blurRadius: presionado ? 2 : 8,
                offset: Offset(0, presionado ? 1 : 5),
              ),
            ],
          ),
          child: Center(
            child: widget.cargando
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'CREAR CUENTA',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
