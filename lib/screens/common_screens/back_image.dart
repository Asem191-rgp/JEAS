import 'package:flutter/material.dart';

class BackImage extends StatefulWidget {
  const BackImage({super.key});

  @override
  State<BackImage> createState() => _BackImageState();
}

class _BackImageState extends State<BackImage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            "assets/images/backImage.jpg",
          ),
          fit: BoxFit.cover,
        ),
      ),
      height: 270,
    );
  }
}
