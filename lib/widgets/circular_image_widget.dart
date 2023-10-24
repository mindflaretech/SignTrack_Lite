import 'package:flutter/material.dart';

class CircularImageWidget extends StatelessWidget {
  final String imagePath;
  final double imageSize;
  final double containerSize;
  final Color containerColor;
  final Color borderColor;
  final double borderWidth;

  const CircularImageWidget({
    super.key,
    required this.imagePath,
    this.imageSize = 40,
    this.containerSize = 40, // Adjust the default size as needed
    this.containerColor = Colors.transparent,
    this.borderColor = Colors.blueGrey,
    this.borderWidth = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        color: containerColor,
        shape: BoxShape.rectangle,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Center(
          child: Image.asset(
            imagePath,
            width: imageSize,
            height: imageSize,
          ),
        ),
      ),
    );
  }
}
