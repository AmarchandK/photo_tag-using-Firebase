import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tag_image/controller/home_controller.dart';

class ImageView extends StatelessWidget {
  const ImageView({super.key, required this.imgeString});
  final String imgeString;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomeController>();
    final markers = controller.tags;
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            child: GestureDetector(
                onTapUp: (tap) {
                  log(tap.localPosition.toString());
                  controller.ontap(tap.localPosition, context);
                },
                child: Image.network(imgeString)),
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
}
