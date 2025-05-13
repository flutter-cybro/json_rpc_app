import 'package:flutter/cupertino.dart';
import 'package:flutter_html/flutter_html.dart';

class HtmlFieldWidget extends StatelessWidget {
  final String name;
  final String value;

  const HtmlFieldWidget({
    Key? key,
    required this.name,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Html(
          data: value,
          style: {
            "body": Style(
              fontSize: FontSize(10),
            ),
          },
        ),
      ],
    );
  }
}