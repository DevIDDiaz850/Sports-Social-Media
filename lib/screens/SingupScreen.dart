import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _selectedSport = 'Dinos tu deporte';

  final Map<String, int> _sportsMap = {
    'Dinos tu deporte': 0,
    'Futbol': 1,
    'Baloncesto': 2,
    'Voleibol': 3,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 30),
                const Text(
                  'Crear cuenta',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                // Usuario
                TextFormField(
                  controller: _usernameController,
                  decoration: _inputDecoration('Usuario', Icons.person_outline),
                  validator:
                      (value) => value!.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 15),

                // Dropdown deporte
                DropdownButtonFormField<String>(
                  decoration: _inputDecoration('Deporte', Icons.sports),
                  value: _selectedSport,
                  items:
                      _sportsMap.keys.map((String item) {
                        return DropdownMenuItem(value: item, child: Text(item));
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedSport = newValue!;
                    });
                  },
                  validator:
                      (value) =>
                          value == 'Dinos tu deporte'
                              ? 'Selecciona un deporte'
                              : null,
                ),
                const SizedBox(height: 15),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: _inputDecoration(
                    'Correo electrónico',
                    Icons.email_outlined,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator:
                      (value) => value!.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 15),

                // Contraseña
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: _inputDecoration(
                    'Contraseña',
                    Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator:
                      (value) =>
                          value!.length < 6 ? 'Mínimo 6 caracteres' : null,
                ),
                const SizedBox(height: 30),

                // Botón
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3D5AF1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: _submitForm,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'CREAR CUENTA',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Al crear una cuenta, acepta nuestros',
                  style: TextStyle(fontSize: 12),
                ),
                const Text(
                  'Términos y condiciones',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF3D5AF1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () => context.go('/login'),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿Ya tienes una cuenta? ',
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Inicia sesión',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF3D5AF1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String hint,
    IconData icon, {
    Widget? suffix,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 15),
      suffixIcon: suffix,
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final String username = _usernameController.text.trim();
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();
      final int sportId = _sportsMap[_selectedSport]!;

      final uri = Uri.parse(
        'http://localhost:3000/api/auth/createAccount',
      ); // Usa tu IP real en dispositivo físico
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': username,
          'email': email,
          'password': password,
          'sport_id': sportId,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('Usuario registrado: ${data['user']}');
        context.go('/home'); // o cualquier ruta post-registro
      } else {
        print('Error: ${response.body}');
        _showDialog('Error', 'No se pudo registrar el usuario');
      }
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }
}
