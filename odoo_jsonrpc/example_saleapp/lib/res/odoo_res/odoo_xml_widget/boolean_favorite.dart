import 'package:flutter/material.dart';

class BooleanFavoriteWidget extends StatelessWidget {
  final bool isFavorite;

  const BooleanFavoriteWidget({super.key, required this.isFavorite});

  @override
  Widget build(BuildContext context) {
    return Icon(
      isFavorite ? Icons.star : Icons.star_border,
      color: isFavorite ? Colors.yellow : Colors.grey,
      size: 24,
    );
  }
}