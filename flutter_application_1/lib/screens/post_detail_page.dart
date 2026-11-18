
import 'package:flutter/material.dart';

import '../models/comentario_model.dart';
import '../models/post_model.dart';
import '../services/comentario_service.dart';

class PostDetailPage extends StatefulWidget {
  final PostModel post;

  const PostDetailPage({
    super.key,
    required this.post,
  });

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final ComentarioService comentarioService = ComentarioService();
  final TextEditingController comentarioController =
      TextEditingController();

  late Future<List<ComentarioModel>> futuroComentarios;

  bool enviandoComentario = false;

  PostModel get post => widget.post;

  @override
  void initState() {
    super.initState();
    futuroComentarios = cargarComentarios();
  }

  @override
  void dispose() {
    comentarioController.dispose();
    super.dispose();
  }

  Future<List<ComentarioModel>> cargarComentarios() async {
    final todos = await comentarioService.obtenerComentarios();

    return todos.where((c) => c.blogId == post.id).toList();
  }

  void recargarComentarios() {
    setState(() {
      futuroComentarios = cargarComentarios();
    });
  }

  Future<void> enviarComentario() async {
    final texto = comentarioController.text.trim();

    if (texto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escribe un comentario antes de enviarlo'),
        ),
      );
      return;
    }

    setState(() {
      enviandoComentario = true;
    });

    try {
      final nuevoComentario = ComentarioModel(
        comentario: texto,
        blogId: post.id,
      );

      await comentarioService.agregarComentario(nuevoComentario);

      comentarioController.clear();

      if (!mounted) return;

      setState(() {
        futuroComentarios = cargarComentarios();
        enviandoComentario = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comentario registrado correctamente'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        enviandoComentario = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo registrar el comentario: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de publicación'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.imagen.isNotEmpty)
              Image.network(
                post.imagen,
                height: 230,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    height: 150,
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 48,
                      ),
                    ),
                  );
                },
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.tags.isNotEmpty) ...[
                    Text(
                      post.tags,
                      style: const TextStyle(
                        color: Color(0xFF2196F3),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  Text(
                    post.titulo,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF08245C),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    post.descripcion.isNotEmpty
                        ? post.descripcion
                        : 'Esta publicación no tiene descripción.',
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Comentarios',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF08245C),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: recargarComentarios,
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Actualizar comentarios',
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  FutureBuilder<List<ComentarioModel>>(
                    future: futuroComentarios,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError) {
                        return Text(
                          'No se pudieron cargar los comentarios: '
                          '${snapshot.error}',
                        );
                      }

                      final comentarios = snapshot.data ?? [];

                      if (comentarios.isEmpty) {
                        return const Text(
                          'Esta publicación aún no tiene comentarios.',
                        );
                      }

                      return Column(
                        children: comentarios.map((c) {
                          final fecha = (c.fecha ?? '')
                              .replaceFirst('T', ' ');

                          final nombre = c.nombreUsuario?.trim().isNotEmpty == true
                              ? c.nombreUsuario!.trim()
                              : 'Usuario eliminado';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                              title: Text(c.comentario),
                              subtitle: Text(
                                '$nombre'
                                '${fecha.isNotEmpty ? " · $fecha" : ""}',
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    'Escribe un comentario',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF08245C),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: comentarioController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Comparte tu opinión...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          enviandoComentario ? null : enviarComentario,
                      icon: enviandoComentario
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send),
                      label: Text(
                        enviandoComentario
                            ? 'Enviando...'
                            : 'Publicar comentario',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
