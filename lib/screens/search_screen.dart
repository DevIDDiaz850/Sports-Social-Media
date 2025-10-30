import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchProfilesScreenState();
}

class _SearchProfilesScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Lista de usuarios de ejemplo
  final List<Map<String, dynamic>> _users = [
    {
      'name': 'Santiago L.',
      'email': 's_l@gmail.com',
      'image':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e7/Santiago_Gim%C3%A9nez_-_2023.jpg/250px-Santiago_Gim%C3%A9nez_-_2023.jpg',
      'tags': ['Principiante', 'Futbolista'],
      'stats': {'partidos': 12, 'ganados': 8, 'perdidos': 4},
    },
    {
      'name': 'María G.',
      'email': 'maria@gmail.com',
      'image': 'https://randomuser.me/api/portraits/women/44.jpg',
      'tags': ['Avanzado', 'Tenista'],
      'stats': {'partidos': 24, 'ganados': 18, 'perdidos': 6},
    },
    {
      'name': 'Carlos R.',
      'email': 'carlos@gmail.com',
      'image': 'https://randomuser.me/api/portraits/men/62.jpg',
      'tags': ['Intermedio', 'Basquetbolista'],
      'stats': {'partidos': 18, 'ganados': 10, 'perdidos': 8},
    },
    {
      'name': 'Laura P.',
      'email': 'laura@gmail.com',
      'image': 'https://randomuser.me/api/portraits/women/33.jpg',
      'tags': ['Principiante', 'Voleibolista'],
      'stats': {'partidos': 8, 'ganados': 3, 'perdidos': 5},
    },
    {
      'name': 'Javier M.',
      'email': 'javier@gmail.com',
      'image': 'https://randomuser.me/api/portraits/men/11.jpg',
      'tags': ['Avanzado', 'Futbolista'],
      'stats': {'partidos': 30, 'ganados': 22, 'perdidos': 8},
    },
  ];

  List<Map<String, dynamic>> get _filteredUsers {
    if (_searchQuery.isEmpty) {
      return _users;
    }
    return _users
        .where(
          (user) =>
              user['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
              user['email'].toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              user['tags'].any(
                (tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()),
              ),
        )
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6F8),
        elevation: 0,
        title: const Text(
          'Buscar Perfiles',
          style: TextStyle(
            color: Color(0xFF3A4256),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra de búsqueda
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Buscar por nombre, email o deporte...',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Título de resultados
              Text(
                'Perfiles (${_filteredUsers.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A4256),
                ),
              ),

              const SizedBox(height: 12),

              // Lista de perfiles
              Expanded(
                child:
                    _filteredUsers.isEmpty
                        ? const Center(
                          child: Text(
                            'No se encontraron resultados',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                        : ListView.builder(
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            return _buildUserCard(user);
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Información básica del usuario
            Row(
              children: [
                // Foto de perfil
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    image: DecorationImage(
                      image: NetworkImage(user['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Información del perfil
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user['email'],
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ...user['tags']
                              .map<Widget>(
                                (tag) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _buildTag(tag, tag.contains('Futbol')),
                                ),
                              )
                              .toList(),
                        ],
                      ),
                    ],
                  ),
                ),

                // Botón de seguir
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3D5AF1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text('Seguir'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Estadísticas del usuario
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  'Partidos',
                  user['stats']['partidos'].toString(),
                ),
                _buildStatColumn(
                  'Ganados',
                  user['stats']['ganados'].toString(),
                ),
                _buildStatColumn(
                  'Perdidos',
                  user['stats']['perdidos'].toString(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Botón para ver perfil completo
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Navegar al perfil detallado
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ver perfil de ${user['name']}')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF3D5AF1),
                  side: const BorderSide(color: Color(0xFF3D5AF1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Ver perfil completo'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, bool hasIcon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
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

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }
}
