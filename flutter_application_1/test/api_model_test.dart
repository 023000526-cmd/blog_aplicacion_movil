import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/models/comentario_model.dart';
import 'package:flutter_application_1/models/post_model.dart';
import 'package:flutter_application_1/models/user_model.dart';

void main() {
  test(
    'PostModel lee la respuesta de /blog y acepta campos opcionales nulos',
    () {
      final post = PostModel.fromJson({
        'id_blog': 7,
        'titulo': 'Publicación',
        'descripcion': null,
        'img': null,
        'tags': 'Flutter',
      });

      expect(post.id, 7);
      expect(post.titulo, 'Publicación');
      expect(post.descripcion, '');
      expect(post.imagen, '');
      expect(post.tags, 'Flutter');
    },
  );

  test('UserModel y ComentarioModel usan las claves del API', () {
    final usuario = UserModel.fromJson({
      'id_usr': 3,
      'nom_usr': 'Ana',
      'mail': 'ana@example.com',
      'dir_usr': null,
      'tip_usu': 1,
    });
    final comentario = ComentarioModel(
      id: 0,
      comentario: 'Buen artículo',
      fecha: '',
      estatus: 1,
      usuarioId: usuario.id,
      blogId: 7,
    );

    expect(usuario.id, 3);
    expect(comentario.toJsonCrear(), {
      'comentario': 'Buen artículo',
      'usr_id': 3,
      'blog_id': 7,
    });
  });

  test('el tipo de usuario predeterminado para registro es cliente', () {
    final usuario = UserModel(
      id: 0,
      nombre: 'Cliente',
      correo: 'cliente@example.com',
      password: 'password-seguro',
    );

    expect(usuario.toJsonCrear()['tip_usu'], 2);
  });
}
