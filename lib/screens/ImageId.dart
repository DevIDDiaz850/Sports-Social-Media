// Añade este import para mostrar snackbar
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PostImageId extends StatelessWidget {
  final int postId;

  const PostImageId({super.key, required this.postId});

  Future<Map<String, dynamic>> fetchPost() async {
    try {
      final url = Uri.parse('http://localhost:3000/api/post/$postId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error en la respuesta: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePost(BuildContext context) async {
    final url = Uri.parse('http://localhost:3000/api/posts/$postId');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Post eliminado con éxito")),
        );
        Navigator.pop(context); // Cierra pantalla actual
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Error: ${json.decode(response.body)['message']}"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❗ Error: $e")));
    }
  }

  void showOptionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text("Actualizar"),
                onTap: () {
                  Navigator.pop(context); // cerrar modal
                  // Aquí podrías navegar a otra pantalla para actualizar
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  "Eliminar",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context); // cerrar modal
                  showDialog(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: const Text("¿Eliminar publicación?"),
                          content: const Text(
                            "Esta acción no se puede deshacer.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancelar"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Cerrar diálogo
                                deletePost(context); // Eliminar post
                              },
                              child: const Text(
                                "Eliminar",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Publicaciones"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchPost(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final post = snapshot.data!;
          final username = post['username'] ?? 'Usuario';
          final content = post['content'] ?? '';
          final imageUrl = post['image_url'];
          final createdAt = post['created_at'];

          String formattedDate = '';
          try {
            formattedDate =
                DateTime.parse(createdAt).toLocal().toString().split(' ')[0];
          } catch (e) {
            formattedDate = 'Fecha desconocida';
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Info
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    child: ClipOval(
                      child: Image.network(
                        'https://randomuser.me/api/portraits/men/32.jpg',
                        fit: BoxFit.cover,
                        width: 40,
                        height: 40,
                        errorBuilder:
                            (_, __, ___) => const Icon(
                              Icons.person,
                              size: 40,
                              color: Color.fromARGB(255, 148, 148, 148),
                            ),
                      ),
                    ),
                  ),
                  title: Text(username),
                  subtitle: const Text("Ubicación genérica"),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => showOptionsModal(context),
                  ),
                ),

                // Post Image
                if (imageUrl != null)
                  Image.network(
                    'http://localhost:3000$imageUrl',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, error, __) =>
                            const Center(child: Text("Imagen no disponible")),
                  )
                else
                  const Center(child: Text("Imagen no disponible")),

                const SizedBox(height: 10),

                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text("$username: $content"),
                ),
                const SizedBox(height: 6),

                // Date
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    "Publicado el $formattedDate",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
