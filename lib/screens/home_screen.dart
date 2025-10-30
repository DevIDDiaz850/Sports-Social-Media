import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? userId;
  List<dynamic> gameStats = [];
  List<dynamic> recentPosts = [];

  final String baseUrl = 'http://localhost:3000';

  @override
  void initState() {
    super.initState();
    _fetchUserIdAndStats();
    _fetchRecentPosts();
  }

  Future<void> _fetchUserIdAndStats() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? retrievedUserId = prefs.getInt('userId');

    if (retrievedUserId != null) {
      setState(() {
        userId = retrievedUserId;
      });
      _fetchGameStats(userId.toString());
    } else {
      print('No userId found');
    }
  }

  Future<void> _fetchGameStats(String userId) async {
    final response = await fetchStatsFromAPI(userId);
    if (response != null) {
      Map<int, Map<String, dynamic>> groupedStats = {};

      for (var stat in response) {
        int gameId = stat['game_id'];
        String gameName = stat['game_name'];
        String statType = stat['stat_type'];
        int statValue = stat['stat_value'];

        if (!groupedStats.containsKey(gameId)) {
          groupedStats[gameId] = {
            'game_name': gameName,
            'stats': <String, int>{},
          };
        }

        groupedStats[gameId]!['stats'][statType] = statValue;
      }

      setState(() {
        gameStats =
            groupedStats.entries.map((e) {
              return {
                'game_id': e.key,
                'game_name': e.value['game_name'],
                'stats': e.value['stats'],
              };
            }).toList();
      });
    }
  }

  Future<List<dynamic>?> fetchStatsFromAPI(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/getstatsuser/$userId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener estadísticas');
      }
    } catch (e) {
      print('Error al hacer la solicitud: $e');
      return null;
    }
  }

  Future<void> _fetchRecentPosts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/image/get'));

      if (response.statusCode == 200) {
        final List<dynamic> posts = json.decode(response.body);
        setState(() {
          recentPosts = posts;
        });
      } else {
        throw Exception('Error al obtener los posts recientes');
      }
    } catch (e) {
      print('Error al hacer la solicitud: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bienvenido Santi',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3A4256),
                  ),
                ),
                const SizedBox(height: 20),
                _buildProfileCard(context),
                const SizedBox(height: 20),
                _buildGameSummarySection(context),
                const SizedBox(height: 20),
                _buildRecentPostsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentPostsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Posts Recientes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3A4256),
          ),
        ),
        const SizedBox(height: 10),
        if (recentPosts.isNotEmpty)
          Column(
            children:
                recentPosts.map((post) {
                  final String username = post['username'] ?? 'Desconocido';
                  final String caption = post['content'] ?? '';
                  final String uploadTime = post['created_at'] ?? '';
                  final String imageUrl =
                      '$baseUrl/${post['image_url'].replaceFirst('/images/', '')}';

                  return _buildPostCard(
                    username: username,
                    caption: caption,
                    uploadTime: uploadTime,
                    imageUrl: imageUrl,
                  );
                }).toList(),
          )
        else
          const Text('No hay posts recientes'),
      ],
    );
  }

  Widget _buildPostCard({
    required String username,
    required String caption,
    required String uploadTime,
    required String imageUrl,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(caption, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  'Subido: $uploadTime',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
                border: Border.all(color: Colors.grey.shade400, width: 2),
              ),
              child: const Center(
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Santiago L.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    's_l@gmail.com',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildTag('Principiante'),
                      const SizedBox(width: 8),
                      _buildTag('Futbolista', hasIcon: true),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: () {
                  context.go('/editprofile');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3D5AF1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text('Editar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, {bool hasIcon = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
          if (hasIcon) ...[
            const SizedBox(width: 4),
            const Icon(Icons.sports_soccer, size: 14, color: Colors.black87),
          ],
        ],
      ),
    );
  }

  Widget _buildGameSummarySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Resumen de Juegos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3A4256),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                context.go('/Addstats');
              },
              color: const Color(0xFF3A4256),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (gameStats.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  gameStats.map((stat) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: _buildGameCard(
                        gameName: stat['game_name'] ?? 'Resumen del juego',
                        goals: stat['stats']['Goles'] ?? 0,
                        assists: stat['stats']['Asistencias'] ?? 0,
                        missedShots: stat['stats']['Tiros bloqueados'] ?? 0,
                        onTap: () {
                          context.go('/gameDetails/${stat['game_id']}');
                        },
                      ),
                    );
                  }).toList(),
            ),
          )
        else
          const Text('No hay juegos recientes'),
      ],
    );
  }

  Widget _buildGameCard({
    required String gameName,
    required int goals,
    required int assists,
    required int missedShots,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                gameName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(221, 4, 221, 22),
                ),
              ),
              const SizedBox(height: 8),
              Text("Goles: $goals"),
              Text("Asistencias: $assists"),
              Text("Tiros bloqueados: $missedShots"),
            ],
          ),
        ),
      ),
    );
  }
}
