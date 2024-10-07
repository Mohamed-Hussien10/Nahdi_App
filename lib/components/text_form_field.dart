// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class TextFField extends StatelessWidget {
  TextFField(this.icon, this.labelText, this.hintText, this.keyboardType,
      this.isObscureText, this.validator, this.onSaved,
      {super.key});

  late Icon icon;
  late String labelText;
  late String hintText;
  late TextInputType keyboardType;
  late bool isObscureText;
  late String? Function(String?)? validator;
  late String? Function(String?)? onSaved;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: isObscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: icon,
        labelText: labelText,
        hintText: hintText,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(
            color: Colors.teal,
            width: 2,
          ),
        ),
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }
}
