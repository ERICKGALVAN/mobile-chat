import 'package:flutter/material.dart';

class MainInput extends StatelessWidget {
  const MainInput({
    Key? key,
    this.hintText = '',
    this.controller,
    this.icon,
    this.filledColor = Colors.white,
    this.onTapIcon,
    this.obscureText = false,
    this.textInputAction,
    this.onChanged,
    this.validator,
    this.keyboardType,
  }) : super(key: key);
  final String hintText;
  final TextEditingController? controller;
  final IconData? icon;
  final VoidCallback? onTapIcon;
  final Color filledColor;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      textInputAction: textInputAction,
      onChanged: onChanged,
      obscureText: obscureText,
      decoration: InputDecoration(
        filled: true,
        fillColor: filledColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        hintText: hintText,
        suffixIcon: InkWell(
          onTap: onTapIcon,
          child: Icon(icon),
        ),
      ),
    );
  }
}
