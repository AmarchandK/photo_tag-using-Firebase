import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tag_image/controller/home_controller.dart';
import '../../model/model.dart';

class ImageView extends StatelessWidget {
  const ImageView({super.key, required this.imageData, required this.id});
  final String id;
  final ImageData imageData;
  @override
  Widget build(BuildContext context) {
    final HomeController controller = context.watch<HomeController>();
    final List<TagData> markers = controller.tags;
    return Scaffold(
      bottomNavigationBar: ElevatedButton(
        onPressed: () async {
          await controller.updatePhoto(id, imageData.imageUrl);
        },
        child: controller.isloading
            ? const CupertinoActivityIndicator()
            : const Text('Update'),
      ),
      appBar: AppBar(),
      body: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: GestureDetector(
              onTapUp: (tap) {
                _buildShowDialog(context, controller, tap);
              },
              child: Image.network(
                imageData.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          ...markers.map(
            (tag) => Positioned(
              left: tag.offset.dx,
              top: tag.offset.dy,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.grey,
                ),
                child: Text(
                  tag.data,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> _buildShowDialog(
      BuildContext context, HomeController controller, TapUpDetails tap) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Enter a name',
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              controller.textController.clear();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          MaterialButton(
            onPressed: () {
              controller.onTag(tap.localPosition);
              controller.textController.clear();
              Navigator.of(context).pop();
            },
            child: const Text('Add Tag'),
          ),
        ],
        content: TextField(controller: controller.textController),
      ),
    );
  }
}
