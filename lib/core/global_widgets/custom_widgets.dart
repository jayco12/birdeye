import 'package:flutter/material.dart';
import '../../core/constants/app_text_styles.dart';

class CustomText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? align;
  final int? maxLines;

  const CustomText(
    this.text, {
    super.key,
    this.style,
    this.align,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align ?? TextAlign.start,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
      style: style ?? AppTextStyles.body,
    );
  }
}
