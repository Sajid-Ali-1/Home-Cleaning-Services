import 'package:flutter/material.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class DividerWithText extends StatelessWidget {
  const DividerWithText({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            height: 1.0,
            decoration: BoxDecoration(color: AppTheme.of(context).dividerColor),
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(17.0, 0.0, 17.0, 0.0),
          child: Text(text, style: AppTheme.of(context).labelSmall),
        ),
        Expanded(
          child: Container(
            height: 1.0,
            decoration: BoxDecoration(color: AppTheme.of(context).dividerColor),
          ),
        ),
      ],
    );
  }
}
