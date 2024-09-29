import 'package:flutter/material.dart';

class ImageDisplay extends StatelessWidget {
  final String? imageUrl;

  const ImageDisplay({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return imageUrl != null
        ? Image.network(
            imageUrl!,
            width: 300,
            height: 300,
            fit: BoxFit.cover,
          )
        : const SizedBox.shrink();
  }
}