import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class AddStats extends StatefulWidget {
  const AddStats({Key? key}) : super(key: key);

  @override
  _AddStatsScreenState createState() => _AddStatsScreenState();
}

class _AddStatsScreenState extends State<AddStats> {
  int? userId;
  int selectedSportId = 1;
  List<Map<String, dynamic>> statTypes = [];
  Map<int, int> statValues = {};
  final TextEditingController gameNameController = TextEditingController();
  bool isLoading = true;

  Future<void> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
    if (userId == null) {
      print('⚠️ [LOG] userId es null después de cargar SharedPreferences.');
    } else {
      print('✅ [LOG] userId cargado correctamente: $userId');
    }
  }

  Future<void> _fetchStatTypes() async {
    try {
      final url = Uri.parse(
        'http://localhost:3000/api/stat_types/$selectedSportId',
      );
      print('🔵 [LOG] Fetching statTypes for sportId: $selectedSportId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isEmpty) {
          print('⚠️ [LOG] La lista de tipos de estadísticas vino vacía.');
        } else {
          print('✅ [LOG] statTypes recibidos: $data');
        }
        statTypes =
            data
                .map((item) => {'id': item['id'], 'name': item['name']})
                .toList();

        statValues = {for (var item in statTypes) item['id'] as int: 0};
      } else {
        print(
          '❌ [LOG] Error al obtener tipos de estadísticas. Status: ${response.statusCode}',
        );
        throw Exception('Error al obtener los tipos de estadísticas');
      }
    } catch (error) {
      print('❗ [LOG] Excepción en _fetchStatTypes: $error');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $error')));
    }
  }

  Future<void> _init() async {
    await _getUserId();
    await _fetchStatTypes();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _submitStats() async {
    if (userId == null) {
      print('⚠️ [LOG] Intento de enviar estadísticas sin userId.');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Usuario no encontrado.')));
      return;
    }

    if (gameNameController.text.isEmpty) {
      print('⚠️ [LOG] El nombre del juego está vacío.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un nombre para el juego'),
        ),
      );
      return;
    }

    try {
      // Crear juego
      final createGameUrl = Uri.parse('http://localhost:3000/api/create_game');
      print('🔵 [LOG] Creando juego con nombre: ${gameNameController.text}');
      final createGameResponse = await http.post(
        createGameUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sport_id': selectedSportId,
          'game_name': gameNameController.text,
          'game_date': DateTime.now().toIso8601String(),
        }),
      );

      if (createGameResponse.statusCode != 201) {
        print(
          '❌ [LOG] Error al crear el juego. Status: ${createGameResponse.statusCode}',
        );
        throw Exception('Error al crear el juego');
      }

      final gameData = jsonDecode(createGameResponse.body);
      final dynamic idValue = gameData['game_id']; // Cambio de 'id' a 'game_id'
      if (idValue == null) {
        print(
          '❗ [LOG] No se encontró el campo "game_id" en la respuesta: $gameData',
        );
        throw Exception('No se encontró el ID del juego.');
      }

      final int gameId;
      if (idValue is int) {
        gameId = idValue;
      } else if (idValue is String) {
        gameId = int.tryParse(idValue) ?? -1;
        if (gameId == -1) {
          print(
            '❗ [LOG] El game_id recibido no se pudo parsear a int: $idValue',
          );
          throw Exception('ID del juego inválido.');
        }
      } else {
        print(
          '❗ [LOG] game_id tiene un tipo inesperado: ${idValue.runtimeType}',
        );
        throw Exception('Tipo de ID inesperado.');
      }

      print('✅ [LOG] Juego creado con id: $gameId');

      // Enviar estadísticas
      List<Future<http.Response>> statRequests = [];
      for (var entry in statValues.entries) {
        final statTypeId = entry.key;
        final value = entry.value;

        print(
          '📊 [LOG] Enviando stat - statTypeId: $statTypeId, value: $value',
        );

        final createStatUrl = Uri.parse(
          'http://localhost:3000/api/create_stats',
        );
        final statRequest = http.post(
          createStatUrl,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'game_id': gameId,
            'user_id': userId!,
            'stat_type_id': statTypeId,
            'value': value,
            'sport_id': selectedSportId,
          }),
        );
        statRequests.add(statRequest);
      }

      final List<http.Response> responses = await Future.wait(statRequests);

      for (var response in responses) {
        if (response.statusCode != 201) {
          print(
            '❌ [LOG] Error al enviar estadística individual. Status: ${response.statusCode}',
          );
          throw Exception('Error al enviar las estadísticas');
        }
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Estadísticas guardadas')));
      print('🎯 [LOG] Todas las estadísticas fueron guardadas correctamente.');
      GoRouter.of(context).go('/home');
    } catch (error) {
      print('[LOG] Excepción en _submitStats: $error');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $error')));
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Estadísticas')),
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
            DropdownButton<int>(
              value: selectedSportId,
              onChanged: (int? newValue) async {
                if (newValue == null) {
                  print('⚠️ [LOG] newValue del dropdown es null.');
                  return;
                }
                setState(() {
                  selectedSportId = newValue;
                  isLoading = true;
                });
                await _fetchStatTypes();
                setState(() {
                  isLoading = false;
                });
              },
              items: const [
                DropdownMenuItem(value: 1, child: Text('Fútbol')),
                DropdownMenuItem(value: 2, child: Text('Básquetbol')),
                DropdownMenuItem(value: 3, child: Text('Voleibol')),
                DropdownMenuItem(value: 4, child: Text('Fútbol Americano')),
                DropdownMenuItem(value: 5, child: Text('Tenis de Mesa')),
                DropdownMenuItem(value: 6, child: Text('Atletismo')),
              ],
            ),
            const SizedBox(height: 20),
            ...statTypes.map((statType) {
              return Column(
                children: [
                  _buildStatInput(statType),
                  const Divider(thickness: 1, color: Colors.grey),
                ],
              );
            }).toList(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: userId != null ? _submitStats : null,
              child: const Text('Guardar Estadísticas'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Regresar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatInput(Map<String, dynamic> statType) {
    int? statId = statType['id'];
    String? statName = statType['name'];

    if (statId == null || statName == null) {
      print('⚠️ [LOG] StatType inválido: $statType');
    }

    int currentStatValue = statValues[statId ?? -1] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${statName ?? 'Nombre Desconocido'}: $currentStatValue',
            style: const TextStyle(fontSize: 18),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed:
                    currentStatValue > 0
                        ? () => setState(() {
                          statValues[statId ?? -1] = currentStatValue - 1;
                        })
                        : null,
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed:
                    () => setState(() {
                      statValues[statId ?? -1] = currentStatValue + 1;
                    }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
