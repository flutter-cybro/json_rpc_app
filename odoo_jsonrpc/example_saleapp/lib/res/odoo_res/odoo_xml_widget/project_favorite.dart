import 'package:flutter/material.dart';

class ProjectFavoriteWidget extends StatelessWidget {
  final bool isFavorite;
  final bool readonly;
  final ValueChanged<bool>? onChanged;

  const ProjectFavoriteWidget({
    Key? key,
    required this.isFavorite,
    this.readonly = true,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: readonly || onChanged == null
          ? null
          : () => onChanged!(!isFavorite),
      child: Tooltip(
        message: isFavorite ? 'Favorited' : 'Not Favorited',
        child: Icon(
          isFavorite ? Icons.star : Icons.star_border,
          color: isFavorite
              ? Colors.yellow[700] // Bright yellow for favorite
              : Colors.grey, // Explicit grey for non-favorite empty star
          size: 24.0,
        ),
      ),
    );
  }
}