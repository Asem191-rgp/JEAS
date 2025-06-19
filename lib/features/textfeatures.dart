import 'package:flutter/material.dart';

class FontFeatures extends StatelessWidget {
  final String name;
  final double size_;
  final Color col;
  const FontFeatures(this.name, this.col, this.size_, {super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          name,
          style: TextStyle(
            color: col,
            fontSize: size_,
          ),
        ),
      ],
    );
  }
}
