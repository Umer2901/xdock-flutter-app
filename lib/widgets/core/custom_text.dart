import 'package:flutter/material.dart';

class CustomTextDisplay extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color textColor;
  final int? maxLine;

  const CustomTextDisplay({
    Key? key,
    required this.text,
    this.maxLine,
    this.fontSize = 14.0,
    this.fontWeight = FontWeight.w700,
    this.textColor = const Color(0xFF000000), // Default color is black
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      maxLines: maxLine ?? 1,
      text, // AppText.space + your custom text
      style: TextStyle(
        fontWeight: fontWeight,
        fontSize: fontSize,
        color: textColor.withOpacity(0.4),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
