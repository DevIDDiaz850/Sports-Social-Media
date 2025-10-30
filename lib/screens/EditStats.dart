import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditStatsScreen extends StatefulWidget {
  final int? gameId;

  const EditStatsScreen({Key? key, this.gameId}) : super(key: key);

  @override
  _EditStatsScreenState createState() => _EditStatsScreenState();
}

class _EditStatsScreenState extends State<EditStatsScreen> {
  int? userId;
  late int? gameId;
  String gameName = '';
  final TextEditingController gameNameController = TextEditingController();
  List<Map<String, dynamic>> statTypes = [];
  Map<String, int> statValues = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _getUserId();
    _extractGameIdFromRoute();

    if (gameId != null) {
      await _fetchGameStats();
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
  }

  void _extractGameIdFromRoute() {
    final state = GoRouterState.of(context);
    final idParam = state.pathParameters['gameId'];
    gameId =
        idParam != null
            ? int.tryParse(idParam) ?? widget.gameId
            : widget.gameId;
  }

  Future<void> _fetchGameStats() async {
    final url = Uri.parse('http://localhost:3000/api/stat/$gameId');

    try {
      final response = await http.get(url);
      print(
        '📥 Respuesta recibida: ${response.body}',
      ); // Imprime la respuesta JSON

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          gameName = data[0]['game_name'];
          gameNameController.text = gameName;

          final Set<String> addedStatIds = {};

          for (var item in data) {
            final String statName = item['stat_type'];
            final int value = item['value'] ?? 0;
            final String statTypeId =
                item['stat_type_id'].toString(); // Convertir a String

            if (!addedStatIds.contains(statTypeId)) {
              statTypes.add({'id': statTypeId, 'name': statName});
              addedStatIds.add(statTypeId);
            }

            statValues[statTypeId] = value;
          }
        }
      } else {
        _showSnackBar('Error al cargar estadísticas. Intenta nuevamente.');
      }
    } catch (e) {
      _showSnackBar('No se pudo conectar al servidor.');
      print('❌ Error al obtener estadísticas: $e');
    }
  }

  Future<void> _submitStats() async {
    if (userId == null || gameId == null) {
      _showSnackBar('Usuario o juego no identificado.');
      print('❌ userId o gameId es null: userId=$userId, gameId=$gameId');
      return;
    }
    final stats =
        statTypes.map((stat) {
          final statTypeId = stat['id']; // Aquí se usa 'id' correctamente
          return {
            'stat_type_id': int.tryParse(
              statTypeId.toString(),
            ), // asegurar que sea int
            'user_id': userId,
            'value':
                statValues[statTypeId.toString()] ??
                0, // usa el mismo string para buscar el valor
          };
        }).toList();

    final url = Uri.parse('http://localhost:3000/api/game/$gameId');
    final body = jsonEncode({
      'game_name': gameNameController.text.trim(),
      'stats': stats,
    });

    print('📤 Enviando PUT a $url');
    print('📦 Body del request: $body');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('📥 Código de respuesta: ${response.statusCode}');
      print('📥 Respuesta del servidor: ${response.body}');

      if (response.statusCode == 200) {
        _showSnackBar('Estadísticas actualizadas exitosamente.');
        GoRouter.of(context).go('/home');
      } else {
        _showSnackBar('Error al actualizar estadísticas.');
      }
    } catch (e) {
      print('❌ Error al hacer PUT: $e');
      _showSnackBar('No se pudo enviar la información al servidor.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildStatInput(Map<String, dynamic> statType) {
    final String statId = statType['id'];
    final String statName = statType['name'];
    final int currentValue = statValues[statId] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$statName: $currentValue',
            style: const TextStyle(fontSize: 18),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: Colors.black),
                onPressed:
                    currentValue > 0
                        ? () => setState(
                          () => statValues[statId] = currentValue - 1,
                        )
                        : null,
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.black),
                onPressed:
                    () => setState(() => statValues[statId] = currentValue + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Estadísticas')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: gameNameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Juego',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ...statTypes.map(
              (statType) => Column(
                children: [
                  _buildStatInput(statType),
                  const Divider(thickness: 1, color: Colors.grey),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitStats,
              child: const Text('Guardar Estadísticas'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Regresar'),
            ),
          ],
        ),
      ),
    );
  }
}
