// ignore_for_file: avoid_print, depend_on_referenced_packages
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeController extends ChangeNotifier {
  CollectionReference photos = FirebaseFirestore.instance.collection('Photos');

  FirebaseStorage storage = FirebaseStorage.instance;
  File? photo;
  final ImagePicker _picker = ImagePicker();
  final List<TagData> tags = [];
  final TextEditingController textController = TextEditingController();
  ontap(Offset offset, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Enter a name',
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              textController.clear();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          MaterialButton(
            onPressed: () async {
              tags.add(
                TagData(data: textController.text.trim(), offset: offset),
              );

              textController.clear();
              Navigator.of(context).pop();
              notifyListeners();
            },
            child: const Text('Add Tag'),
          ),
        ],
        content: TextField(
          controller: textController,
        ),
      ),
    );
  }

  savePhoto(String id, String imageUrl) async {
    final ImageData image = ImageData(imageUrl: imageUrl, tags: tags);
   
    await photos.doc(id).set(image.toJson()).then((value) => print('updated'));
  }

  Future imgFromGallery(context) async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 20);
    if (pickedFile != null) {
      photo = File(pickedFile.path);
      await showDiologue(context);
    } else {
      print('No image selected.');
    }
  }

  Future uploadFile() async {
    if (photo == null) return;
    final String fileName = basename(photo!.path);
    try {
      final Reference ref = storage.ref(fileName);
      await ref.putFile(photo!);
      final imageUrl = await ref.getDownloadURL();
      await photos
          .add({'imageUrl': imageUrl, 'tags': []})
          .then((value) => print("User Added"))
          .catchError((error, stackTrace) => print(error.toString()));
      loadImages();
    } catch (e) {
      print('error occured');
    }
    notifyListeners();
  }

  Stream<List<String>> loadImages() async* {
    List<String> files = [];
    final ListResult result = await storage.ref().list();
    final List<Reference> allFiles = result.items;
    await Future.forEach<Reference>(
      allFiles,
      (file) async {
        final String fileUrl = await file.getDownloadURL();
        files.add(fileUrl);
      },
    );
    yield files;
  }

  Future<void> showDiologue(context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          photo!.path,
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              uploadFile();
              photo = null;
              Navigator.of(context).pop();
            },
            child: const Text('Upload'),
          ),
          MaterialButton(
              onPressed: () {
                photo = null;
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'))
        ],
        content: Image.file(
          photo!,
          fit: BoxFit.fitHeight,
        ),
      ),
    );
  }

  Future<void> delete(String ref) async {
    await storage.ref(ref).delete();
  }
}

class TagData {
  Offset offset;
  String data;

  TagData({required this.data, required this.offset});

  Map<String, dynamic> toJson() {
    return {'dx': offset.dx, 'dy': offset.dy, 'data': data};
  }

  static fromJson(Map<String, dynamic> data) {
    return TagData(data: data['data'], offset: Offset(data['dx'], data['dy']));
  }
}

class ImageData {
  String imageUrl;
  List<TagData> tags;
  ImageData({required this.imageUrl, required this.tags});

  static ImageData fromJson(Map<String, dynamic> data) {
    return ImageData(
        imageUrl: data['imageUrl'],
        tags: List.from(data['tags'].map((e) => TagData.fromJson(e))));
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'tags': List.from(tags.map((e) => e.toJson()))
    };
  }
}
