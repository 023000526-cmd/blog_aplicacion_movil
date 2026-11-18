import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/screens/login_user_page.dart';
import 'package:flutter_application_1/screens/users_page.dart';

void main() {
  testWidgets('app loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const LoginApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('INICIAR SESIÓN'), findsOneWidget);
  });

  testWidgets('el enlace de recuperación abre su pantalla', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const LoginApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('¿Olvidaste tu contraseña?'));
    await tester.pumpAndSettle();

    expect(find.text('Restablecer acceso'), findsOneWidget);
  });

  testWidgets('login valida que se completen los campos', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(0.6)),
        child: MaterialApp(
          home: const LoginPage(),
          routes: {'/users': (context) => const UsersPage()},
        ),
      ),
    );

    await tester.tap(find.text('INGRESAR'));
    await tester.pumpAndSettle();

    expect(find.text('Ingresa tu correo y contraseña'), findsOneWidget);
  });

  testWidgets('la lista de usuarios muestra el error de API', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const UsersPage(),
        routes: {
          '/login': (context) => const LoginPage(),
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No se pudieron cargar los usuarios.'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);

    await tester.tap(find.byTooltip('Cerrar sesión'));
    await tester.pumpAndSettle();

    expect(find.text('INICIAR SESIÓN'), findsOneWidget);
  });
}
