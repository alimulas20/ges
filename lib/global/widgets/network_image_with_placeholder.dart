import 'package:flutter/material.dart';

class NetworkImageWithPlaceholder extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final String placeholderType; // 'plant' or 'profile'

  const NetworkImageWithPlaceholder({super.key, required this.imageUrl, required this.width, required this.height, this.fit = BoxFit.cover, this.placeholderType = 'plant'});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey[200]),
      child: _buildImageContent(),
    );
  }

  Widget _buildImageContent() {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl!,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(child: CircularProgressIndicator(value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null));
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(child: Icon(placeholderType == 'plant' ? Icons.solar_power : Icons.person, size: 30, color: Colors.grey));
  }
}
