import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  static const String cloudName = 'djoztofo8';
  static const String uploadPreset = 'zenjshop_unsigned';

  static Future<String?> uploadImage(XFile file) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = uploadPreset;

      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: file.name),
        );
      } else {
        request.files.add(await http.MultipartFile.fromPath('file', file.path));
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);

      if (response.statusCode == 200) {
        return jsonData['secure_url'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<XFile?> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    return image;
  }
}
