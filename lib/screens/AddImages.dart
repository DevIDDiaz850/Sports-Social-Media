import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:io' if (dart.library.html) 'dart:html' as html;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'dart:convert'; // Para jsonDecode

class UploadImageScreen extends StatefulWidget {
  const UploadImageScreen({Key? key}) : super(key: key);

  @override
  _UploadImageScreenState createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  Uint8List? _imageBytes;
  XFile? _pickedFile;
  final TextEditingController _captionController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _pickedFile = pickedFile;
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_pickedFile == null) return;

    final uri = Uri.parse('http://localhost:3000/api/srcimages');
    final request = http.MultipartRequest('POST', uri);

    request.fields['user_id'] = '1';
    request.fields['content'] = _captionController.text;

    request.files.add(
      http.MultipartFile.fromBytes(
        'img',
        _imageBytes!,
        filename: _pickedFile!.name,
        contentType: http_parser.MediaType('image', 'jpeg'),
      ),
    );

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint('📦 Respuesta del servidor: $responseBody');

      if (response.statusCode == 200) {
        try {
          final imageId = _extractImageId(responseBody);
          debugPrint('✅ ID de la imagen recibida: $imageId');
        } catch (_) {
          debugPrint('⚠️ No se pudo extraer el ID de la imagen.');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imagen subida correctamente.')),
        );
        _captionController.clear();
        setState(() {
          _imageBytes = null;
          _pickedFile = null;
        });
      } else {
        debugPrint('❌ Error al subir imagen: $responseBody');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al subir la imagen.')),
        );
      }
    } catch (e) {
      debugPrint('🔥 Excepción: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fallo en la conexión al servidor.')),
      );
    }
  }

  dynamic _extractImageId(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      return decoded['id'] ?? decoded['_id']; // depende del backend
    } catch (_) {
      throw Exception('No es una respuesta JSON válida');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cargar Imagen')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(
                labelText: 'Escribe un caption',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Seleccionar Imagen'),
            ),
            const SizedBox(height: 20),
            _imageBytes != null
                ? Image.memory(
                  _imageBytes!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                )
                : const Text('No se ha seleccionado ninguna imagen'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadImage,
              child: const Text('Subir Imagen'),
            ),
          ],
        ),
      ),
    );
  }
}
