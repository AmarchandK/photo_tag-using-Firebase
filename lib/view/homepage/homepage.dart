// ignore_for_file: library_private_types_in_public_api, avoid_print, depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tag_image/controller/home_controller.dart';
import 'package:tag_image/view/viewpage/image_view.dart';

class ImageUploads extends StatelessWidget {
  const ImageUploads({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _usersStream =
        FirebaseFirestore.instance.collection('Photos').snapshots();
    final HomeController controller = Provider.of<HomeController>(context);
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder(
        stream: _usersStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }
          return GridView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final data =
                  snapshot.data!.docs[index].data()! as Map<String, dynamic>;
              final String image = data['imageUrl'];
              final ImageData imageData = ImageData.fromJson(data);
              return GestureDetector(
                onTap: () {
                  final tags = context.read<HomeController>().tags;
                  tags.clear();
                  tags.addAll(imageData.tags);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageView(imageData: imageData, id :snapshot.data!.docs[index].id),
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  elevation: 15,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        image: NetworkImage(
                          image,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.imgFromGallery(context);
        },
        child: const Icon(Icons.add_photo_alternate_rounded),
      ),
    );
  }
}
