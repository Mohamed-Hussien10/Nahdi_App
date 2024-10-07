import 'package:flutter/material.dart';

Widget buildOtpField(context, TextEditingController controller,
    {bool autoFocus = false}) {
  return SizedBox(
    width: 50,
    child: TextField(
      controller: controller,
      autofocus: autoFocus,
      maxLength: 1,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      decoration: const InputDecoration(
        counterText: '',
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal, width: 2),
        ),
      ),
      onChanged: (value) {
        // Automatically move to the next TextField once input is entered
        if (value.length == 1) {
          FocusScope.of(context).nextFocus();
        }
      },
    ),
  );
}
