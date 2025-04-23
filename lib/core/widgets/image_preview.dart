import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImagePreview extends StatelessWidget {
  final String? imagePath;
  final String? imageUrl;
  final VoidCallback? onRemove;
  final double dimesion;
  final double size;

  const ImagePreview({
    super.key,
    this.imagePath,
    this.imageUrl,
    this.onRemove,
    this.dimesion = 100,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child:
              imagePath != null
                  ? Image.file(
                    File(imagePath!),
                    height: dimesion,
                    width: dimesion,
                    fit: BoxFit.cover,
                  )
                  : CachedNetworkImage(
                    imageUrl: imageUrl ?? '',
                    height: dimesion,
                    width: dimesion,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => Container(
                          height: dimesion,
                          width: dimesion,
                          color: Colors.grey[200],
                          child: Icon(Icons.image, size: size),
                        ),
                    errorWidget:
                        (context, url, error) => Container(
                          height: dimesion,
                          width: dimesion,
                          color: Colors.grey[200],
                          child: Icon(Icons.error_outline, size: size),
                        ),
                  ),
        ),
        if (onRemove != null)
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: onRemove,
            ),
          ),
      ],
    );
  }
}
