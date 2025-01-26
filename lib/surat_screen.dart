import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Surat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SuratScreen(),
    );
  }
}

class SuratScreen extends StatefulWidget {
  @override
  _SuratScreenState createState() => _SuratScreenState();
}

class _SuratScreenState extends State<SuratScreen> {
  TextEditingController _suratController = TextEditingController();

  // Fungsi untuk memilih file
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    
    if (result != null) {
      // Ambil file yang dipilih
      PlatformFile file = result.files.first;
      // Kirim file ke server atau ke staf
      _sendFile(file);
    } else {
      // User canceled the picker
    }
  }

  // Fungsi untuk mengirim file
  Future<void> _sendFile(PlatformFile file) async {
    var uri = Uri.parse('https://yourserver.com/upload'); // Ubah dengan URL server Anda
    var request = http.MultipartRequest('POST', uri)
      ..fields['to'] = 'all_staff@example.com' // Kirim ke staf
      ..files.add(await http.MultipartFile.fromPath('file', file.path!));

    var response = await request.send();

    if (response.statusCode == 200) {
      print('File successfully uploaded');
    } else {
      print('File upload failed');
    }
  }

  // Fungsi untuk mengirim surat
  Future<void> _sendSurat() async {
    var uri = Uri.parse('https://yourserver.com/send_surat'); // Ubah dengan URL server Anda
    var response = await http.post(uri, body: {
      'surat': _suratController.text,
      'to': 'all_staff@example.com', // Kirim ke staf
    });

    if (response.statusCode == 200) {
      print('Surat successfully sent');
    } else {
      print('Surat sending failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Surat App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form untuk menulis surat
            TextField(
              controller: _suratController,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: 'Tulis Surat...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _pickFile,
                  child: Text('Upload File'),
                ),
                ElevatedButton(
                  onPressed: _sendSurat,
                  child: Text('Kirim Surat'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
