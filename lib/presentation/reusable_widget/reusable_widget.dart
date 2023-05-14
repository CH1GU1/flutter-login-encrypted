import 'package:flutter/material.dart';



TextField reusableTextField(String text, IconData icon, bool isPasswordType, TextEditingController controller){
  return TextField(
    controller: controller,
    obscureText: isPasswordType,
    enableSuggestions: !isPasswordType,
    autocorrect: !isPasswordType,
    cursorColor: Colors.black,
    style: TextStyle(color: Colors.white.withOpacity(0.9)),
    decoration: InputDecoration(
      prefixIcon: Icon(
        icon,
        color: Color.fromARGB(255, 41, 81, 114),
      ),
      labelText: text,
      labelStyle: TextStyle(color: Color.fromARGB(255, 105, 103, 103).withOpacity(0.9)),
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: Colors.blue.withOpacity(0.25),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
        borderSide: const BorderSide(width: 0, style: BorderStyle.none)
      ),
    ),
    keyboardType: isPasswordType
    ? TextInputType.visiblePassword
    : TextInputType.emailAddress,
  );
}