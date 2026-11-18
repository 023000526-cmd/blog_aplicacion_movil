
import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/post_card.dart';
import 'post_detail_page.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({super.key});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  final PostService postService = PostService();

  late Future<List<PostModel>> futurePosts;

  String nombreUsuario = 'Usuario';
  Map<String, dynamic> usuarioActual = {
    'nom_usr': 'Usuario',
    'mail': '',
    'tip_usu': 2,
  };

  bool argumentoLeido = false;

  @override
  void initState() {
    super.initState();
    futurePosts = postService.obtenerPosts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (argumentoLeido) return;

    final argumento = ModalRoute.of(context)?.settings.arguments;

    if (argumento is Map<String, dynamic>) {
      usuarioActual = Map<String, dynamic>.from(argumento);
      nombreUsuario =
          usuarioActual['nom_usr']?.toString() ?? 'Usuario';
    } else if (argumento is String && argumento.isNotEmpty) {
      nombreUsuario = argumento;
      usuarioActual = {
        'nom_usr': nombreUsuario,
        'mail': '',
        'tip_usu': 2,
      };
    }

    argumentoLeido = true;
  }

  void recargarPosts() {
    setState(() {
      futurePosts = postService.obtenerPosts();
    });
  }

  void irACrearPublicacion() {
    Navigator.pushNamed(
      context,
      '/add-blog',
      arguments: usuarioActual,
    ).then((resultado) {
      if (!mounted) return;
      recargarPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final esAdmin =
        (usuarioActual['tip_usu'] as num? ?? 2).toInt() == 1;

    return Scaffold(
      drawer: esAdmin
          ? AdminDrawer(
              usuario: usuarioActual,
              rutaActual: '/blog',
            )
          : null,

      appBar: AppBar(
        title: const Text('Mi Blog'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            ),
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),

          if (esAdmin)
            IconButton(
              onPressed: () => Navigator.pushNamed(
                context,
                '/users',
                arguments: usuarioActual,
              ),
              icon: const Icon(Icons.people),
              tooltip: 'Gestión de usuarios',
            ),

          IconButton(
            onPressed: recargarPosts,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar publicaciones',
          ),
        ],
      ),

      body: FutureBuilder<List<PostModel>>(
        future: futurePosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 45),
                    const SizedBox(height: 12),
                    const Text(
                      'No fue posible cargar el blog.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: recargarPosts,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final posts = snapshot.data ?? <PostModel>[];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Bienvenido, $nombreUsuario',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF08245C),
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Descubre nuevas ideas',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 20),

              if (posts.isEmpty)
                const Center(
                  child: Text('No hay publicaciones registradas.'),
                )
              else
                ...posts.map(
                  (post) => PostCard(
                    post: post,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              PostDetailPage(post: post),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),

      floatingActionButton: esAdmin
          ? FloatingActionButton.extended(
              onPressed: irACrearPublicacion,
              icon: const Icon(Icons.add),
              label: const Text('Nueva publicación'),
            )
          : null,
    );
  }
}
