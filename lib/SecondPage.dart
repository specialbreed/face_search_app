import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class FaceSearchApp extends StatefulWidget {
  @override
  _FaceSearchAppState createState() => _FaceSearchAppState();
}

class _FaceSearchAppState extends State<FaceSearchApp> {
  List<String> _imageUrls = [];
  int _currentImageIndex = 0;
  bool _uploadComplete = false;
  final ImagePicker _picker = ImagePicker();
  Timer? _timer;

  Future<void> _fetchRandomImages() async {
    try {
      final response = await http.get(
          Uri.parse('https://picsum.photos/v2/list?page=1&limit=10'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<String> urls = [];

        for (int i = 0; i < data.length; i++) {
          urls.add('https://picsum.photos/id/${data[i]['id']}/500/500.jpg');
        }

        setState(() {
          _imageUrls = urls;
        });
      } else {
        print('Failed to fetch random images: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching random images: $error');
    }
  }

  Future<void> _uploadImage(File imageFile) async {
  }

  Future<void> _getImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final String imagePath = pickedFile.path;

      setState(() {
        _uploadComplete = true;
      });

      _uploadImage(File(imagePath));
      _fetchRandomImages();
    }
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 2), (Timer timer) {
      if (_imageUrls.isNotEmpty) {
        setState(() {
          _currentImageIndex =
              (_currentImageIndex + 1) % _imageUrls.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'IMAGE SEARCH',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 60),
            if (!_uploadComplete && _imageUrls.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: CircularProgressIndicator(), // Show a loader while uploading
                ),
              ),
            if (_uploadComplete && _imageUrls.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Image.network(
                    _imageUrls[_currentImageIndex],
                    key: UniqueKey(),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getImageFromGallery,
        tooltip: 'Upload Image',
        child: Icon(Icons.camera_alt),
      ),
      persistentFooterButtons: [
        Center(
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 20.0),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'DONE',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
  void main() {
  runApp(MaterialApp(
    title: 'FaceSearchApp',
    home: FaceSearchApp(),
  ));
}
