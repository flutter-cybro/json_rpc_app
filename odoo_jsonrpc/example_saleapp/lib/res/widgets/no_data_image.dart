import 'package:flutter/material.dart';

class NoDataWidget extends StatelessWidget {
  final String message;
  final String imagePath;

  const NoDataWidget({
    Key? key,
    this.message = "No Data Available",
    this.imagePath = "assets/image/no-data-img.png",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;


    final double imageSize = screenWidth * 0.5;
    final double fontSize = screenWidth * 0.045;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: imageSize,
            height: imageSize,
            fit: BoxFit.contain,
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            message,
            style: TextStyle(
              fontSize: fontSize,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
