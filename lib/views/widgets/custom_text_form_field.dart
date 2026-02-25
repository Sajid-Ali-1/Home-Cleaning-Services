import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

// ignore: must_be_immutable
class CustomTextFormField extends StatefulWidget {
  CustomTextFormField({
    super.key,
    required this.controller,
    required this.validator,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.keyboardType,
    this.isPassword = false,
    this.fillColor,
    this.minLines,
    this.maxLines,
    this.textCapitalization,
    this.onChanged,
  });

  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final bool isPassword;
  bool obscureText = true;
  final Color? fillColor;

  final int? minLines;
  final int? maxLines;
  final TextCapitalization? textCapitalization;
  final ValueChanged<String>? onChanged;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  @override
  Widget build(BuildContext context) {
    if (!widget.isPassword) {
      widget.obscureText = false;
    }
    var inputBorder = OutlineInputBorder(
      borderSide: BorderSide(color: Color(0x00000000)),
      borderRadius: BorderRadius.circular(16.0.r),
    );
    var errorBorder = OutlineInputBorder(
      borderSide: BorderSide(color: AppTheme.of(context).error),
      borderRadius: BorderRadius.circular(16.0.r),
    );
    return TextFormField(
      textCapitalization: widget.textCapitalization ?? TextCapitalization.none,
      maxLines: widget.isPassword
          ? 1
          : (widget.maxLines ?? (widget.minLines != null ? null : 1)),
      minLines: widget.isPassword ? null : widget.minLines ?? 1,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: widget.obscureText
                    ? Icon(Icons.visibility_off, color: Color(0xFF565D6D))
                    : Icon(
                        Icons.visibility,
                        color: AppTheme.of(context).primaryText,
                      ),
                onPressed: () => setState(() {
                  widget.obscureText = !widget.obscureText;
                }),
              )
            : null,
        hintText: widget.labelText,
        hintStyle: AppTheme.of(context).labelMedium,

        // hintText: widget.hintText,
        // hintStyle: Theme.of(context).textTheme.labelLarge,
        border: inputBorder,
        focusedBorder: inputBorder,
        enabledBorder: inputBorder,
        errorBorder: errorBorder,
        focusedErrorBorder: errorBorder,
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: Color(0xFF565D6D))
            : null,
        filled: true,
        fillColor: widget.fillColor ?? AppTheme.of(context).textFieldColor,
      ),
      style: AppTheme.of(context).bodySmall,
      cursorColor: AppTheme.of(context).accent1,
      validator: widget.validator,
      controller: widget.controller,
    );
  }
}
