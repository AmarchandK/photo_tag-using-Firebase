import 'dart:developer';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/model.dart';

class HomeController extends ChangeNotifier {
  CollectionReference photos = FirebaseFirestore.instance.collection('Photos');
  FirebaseStorage storage = FirebaseStorage.instance;
  File? photo;
  final ImagePicker _picker = ImagePicker();
  final List<TagData> tags = [];
  final TextEditingController textController = TextEditingController();
  bool isloading = false;
  void load() {
    isloading = !isloading;
    notifyListeners();
  }

  void onTag(Offset offset) {
    tags.add(
      TagData(data: textController.text.trim(), offset: offset),
    );
    notifyListeners();
  }

  Future updatePhoto(String id, String imageUrl) async {
    load();
    final ImageData image = ImageData(imageUrl: imageUrl, tags: tags);
    await photos
        .doc(id)
        .set(
          image.toJson(),
        )
        .then(
          (value) => const SnackBar(content: Text('Image Upadated')),
        );
    load();
  }

  Future<void> imgFromGallery(context) async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 20);
    if (pickedFile != null) {
      photo = File(pickedFile.path);
    } else {
      const SnackBar(
        content: Text('No Image Selected'),
      );
    }
  }

  uploadFile(BuildContext context) async {
    load();

    log(isloading.toString());
    if (photo == null) return;
    final String fileName = basename(photo!.path);
    try {
      final Reference ref = storage.ref(fileName);
      await ref.putFile(photo!);
      final imageUrl = await ref.getDownloadURL();
      await photos
          .add(
            {'imageUrl': imageUrl, 'tags': []},
          )
          .then(
            (value) => const SnackBar(content: Text('Added')),
          )
          .catchError(
              (error, stackTrace) => SnackBar(content: Text(error.toString())));
    } catch (e) {
      SnackBar(
        content: Text(
          e.toString(),
        ),
      );
    }
    notifyListeners();

    load();
    log(isloading.toString());
  }

  Future<void> delete(String ref) async {
    await storage.ref(ref).delete();
  }

  // Stream<List<String>> loadImages() async* {
  //   List<String> files = [];
  //   final ListResult result = await storage.ref().list();
  //   final List<Reference> allFiles = result.items;
  //   await Future.forEach<Reference>(
  //     allFiles,
  //     (file) async {
  //       final String fileUrl = await file.getDownloadURL();
  //       files.add(fileUrl);
  //     },
  //   );
  //   yield files;
  // }
}
