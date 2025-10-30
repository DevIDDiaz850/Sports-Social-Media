import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'dart:convert';

class GameDetailsScreen extends StatefulWidget {
  final String statId;

  const GameDetailsScreen({Key? key, required this.statId}) : super(key: key);

  @override
  _GameDetailsScreenState createState() => _GameDetailsScreenState();
}

class _GameDetailsScreenState extends State<GameDetailsScreen> {
  List<dynamic>? statDetails;
  final String baseUrl = 'http://localhost:3000'; // Cambia si estás en prod

  @override
  void initState() {
    super.initState();
    _fetchStatDetails();
  }

  Future<void> _fetchStatDetails() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/stat/${widget.statId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List) {
          setState(() {
            statDetails = data;
          });
        } else {
          throw Exception('Respuesta inesperada del servidor');
        }
      } else {
        throw Exception('Error al obtener los detalles del juego');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _deleteGame() async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/gameDelete/${widget.statId}'),
      );
      if (response.statusCode == 200) {
        // Redirigir al Home después de eliminar el juego
        context.go('/home');
      } else {
        throw Exception('Error al eliminar el juego');
      }
    } catch (e) {
      print('Error eliminando: $e');
    }
  }

  void _updateGame() {
    context.push('/editStats/${widget.statId}');
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text(
            '¿Estás seguro de que deseas eliminar este juego?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo sin hacer nada
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
                _deleteGame(); // Eliminar el juego si el usuario confirma
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (statDetails == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalles del Juego')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (statDetails!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalles del Juego')),
        body: const Center(child: Text('No se encontraron estadísticas')),
      );
    }

    final gameName = statDetails![0]['game_name'];
    final player = statDetails![0]['player'];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalles del Juego',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 192, 77),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 2,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.account_circle,
                    color: const Color.fromARGB(255, 228, 228, 228),
                    size: 100,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Juego: $gameName',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Jugador: $player',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                ...statDetails!.map(
                  (stat) => Column(
                    children: [
                      _buildDetailRow(stat['stat_type'], stat['value']),
                      const Divider(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _showDeleteConfirmationDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 211, 77, 68),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.delete, color: Colors.white),
                      label: const Text(
                        'Eliminar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _updateGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 2, 172, 2),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text(
                        'Actualizar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Text(value?.toString() ?? '0', style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
