import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/login.dart';
import 'screens/SingupScreen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/EditProfile.dart';
import 'screens/AddStats.dart';
import 'screens/AddImages.dart';
import 'screens/ImageId.dart';
import 'screens/GameId.dart';
import 'screens/EditStats.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final _router = GoRouter(
    initialLocation: '/signup',
    routes: [
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/editprofile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/addimage',
        builder: (context, state) => UploadImageScreen(),
      ),
      GoRoute(path: '/Addstats', builder: (context, state) => const AddStats()),
      GoRoute(
        path: '/PostId/:id',
        builder: (context, state) {
          final idParam = state.pathParameters['id'];
          final postId = int.tryParse(
            idParam ?? '',
          ); // Asegúrate de convertirlo en entero
          if (postId == null) {
            return const Scaffold(
              body: Center(child: Text('ID de imagen inválido')),
            );
          }
          return PostImageId(postId: postId); // Pasa el postId como argumento
        },
      ),
      GoRoute(
        path: '/gameDetails/:statId',
        builder: (context, state) {
          final statId = state.pathParameters['statId']!;
          return GameDetailsScreen(statId: statId);
        },
      ),
      GoRoute(
        path: '/editStats/:gameId',
        builder: (context, state) {
          final gameIdParam = state.pathParameters['gameId'];
          final gameId = gameIdParam != null ? int.tryParse(gameIdParam) : null;
          return EditStatsScreen(gameId: gameId);
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainNavigationScreen(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mis estadisticas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3D5AF1),
          primary: const Color(0xFF3D5AF1),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F6F8),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF3D5AF1),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Otros'),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'MyCard',
            ),
          ],
        ),
      ),
    );
  }
}
