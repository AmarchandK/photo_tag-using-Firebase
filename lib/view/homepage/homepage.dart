// ignore_for_file: library_private_types_in_public_api, avoid_print, depend_on_referenced_packages
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tag_image/controller/home_controller.dart';
import 'package:tag_image/view/viewpage/image_view.dart';

class ImageUploads extends StatelessWidget {
  const ImageUploads({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Provider.of<HomeController>(context);
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder(
        stream: controller.loadImages(),
        builder: (context, AsyncSnapshot<List<String>> snapshot) {
          return snapshot.data == null
              ? const Center(
                  child: CupertinoActivityIndicator(),
                )
              : snapshot.data!.isEmpty
                  ? const Center(
                      child: Text('No Data'),
                    )
                  : GridView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final String image = snapshot.data![index];
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ImageView(imgeString: image),
                            ),
                          ),
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
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
