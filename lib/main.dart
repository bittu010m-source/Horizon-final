import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const HorizonApp());
}

class HorizonApp extends StatelessWidget {
  const HorizonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Horizon',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final picker = ImagePicker();
  List<File> images = [];

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  Future<Directory> get folder async {
    final dir = await getApplicationDocumentsDirectory();
    final f = Directory("${dir.path}/horizon");
    if (!await f.exists()) {
      await f.create(recursive: true);
    }
    return f;
  }

  Future<void> loadImages() async {
    final f = await folder;
    final files = f.listSync().whereType<File>().toList();

    setState(() {
      images = files;
    });
  }

  Future<void> pickImage(ImageSource source) async {
    final x = await picker.pickImage(source: source);
    if (x == null) return;

    final f = await folder;

    await File(x.path).copy(
      "${f.path}/${DateTime.now().millisecondsSinceEpoch}.jpg",
    );

    loadImages();
  }

  Future<void> deleteImage(File file) async {
    await file.delete();
    loadImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Horizon"),
        centerTitle: true,
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "1",
            onPressed: () => pickImage(ImageSource.camera),
            child: const Icon(Icons.camera_alt),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "2",
            onPressed: () => pickImage(ImageSource.gallery),
            child: const Icon(Icons.photo),
          ),
        ],
      ),
      body: images.isEmpty
          ? const Center(child: Text("No Images"))
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: images.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final file = images[index];

                return GestureDetector(
                  onLongPress: () => deleteImage(file),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      file,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
